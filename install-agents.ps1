[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Update,
    [string]$WorkspacePath,
    [string]$UserProfileOverride
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================================================================
# AI-Dev-Machine v2 -- Canonical Specialists Library Manager
# Canonical Storage (Library): %USERPROFILE%\.agents\agents
# ==============================================================================
$effectiveUserProfile = if ($UserProfileOverride) { $UserProfileOverride } else { $env:USERPROFILE }
$AgentsRoot = Join-Path $effectiveUserProfile '.agents\agents'

$registryFile = Join-Path $PSScriptRoot 'registry\agents.json'
if (-not (Test-Path -LiteralPath $registryFile)) {
    throw "Canonical registry not found at $registryFile"
}
$agentsJson = Get-Content -LiteralPath $registryFile -Raw -Encoding utf8 | ConvertFrom-Json
$ManagedAgents = @($agentsJson.agents | Where-Object { $_.source -eq 'upstream' } | ForEach-Object {
    [pscustomobject]@{
        Slug         = $_.slug
        Subpath      = $_.subpath
        ExpectedName = $_.expectedName
    }
})

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Test-HasUtf8Bom {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    return ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
}

function Test-AgentFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedName
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    if ((Get-Item -LiteralPath $Path).Length -le 0) { return $false }
    $lines = @(Get-Content -LiteralPath $Path -Encoding utf8 -ErrorAction Stop)
    if ($lines.Count -eq 0 -or $lines[0].TrimStart([char]0xFEFF).Trim() -ne '---') { return $false }
    $closing = @($lines | Select-Object -Skip 1 | Where-Object { $_.Trim() -eq '---' })
    if ($closing.Count -eq 0) { return $false }
    $nameLine = $lines | Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1
    if (-not $nameLine) { return $false }
    $nameMatch = [regex]::Match([string]$nameLine, '^name:\s*(.+)$')
    if (-not $nameMatch.Success) { return $false }
    $declaredName = $nameMatch.Groups[1].Value.Trim().Trim('"', "'")
    $kebabExpected = ($ExpectedName.ToLowerInvariant() -replace '\s+', '-')
    if ($declaredName -ne $ExpectedName -and $declaredName -ne $kebabExpected) { return $false }
    return $true
}

function Invoke-GitClone {
    param(
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Destination
    )
    $cloneArgs = @('clone', '--depth', '1', '--quiet', "https://github.com/$Repo.git", $Destination)
    $output = @(& git @cloneArgs 2>&1)
    if ($LASTEXITCODE -ne 0) { throw (($output | ForEach-Object ToString) -join "`n") }
}

function Set-ManagedAgentFile {
    param(
        [Parameter(Mandatory)]$Agent,
        [Parameter(Mandatory)][string]$SourceFilePath
    )
    $destFile = Join-Path $AgentsRoot ("$($Agent.Slug).md")
    $backupFile = Join-Path ([IO.Path]::GetTempPath()) ("aidev-agent-backup-{0}.md" -f [guid]::NewGuid().ToString('N'))
    $hadExisting = Test-Path -LiteralPath $destFile -PathType Leaf

    try {
        if ($hadExisting) {
            Copy-Item -LiteralPath $destFile -Destination $backupFile -Force
            Remove-Item -LiteralPath $destFile -Force
        }
        Copy-Item -LiteralPath $SourceFilePath -Destination $destFile -Force
        if (-not (Test-AgentFile -Path $destFile -ExpectedName $Agent.ExpectedName)) {
            throw "Validacao pos-copia falhou para o agente $($Agent.Slug)"
        }
    } catch {
        if (Test-Path -LiteralPath $destFile) {
            Remove-Item -LiteralPath $destFile -Force -ErrorAction SilentlyContinue
        }
        if ($hadExisting -and (Test-Path -LiteralPath $backupFile)) {
            Move-Item -LiteralPath $backupFile -Destination $destFile -Force
        }
        throw
    } finally {
        if (Test-Path -LiteralPath $backupFile) {
            Remove-Item -LiteralPath $backupFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- Execution ---
Write-Host "AI-Dev-Machine v2: Canonical Specialists Library Sync"
Write-Host "Target Library: $AgentsRoot"

if (-not (Test-Path -LiteralPath $AgentsRoot -PathType Container)) {
    if (-not $DryRun) {
        $null = New-Item -ItemType Directory -Path $AgentsRoot -Force
    }
}

$neededAgents = @()
foreach ($agent in $ManagedAgents) {
    $destFile = Join-Path $AgentsRoot ("$($agent.Slug).md")
    $isValid = (Test-Path -LiteralPath $destFile -PathType Leaf) -and (Test-AgentFile -Path $destFile -ExpectedName $agent.ExpectedName)
    if ($Update -or -not $isValid) {
        $neededAgents += $agent
    } else {
        Write-Host "[PRESENT] $($agent.Slug)"
    }
}

$failures = @()
$tempRepoWorkspace = $null

if ($neededAgents.Count -gt 0) {
    if ($DryRun) {
        foreach ($agent in $neededAgents) {
            Write-Host "[WOULD SYNC] $($agent.Slug) from agency-agents"
        }
    } else {
        Write-Host "Fetching upstream repo: msitarzewski/agency-agents"
        $tempRepoWorkspace = Join-Path ([IO.Path]::GetTempPath()) ("aidev-agents-{0}" -f [guid]::NewGuid().ToString('N'))
        try {
            Invoke-GitClone -Repo 'msitarzewski/agency-agents' -Destination $tempRepoWorkspace
            foreach ($agent in $neededAgents) {
                try {
                    $sourcePath = Join-Path $tempRepoWorkspace ($agent.Subpath -replace '/', '\')
                    if (-not (Test-AgentFile -Path $sourcePath -ExpectedName $agent.ExpectedName)) {
                        throw "Arquivo fonte $sourcePath nao contem agente valido para $($agent.Slug)"
                    }
                    Set-ManagedAgentFile -Agent $agent -SourceFilePath $sourcePath
                    Write-Host "[INSTALLED] $($agent.Slug)"
                } catch {
                    $failures += "[ERROR] $($agent.Slug): $($_.Exception.Message)"
                    Write-Host "[ERROR] $($agent.Slug): $($_.Exception.Message)"
                }
            }
        } catch {
            $msg = $_.Exception.Message
            foreach ($agent in $neededAgents) {
                $failures += "[ERROR] $($agent.Slug): $msg"
                Write-Host "[ERROR] $($agent.Slug): $msg"
            }
        } finally {
            if ($tempRepoWorkspace -and (Test-Path -LiteralPath $tempRepoWorkspace)) {
                Remove-Item -LiteralPath $tempRepoWorkspace -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# Sincronizacao de Especialistas Cognitivos (researcher, reviewer, security-reviewer)
$cognitiveAgents = @('researcher.md', 'reviewer.md', 'security-reviewer.md')
$cognitiveDir = Join-Path $PSScriptRoot 'templates\agents'
if (Test-Path -LiteralPath $cognitiveDir -PathType Container) {
    foreach ($ca in $cognitiveAgents) {
        $src = Join-Path $cognitiveDir $ca
        $dest = Join-Path $AgentsRoot $ca
        if (Test-Path -LiteralPath $src) {
            if (-not $DryRun) {
                Copy-Item -LiteralPath $src -Destination $dest -Force
                Write-Host "[SYNCED COGNITIVE] $ca" -ForegroundColor Green
            } else {
                Write-Host "[WOULD SYNC COGNITIVE] $ca" -ForegroundColor Yellow
            }
        }
    }
}

function Optimize-AgentDefinition {
    param(
        [Parameter(Mandatory)][string]$AgentFilePath,
        [Parameter(Mandatory)][string]$Slug
    )
    if (-not (Test-Path -LiteralPath $AgentFilePath -PathType Leaf)) { return }
    $proactiveDescriptions = @{
        'software-architect'       = 'Use proactively via invoke_subagent whenever designing system architecture, defining module boundaries, modeling DDD bounded contexts, evaluating trade-offs, planning cross-package refactorings, or writing ADRs.'
        'backend-architect'        = 'Use proactively via invoke_subagent whenever designing or implementing backend services, APIs (NestJS, Fastify, Express, .NET), Windows Services (Session 0), IPC protocols, signaling servers, or distributed systems.'
        'frontend-developer'       = 'Use proactively via invoke_subagent whenever building, styling, refactoring, or optimizing frontend UI, React components, Next.js 16 App Router pages, Electron renderer interfaces, accessibility (WCAG), or Core Web Vitals.'
        'database-optimizer'       = 'Use proactively via invoke_subagent whenever designing or modifying database schemas, writing PostgreSQL/Supabase migrations, configuring Row Level Security (RLS), optimizing SQL/Kysely queries, indexing, or tuning SQLite.'
        'security-architect'       = 'Use proactively via invoke_subagent whenever performing threat modeling, analyzing trust boundaries, designing multi-tenant isolation, hardening Windows Service DACLs/IPC, or architecting authentication and cryptography.'
        'test-automation-engineer' = 'Use proactively via invoke_subagent whenever creating, debugging, or stabilizing E2E and integration tests using Playwright (browser/Electron), WinApp CLI (Windows UIA desktop automation), or unit test suites.'
        'devops-automator'         = 'Use proactively via invoke_subagent whenever configuring CI/CD pipelines, packaging installers (MSI, Electron Builder), automating auto-update & rollback lifecycles, Docker, or build/release scripts.'
    }
    $agentSkillsMap = @{
        'software-architect'       = @('graphify', 'codebase-design', 'improve-codebase-architecture', 'domain-modeling', 'devils-advocate')
        'backend-architect'        = @('graphify', 'codebase-design', 'improve-codebase-architecture', 'security-best-practices', 'systematic-debugging', 'ponytail')
        'frontend-developer'       = @('graphify', 'ui-ux-pro-max', 'frontend-design', 'impeccable', 'web-design-guidelines', 'vercel-react-best-practices')
        'database-optimizer'       = @('graphify', 'supabase-postgres-best-practices', 'supabase', 'domain-modeling')
        'security-architect'       = @('graphify', 'security-threat-model', 'cybersecurity-review', 'security-best-practices', 'strix')
        'test-automation-engineer' = @('graphify', 'playwright', 'winapp', 'systematic-debugging', 'diagnosing-bugs', 'verification-before-completion')
        'devops-automator'         = @('graphify', 'security-review', 'verification-before-completion', 'ponytail')
    }

    $hasBom = Test-HasUtf8Bom -Path $AgentFilePath
    $raw = Get-Content -LiteralPath $AgentFilePath -Raw -Encoding utf8
    $rawClean = $raw.TrimStart([char]0xFEFF)
    if ($rawClean -notmatch '(?s)^---\r?\n(.*?)\r?\n---(.*)$') { return }
    $fm = $Matches[1]
    $body = $Matches[2]
    $changed = $false

    if ($proactiveDescriptions.ContainsKey($Slug)) {
        $newDesc = $proactiveDescriptions[$Slug]
        $canonicalFm = @(
            "name: $Slug"
            "description: `"$newDesc`""
            "tools:"
            "  - view_file"
            "  - grep_search"
            "  - replace_file_content"
            "  - run_command"
            "subagent: true"
            "mainAgent: false"
            "model: inherit"
        ) -join "`r`n"
        if ($fm.Trim() -ne $canonicalFm.Trim()) {
            $fm = $canonicalFm
            $changed = $true
        }
    }

    if ($agentSkillsMap.ContainsKey($Slug)) {
        $skillsList = ($agentSkillsMap[$Slug] | ForEach-Object { '  - `.agents/skills/' + $_ + '/SKILL.md`' }) -join "`r`n"
        $graphifyHighlight = '> **Surgical Navigation & Token-Economy Protocol (`always_on`)**: On Turn 1, load `.agents/skills/graphify/SKILL.md` and run `if (-not (Test-Path "graphify-out/graph.json")) { graphify extract . --code-only ; graphify cluster-only . --no-label --no-viz } ; graphify query "<topic>" --budget 1200` + `rg -n "<symbol>" <path>` via `run_command` BEFORE opening source files. **NEVER dump `#L1-800` across multiple files** -- use `rg -n` line numbers to call `view_file` only on surgical `StartLine`-`EndLine` windows (`60-150 lines`).'
        $skillSection = "`r`n`r`n" + '## Mandatory Downloaded Skill Routing (`always_on`)' + "`r`n`r`n" + $graphifyHighlight + "`r`n`r`n" + 'On Turn 1, load `.agents/skills/graphify/SKILL.md` plus **only the 1-2 skills from the list below that directly match your specific subtask** (never load all skills at once):' + "`r`n" + $skillsList + "`r`n"
        if ($body -match '(?s)\r?\n\r?\n## Mandatory Downloaded Skill Routing.*$') {
            $newBody = [regex]::Replace($body, '(?s)\r?\n\r?\n## Mandatory Downloaded Skill Routing.*$', $skillSection)
            if ($newBody -ne $body) {
                $body = $newBody
                $changed = $true
            }
        } else {
            $body = $body.TrimEnd() + $skillSection
            $changed = $true
        }
    }

    if ($changed -or $hasBom) {
        $updated = "---`r`n" + $fm.TrimEnd() + "`r`n---`r`n" + $body.TrimStart("`r", "`n")
        Write-Utf8NoBom -Path $AgentFilePath -Content $updated
    }
}

# Sincronizacao global para Antigravity IDE (~/.gemini/config/agents)
$globalGeminiAgents = Join-Path $effectiveUserProfile '.gemini\config\agents'
if (-not (Test-Path -LiteralPath $globalGeminiAgents -PathType Container)) {
    if (-not $DryRun) {
        $null = New-Item -ItemType Directory -Path $globalGeminiAgents -Force
    }
}

if (Test-Path -LiteralPath $AgentsRoot) {
    $existingGlobalAgents = @(Get-ChildItem -LiteralPath $globalGeminiAgents -Filter '*.md' -File -ErrorAction SilentlyContinue)
    $canonicalAgents = @(Get-ChildItem -LiteralPath $AgentsRoot -Filter '*.md' -File)
    $canonicalSlugs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($agFile in $canonicalAgents) {
        $null = $canonicalSlugs.Add($agFile.Name)
        $slugName = [IO.Path]::GetFileNameWithoutExtension($agFile.Name)
        if (-not $DryRun) {
            Optimize-AgentDefinition -AgentFilePath $agFile.FullName -Slug $slugName
        }
        $destFile = Join-Path $globalGeminiAgents $agFile.Name
        if (-not $DryRun) {
            Copy-Item -LiteralPath $agFile.FullName -Destination $destFile -Force
            Write-Host "[GLOBAL AGENT READY] $($agFile.Name)" -ForegroundColor Green
        } else {
            Write-Host "[WOULD EXPOSE AGENT GLOBALLY] $($agFile.Name)" -ForegroundColor Yellow
        }
    }

    # Preservacao de agentes locais customizados
    foreach ($external in $existingGlobalAgents) {
        if (-not $canonicalSlugs.Contains($external.Name)) {
            Write-Host "[PRESERVE EXTERNAL GLOBAL AGENT] $($external.Name)" -ForegroundColor Cyan
        }
    }
}

# Preservacao de agentes locais customizados em AgentsRoot
if (Test-Path -LiteralPath $AgentsRoot -PathType Container) {
    $managedSlugs = @($ManagedAgents.Slug | ForEach-Object { "$_.md" }) + $cognitiveAgents
    foreach ($external in @(Get-ChildItem -LiteralPath $AgentsRoot -Filter '*.md' -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $managedSlugs })) {
        Write-Host "[PRESERVE EXTERNAL] $($external.Name)" -ForegroundColor Cyan
    }
}

if ($failures.Count -eq 0) {
    Write-Host "SUCCESS: Canonical specialists library is up to date ($AgentsRoot)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "INCOMPLETE: $($failures.Count) agent(s) failed validation." -ForegroundColor Red
    exit 1
}
