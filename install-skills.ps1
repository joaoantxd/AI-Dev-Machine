[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Update,
    [string]$WorkspacePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Fonte canonica fisica das Skills do AI Dev Machine: %USERPROFILE%\.agents\skills
$SkillsRoot = Join-Path $env:USERPROFILE '.agents\skills'

# Integration compatibility targets para IAs (Antigravity IDE, Gemini CLI, OpenAI Codex, Claude Code):
# - ~/.gemini/antigravity/skills: caminho documentado pelo Antigravity IDE
# - ~/.gemini/config/skills: caminho de descoberta do ecossistema Google/Antigravity
# - ~/.codex/skills: caminho de descoberta do OpenAI Codex / ChatGPT Desktop
# - ~/.claude/skills: caminho de descoberta do Claude Code / Claude Desktop
$IntegrationRoots = @(
    Join-Path $env:USERPROFILE '.gemini\antigravity\skills'
    Join-Path $env:USERPROFILE '.gemini\config\skills'
    Join-Path $env:USERPROFILE '.codex\skills'
    Join-Path $env:USERPROFILE '.claude\skills'
)

$Managed = @(
    [pscustomobject]@{ Name = 'context-engineering'; Repo = 'addyosmani/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'context-engineering' }
    [pscustomobject]@{ Name = 'prompt-master'; Repo = 'nidhinjs/prompt-master'; SourceType = 'repo-root'; Subpath = '.'; ExpectedName = 'prompt-master' }
    [pscustomobject]@{ Name = 'systematic-debugging'; Repo = 'obra/superpowers'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'systematic-debugging' }
    [pscustomobject]@{ Name = 'verification-before-completion'; Repo = 'obra/superpowers'; SourceType = 'subpath'; Subpath = 'skills/verification-before-completion'; ExpectedName = 'verification-before-completion' }
    [pscustomobject]@{ Name = 'vercel-react-best-practices'; Repo = 'vercel-labs/agent-skills'; SourceType = 'subpath'; Subpath = 'skills/react-best-practices'; ExpectedName = 'vercel-react-best-practices' }
    [pscustomobject]@{ Name = 'ui-ux-pro-max'; Repo = 'nextlevelbuilder/ui-ux-pro-max-skill'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'ui-ux-pro-max' }
    [pscustomobject]@{ Name = 'frontend-design'; Repo = 'anthropics/claude-code'; SourceType = 'subpath'; Subpath = 'plugins/frontend-design/skills/frontend-design'; ExpectedName = 'frontend-design' }
    [pscustomobject]@{ Name = 'web-design-guidelines'; Repo = 'vercel-labs/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'web-design-guidelines' }
    [pscustomobject]@{ Name = 'supabase'; Repo = 'supabase/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'supabase' }
    [pscustomobject]@{ Name = 'supabase-postgres-best-practices'; Repo = 'supabase/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'supabase-postgres-best-practices' }
    [pscustomobject]@{ Name = 'security-best-practices'; Repo = 'openai/skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'security-best-practices' }
    [pscustomobject]@{ Name = 'security-threat-model'; Repo = 'openai/skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'security-threat-model' }
    [pscustomobject]@{ Name = 'finding-google-skills'; Repo = 'google/skills'; SourceType = 'subpath'; Subpath = 'skills/developers/finding-google-skills'; ExpectedName = 'finding-google-skills' }
    [pscustomobject]@{ Name = 'graphify'; Repo = 'Graphify-Labs/graphify'; Branch = 'v8'; SourceType = 'graphify-adapter'; Adapter = 'graphify-agents'; ExpectedName = 'graphify' }
    [pscustomobject]@{ Name = 'playwright'; Repo = 'openai/skills'; SourceType = 'subpath'; Subpath = 'skills/.curated/playwright'; ExpectedName = 'playwright' }
    [pscustomobject]@{ Name = 'caveman'; Repo = 'JuliusBrussee/caveman'; SourceType = 'subpath'; Subpath = 'skills/caveman'; ExpectedName = 'caveman' }
    [pscustomobject]@{ Name = 'diagnosing-bugs'; Repo = 'mattpocock/skills'; SourceType = 'subpath'; Subpath = 'skills/engineering/diagnosing-bugs'; ExpectedName = 'diagnosing-bugs' }
    [pscustomobject]@{ Name = 'code-review'; Repo = 'mattpocock/skills'; SourceType = 'subpath'; Subpath = 'skills/engineering/code-review'; ExpectedName = 'code-review' }
    [pscustomobject]@{ Name = 'codebase-design'; Repo = 'mattpocock/skills'; SourceType = 'subpath'; Subpath = 'skills/engineering/codebase-design'; ExpectedName = 'codebase-design' }
    [pscustomobject]@{ Name = 'improve-codebase-architecture'; Repo = 'mattpocock/skills'; SourceType = 'subpath'; Subpath = 'skills/engineering/improve-codebase-architecture'; ExpectedName = 'improve-codebase-architecture' }
    [pscustomobject]@{ Name = 'cybersecurity-review'; Repo = 'ericmjl/skills'; SourceType = 'subpath'; Subpath = 'skills/cybersecurity-review'; ExpectedName = 'cybersecurity-review' }
    [pscustomobject]@{ Name = 'security-review'; Repo = 'bestdeejay-design/agent-skills'; SourceType = 'subpath'; Subpath = 'skills/security-review'; ExpectedName = 'security-review' }
    [pscustomobject]@{ Name = 'review-skills'; Repo = 'tomzx/agents'; SourceType = 'subpath'; Subpath = 'skills/review-skills'; ExpectedName = 'review-skills' }
    [pscustomobject]@{ Name = 'skill-security-review'; Repo = 'klh/speedy-claude'; SourceType = 'subpath'; Subpath = 'skills/skill-security-review'; ExpectedName = 'skill-security-review' }
    [pscustomobject]@{ Name = 'domain-modeling'; Repo = 'mattpocock/skills'; SourceType = 'subpath'; Subpath = 'skills/engineering/domain-modeling'; ExpectedName = 'domain-modeling' }
    [pscustomobject]@{ Name = 'resolving-merge-conflicts'; Repo = 'mattpocock/skills'; SourceType = 'subpath'; Subpath = 'skills/engineering/resolving-merge-conflicts'; ExpectedName = 'resolving-merge-conflicts' }
    [pscustomobject]@{ Name = 'devils-advocate'; Repo = 'Mathews-Tom/armory'; SourceType = 'subpath'; Subpath = 'skills/devils-advocate'; ExpectedName = 'devils-advocate' }
    [pscustomobject]@{ Name = 'impeccable'; Repo = 'pbakaus/impeccable'; SourceType = 'subpath'; Subpath = '.agents/skills/impeccable'; ExpectedName = 'impeccable' }
    [pscustomobject]@{ Name = 'calm'; Repo = 'Eilodon/CALM'; SourceType = 'adapter'; Adapter = 'calm-adapter'; ExpectedName = 'calm' }
    [pscustomobject]@{ Name = 'ponytail'; Repo = 'DietrichGebert/ponytail'; SourceType = 'subpath'; Subpath = 'skills/ponytail'; ExpectedName = 'ponytail' }
    [pscustomobject]@{ Name = 'winapp'; Repo = 'local'; SourceType = 'local'; LocalPath = 'skills/winapp'; ExpectedName = 'winapp' }
    [pscustomobject]@{ Name = 'strix'; Repo = 'local'; SourceType = 'local'; LocalPath = 'skills/strix'; ExpectedName = 'strix' }
    [pscustomobject]@{ Name = 'understand-anything'; Repo = 'local'; SourceType = 'local'; LocalPath = 'skills/understand-anything'; ExpectedName = 'understand-anything' }
)

function Test-SkillDirectory {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$ExpectedName)
    $skillFile = Join-Path $Path 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) { return $false }
    if ((Get-Item -LiteralPath $skillFile).Length -le 0) { return $false }
    $lines = @(Get-Content -LiteralPath $skillFile -ErrorAction Stop)
    if ($lines.Count -gt 0 -and $lines[0].Trim() -eq '---') {
        $closing = @($lines | Select-Object -Skip 1 | Where-Object { $_.Trim() -eq '---' })
        if ($closing.Count -eq 0) { return $false }
        $nameLine = $lines | Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1
        if ($nameLine) {
            $nameMatch = [regex]::Match([string]$nameLine, '^name:\s*(.+)$')
            if ($nameMatch.Success) {
                $declaredName = $nameMatch.Groups[1].Value.Trim().Trim('"', "'")
                if ($declaredName -ne $ExpectedName) { return $false }
            }
        }
    }
    return $true
}

function Resolve-SkillPath {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$RepositoryPath)
    $subpath = if ($Skill.PSObject.Properties.Name -contains 'Subpath') { $Skill.Subpath } else { $null }
    $expectedName = if ($Skill.PSObject.Properties.Name -contains 'ExpectedName') { $Skill.ExpectedName } else { $Skill.Name }
    if ($subpath) {
        $candidate = Join-Path $RepositoryPath ($subpath -replace '/', '\')
        if (-not (Test-SkillDirectory -Path $candidate -ExpectedName $expectedName)) { throw "Upstream structure changed: $($Skill.Name) - subpath esperado: $subpath" }
        return $candidate
    }
    $skillMatches = @(Get-ChildItem -LiteralPath $RepositoryPath -Directory -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ieq $Skill.Name -and (Test-SkillDirectory -Path $_.FullName -ExpectedName $expectedName) } |
        Select-Object -ExpandProperty FullName)
    if ($skillMatches.Count -ne 1) { throw "subpath nao pode ser resolvido de forma unica (encontrados: $($skillMatches.Count))" }
    return $skillMatches[0]
}

function New-GraphifyStaging {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$RepositoryPath, [Parameter(Mandatory)][string]$StagingPath)
    $source = Join-Path $RepositoryPath 'graphify\skill-agents.md'
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw 'Upstream structure changed: graphify - subpath esperado: graphify/skill-agents.md' }
    $null = New-Item -ItemType Directory -Path $StagingPath -Force
    Copy-Item -LiteralPath $source -Destination (Join-Path $StagingPath 'SKILL.md') -Force
    $references = Join-Path $RepositoryPath 'graphify\skills\agents\references'
    if (Test-Path -LiteralPath $references -PathType Container) {
        Copy-Item -LiteralPath $references -Destination (Join-Path $StagingPath 'references') -Recurse -Force
    }
    if (-not (Test-SkillDirectory -Path $StagingPath -ExpectedName $Skill.Name)) { throw 'Graphify: validacao da Skill em staging falhou' }
    return $StagingPath
}

function New-CalmStaging {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$RepositoryPath, [Parameter(Mandatory)][string]$StagingPath)
    $sourceDir = Join-Path $RepositoryPath 'plugins\calm\skills\calm-guide'
    $sourceSkill = Join-Path $sourceDir 'SKILL.md'
    if (-not (Test-Path -LiteralPath $sourceSkill -PathType Leaf)) { throw 'Upstream structure changed: CALM - subpath esperado: plugins/calm/skills/calm-guide/SKILL.md' }
    $null = New-Item -ItemType Directory -Path $StagingPath -Force
    Copy-Item -Path (Join-Path $sourceDir '*') -Destination $StagingPath -Recurse -Force
    $skillContent = Get-Content -LiteralPath (Join-Path $StagingPath 'SKILL.md') -Raw -Encoding utf8
    $skillContent = $skillContent -replace '(?m)^name:\s*calm-guide\s*$', 'name: calm'
    Set-Content -LiteralPath (Join-Path $StagingPath 'SKILL.md') -Value $skillContent -Encoding utf8
    if (-not (Test-SkillDirectory -Path $StagingPath -ExpectedName $Skill.Name)) { throw 'CALM: validacao da Skill em staging falhou' }
    return $StagingPath
}

function Invoke-GitClone {
    param([string]$Repo, [string]$Destination, [string]$Branch)
    $cloneArgs = @('clone', '--depth', '1', '--quiet')
    if ($Branch) { $cloneArgs += @('--branch', $Branch) }
    $cloneArgs += @("https://github.com/$Repo.git", $Destination)
    $output = @(& git @cloneArgs 2>&1)
    if ($LASTEXITCODE -ne 0) { throw (($output | ForEach-Object ToString) -join "`n") }
}

function Set-ManagedSkill {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$SourcePath)
    $destination = Join-Path $SkillsRoot $Skill.Name
    $backup = Join-Path ([IO.Path]::GetTempPath()) ("aidev-skill-backup-{0}" -f [guid]::NewGuid().ToString('N'))
    $hadExisting = Test-Path -LiteralPath $destination -PathType Container
    try {
        if ($hadExisting) { Copy-Item -LiteralPath $destination -Destination $backup -Recurse -Force; Remove-Item -LiteralPath $destination -Recurse -Force }
        $null = New-Item -ItemType Directory -Path $destination -Force
        Copy-Item -Path (Join-Path $SourcePath '*') -Destination $destination -Recurse -Force
        if (-not (Test-SkillDirectory -Path $destination -ExpectedName $Skill.Name)) { throw 'validacao pos-copia falhou' }
    } catch {
        if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force -ErrorAction SilentlyContinue }
        if ($hadExisting -and (Test-Path -LiteralPath $backup)) { Move-Item -LiteralPath $backup -Destination $destination -Force }
        throw
    } finally { if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force -ErrorAction SilentlyContinue } }
}

function Test-IsCorrectJunction {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$ExpectedTarget)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    if ($item.LinkType -ne 'Junction') { return $false }
    if (-not $item.Target) { return $false }
    $targetPath = if ($item.Target -is [array]) { $item.Target[0] } else { $item.Target }
    try {
        $normActual = [IO.Path]::GetFullPath($targetPath).TrimEnd('\', '/')
        $normExpected = [IO.Path]::GetFullPath($ExpectedTarget).TrimEnd('\', '/')
        return ($normActual -ieq $normExpected)
    } catch {
        return $false
    }
}

Write-Host 'MANAGED SKILLS'
$git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $git) {
    Write-Host '[PREREQUISITE] Git is required. Run SETUP-AI-ENVIRONMENT.md first.'
    exit 2
}
try {
    $gitVersion = @(& $git.Source --version 2>&1)
    if ($LASTEXITCODE -ne 0) { throw (($gitVersion | ForEach-Object ToString) -join "`n") }
} catch {
    Write-Host '[PREREQUISITE] Git is required. Run SETUP-AI-ENVIRONMENT.md first.'
    Write-Host "[ERROR] git --version: $($_.Exception.Message)"
    exit 2
}

if ($DryRun -and -not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
    Write-Host "[CHECK] diretorio ausente: $SkillsRoot (nao sera criado em dry-run)"
} elseif (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
    $null = New-Item -ItemType Directory -Path $SkillsRoot -Force
}

$repoCache = @{}
$failures = @()

foreach ($skill in $Managed) {
    $destination = Join-Path $SkillsRoot $skill.Name
    $exists = Test-Path -LiteralPath $destination -PathType Container
    $present = if ($exists) { Test-SkillDirectory -Path $destination -ExpectedName $skill.Name } else { $false }
    $isCorrupted = $exists -and (-not $present)

    if ($DryRun) {
        if ($Update) {
            if ($exists) { Write-Host "[WOULD UPDATE] $($skill.Name) from $($skill.Repo)" }
            else { Write-Host "[WOULD INSTALL] $($skill.Name) from $($skill.Repo)" }
        } else {
            if ($present) { Write-Host "[SKIP / PRESENT] $($skill.Name)" }
            elseif ($isCorrupted) { Write-Host "[WOULD REPAIR] $($skill.Name)" }
            else { Write-Host "[WOULD INSTALL] $($skill.Name) from $($skill.Repo)" }
        }
        continue
    }

    # If -Update is not requested and the skill is already healthy, SKIP without touching network
    if (-not $Update -and $present) {
        Write-Host "[SKIP / PRESENT] $($skill.Name)"
        continue
    }

    $actionLabel = if ($Update) {
        if ($exists) { 'UPDATE' } else { 'INSTALL' }
    } else {
        if ($isCorrupted) { 'REPAIR' } else { 'INSTALL' }
    }

    try {
        if ($skill.SourceType -eq 'local') {
            $localCandidate = Join-Path $PSScriptRoot ($skill.LocalPath -replace '/', '\')
            if (-not (Test-SkillDirectory -Path $localCandidate -ExpectedName $skill.Name)) {
                throw "Arquivo ou diretorio local da skill invalido: $localCandidate"
            }
            $sourcePath = $localCandidate
        } else {
            if (-not $repoCache.ContainsKey($skill.Repo)) {
                $repoWorkspace = Join-Path ([IO.Path]::GetTempPath()) ("aidev-repo-{0}" -f [guid]::NewGuid().ToString('N'))
                $null = New-Item -ItemType Directory -Path $repoWorkspace -Force
                $branch = if ($skill.PSObject.Properties.Name -contains 'Branch') { $skill.Branch } else { $null }
                Invoke-GitClone -Repo $skill.Repo -Destination $repoWorkspace -Branch $branch
                $repoCache[$skill.Repo] = $repoWorkspace
            }
            $repoPath = $repoCache[$skill.Repo]
            $adapter = if ($skill.PSObject.Properties.Name -contains 'Adapter') { $skill.Adapter } else { $null }
            $sourcePath = if ($adapter -eq 'graphify-agents') {
                $staging = Join-Path $repoPath '.aidev-graphify-staging'
                New-GraphifyStaging -Skill $skill -RepositoryPath $repoPath -StagingPath $staging
            } elseif ($adapter -eq 'calm-adapter') {
                $staging = Join-Path $repoPath '.aidev-calm-staging'
                New-CalmStaging -Skill $skill -RepositoryPath $repoPath -StagingPath $staging
            } else { Resolve-SkillPath -Skill $skill -RepositoryPath $repoPath }
        }

        Write-Host "[$actionLabel] $($skill.Name)"
        Set-ManagedSkill -Skill $skill -SourcePath $sourcePath
        Write-Host "[OK] $($skill.Name)"
    } catch {
        $failureMessage = $_.Exception.Message
        $failureLabel = if ($failureMessage -match 'unable to access|Could not connect|Failed to connect|port 443|network|DNS') { 'BLOCKED_BY_ENVIRONMENT' } else { 'ERROR' }
        $failures += "[$failureLabel] $($skill.Name): $failureMessage"
        Write-Host "[$failureLabel] $($skill.Name): $failureMessage"
    }
}

foreach ($external in @(Get-ChildItem -LiteralPath $SkillsRoot -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @($Managed.Name) })) {
    Write-Host "[PRESERVE EXTERNAL] $($external.Name)"
}
foreach ($workspace in @($repoCache.Values)) {
    if (Test-Path -LiteralPath $workspace) { Remove-Item -LiteralPath $workspace -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host 'MULTI-AI SKILLS INTEGRATION (Antigravity, Codex, Claude)'
$integrationConflicts = @()

foreach ($skill in $Managed) {
    $sourceSkill = Join-Path $SkillsRoot $skill.Name
    $sourceValid = Test-SkillDirectory -Path $sourceSkill -ExpectedName $skill.Name

    if (-not $sourceValid) {
        if ($DryRun) {
            Write-Host "[INTEGRATION / WOULD LINK] $($skill.Name)"
            continue
        }
        $integrationConflicts += "[INTEGRATION / ERROR] $($skill.Name): Skill de origem ausente ou invalida no repositorio canonico"
        Write-Host "[INTEGRATION / ERROR] $($skill.Name)"
        continue
    }

    $skillHasConflict = $false
    $skillAllPresent = $true

    foreach ($root in $IntegrationRoots) {
        $targetPath = Join-Path $root $skill.Name
        if (Test-Path -LiteralPath $targetPath) {
            if (Test-IsCorrectJunction -Path $targetPath -ExpectedTarget $sourceSkill) {
                # Already correct junction
            } else {
                $skillHasConflict = $true
                $skillAllPresent = $false
            }
        } else {
            $skillAllPresent = $false
        }
    }

    if ($skillHasConflict) {
        $integrationConflicts += "[INTEGRATION / CONFLICT / PRESERVED] $($skill.Name)"
        Write-Host "[INTEGRATION / CONFLICT / PRESERVED] $($skill.Name)"
    } elseif ($skillAllPresent) {
        Write-Host "[INTEGRATION / PRESENT] $($skill.Name)"
    } elseif ($DryRun) {
        Write-Host "[INTEGRATION / WOULD LINK] $($skill.Name)"
    } else {
        $linkSuccess = $true
        foreach ($root in $IntegrationRoots) {
            $targetPath = Join-Path $root $skill.Name
            if (-not (Test-Path -LiteralPath $targetPath)) {
                try {
                    $parent = Split-Path -Parent $targetPath
                    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
                        $null = New-Item -ItemType Directory -Path $parent -Force
                    }
                    $linkOutput = cmd /c "mklink /J `"$targetPath`" `"$sourceSkill`"" 2>&1
                    if ($LASTEXITCODE -ne 0 -or -not (Test-IsCorrectJunction -Path $targetPath -ExpectedTarget $sourceSkill)) {
                        $linkSuccess = $false
                        $integrationConflicts += "[INTEGRATION / ERROR] $($skill.Name): Falha ao criar junction em $targetPath ($linkOutput)"
                    }
                } catch {
                    $linkSuccess = $false
                    $integrationConflicts += "[INTEGRATION / ERROR] $($skill.Name): $($_.Exception.Message)"
                }
            }
        }
        if ($linkSuccess) {
            Write-Host "[INTEGRATION / LINK] $($skill.Name)"
        } else {
            Write-Host "[INTEGRATION / ERROR] $($skill.Name)"
        }
    }
}

# Global AI Rules integration (Antigravity Global Rules Root)
$globalRulesDir = Join-Path $env:USERPROFILE '.gemini\config\rules'
$globalRuleFile = Join-Path $globalRulesDir 'ai-dev-machine.md'
if (-not (Test-Path -LiteralPath $globalRulesDir -PathType Container)) {
    if (-not $DryRun) { $null = New-Item -ItemType Directory -Path $globalRulesDir -Force }
}
if (-not (Test-Path -LiteralPath $globalRuleFile)) {
    if ($DryRun) {
        Write-Host "[GLOBAL RULE / WOULD CREATE] ai-dev-machine.md"
    } else {
        $ruleContent = @"
# AI Dev Machine — Global Agent Rules

## Global Skills Architecture
This development machine has 33 canonical managed skills located at `%USERPROFILE%\.agents\skills`.

## Automatic Workspace Linking
When starting work in any project workspace:
1. Check if the `.agents` folder/junction exists in the workspace root.
2. If `.agents` does NOT exist in the workspace, automatically create a Directory Junction to `%USERPROFILE%\.agents` and ensure `.agents/` is in `.gitignore`:
   ```powershell
   cmd /c "mklink /J .agents $env:USERPROFILE\.agents"
   ```
3. This grants immediate, unrestricted access to all `SKILL.md` files within the workspace sandbox without manual user intervention.

## Core Operational Principles
- **Context Engineering**: Keep context lean, follow progressive disclosure, and load only the documentation/skills needed for the specific task.
- **Verification Before Completion**: Never declare a task complete without actual evidence (typecheck, tests, build, or command output).
- **Systematic Debugging**: Investigate root cause before making speculative edits.
- **Security**: Never expose secrets, hardcode API keys, or weaken security policies.
"@
        Set-Content -Path $globalRuleFile -Value $ruleContent -Encoding utf8
        Write-Host "[GLOBAL RULE / CREATED] ai-dev-machine.md"
    }
} else {
    Write-Host "[GLOBAL RULE / PRESENT] ai-dev-machine.md"
}

# Workspace linking se WorkspacePath for fornecido ou se executado dentro de um workspace
$targetWorkspace = if ($WorkspacePath) { (Resolve-Path $WorkspacePath).Path } else { $null }
if ($targetWorkspace) {
    Write-Host "WORKSPACE INTEGRATION: $targetWorkspace"
    $workspaceAgents = Join-Path $targetWorkspace '.agents'
    $canonicalAgents = Join-Path $env:USERPROFILE '.agents'
    if (Test-Path -LiteralPath $workspaceAgents) {
        if (Test-IsCorrectJunction -Path $workspaceAgents -ExpectedTarget $canonicalAgents) {
            Write-Host "[WORKSPACE / PRESENT] .agents junction"
        } else {
            Write-Host "[WORKSPACE / CONFLICT / PRESERVED] .agents ja existe como pasta independente"
        }
    } elseif ($DryRun) {
        Write-Host "[WORKSPACE / WOULD LINK] .agents -> $canonicalAgents"
    } else {
        $null = cmd /c "mklink /J `"$workspaceAgents`" `"$canonicalAgents`"" 2>&1
        if (Test-IsCorrectJunction -Path $workspaceAgents -ExpectedTarget $canonicalAgents) {
            Write-Host "[WORKSPACE / LINKED] .agents -> $canonicalAgents"
        } else {
            Write-Host "[WORKSPACE / ERROR] Falha ao criar junction .agents no workspace"
        }
    }
}

Write-Host 'RESULT:'
if ($DryRun) {
    Write-Host 'DRY RUN'
    exit 0
}
if ($failures.Count -eq 0 -and $integrationConflicts.Count -eq 0) {
    Write-Host 'SUCCESS'
    exit 0
}
Write-Host 'INCOMPLETE'
$failures | ForEach-Object { Write-Host $_ }
$integrationConflicts | ForEach-Object { Write-Host $_ }
exit 1
