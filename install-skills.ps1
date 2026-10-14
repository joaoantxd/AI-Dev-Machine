[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Update,
    [string]$WorkspacePath,
    [switch]$ExposeGlobal,
    [string]$UserProfileOverride
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================================================================
# AI-Dev-Machine v2 -- Canonical Skills Library Manager
# Canonical Storage (Library): %USERPROFILE%\.agents\skills
# ==============================================================================
$effectiveUserProfile = if ($UserProfileOverride) { $UserProfileOverride } else { $env:USERPROFILE }
$SkillsRoot = Join-Path $effectiveUserProfile '.agents\skills'

# Registry is the Single Source of Truth
$registryFile = Join-Path $PSScriptRoot 'registry\skills.json'
if (-not (Test-Path -LiteralPath $registryFile)) {
    throw "Canonical registry not found at $registryFile"
}
$skillsJson = Get-Content -LiteralPath $registryFile -Raw -Encoding utf8 | ConvertFrom-Json
$Managed = @($skillsJson.skills | ForEach-Object {
    $item = [pscustomobject]@{
        Name           = $_.id
        Repo           = $_.repo
        SourceType     = $_.sourceType
        ExpectedName   = $_.expectedName
        GlobalExposure = if ($_.PSObject.Properties.Name.Contains('globalExposure')) { [bool]$_.globalExposure } else { $false }
    }
    if ($_.PSObject.Properties.Name.Contains('subpath') -and $_.subpath) {
        $item | Add-Member -NotePropertyName 'Subpath' -NotePropertyValue $_.subpath
    }
    if ($_.PSObject.Properties.Name.Contains('adapter') -and $_.adapter) {
        $item | Add-Member -NotePropertyName 'Adapter' -NotePropertyValue $_.adapter
    }
    if ($_.PSObject.Properties.Name.Contains('branch') -and $_.branch) {
        $item | Add-Member -NotePropertyName 'Branch' -NotePropertyValue $_.branch
    }
    if ($_.PSObject.Properties.Name.Contains('localPath') -and $_.localPath) {
        $item | Add-Member -NotePropertyName 'LocalPath' -NotePropertyValue $_.localPath
    }
    $item
})

function Test-SkillDirectory {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$ExpectedName)
    $skillFile = Join-Path $Path 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) { return $false }
    if ((Get-Item -LiteralPath $skillFile).Length -le 0) { return $false }
    $lines = @(Get-Content -LiteralPath $skillFile -Encoding utf8 -ErrorAction Stop)
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
}

function Invoke-GitClone {
    param([Parameter(Mandatory)][string]$Repo, [Parameter(Mandatory)][string]$Destination, [string]$Branch)
    $cloneArgs = @('clone', '--depth', '1', '--quiet')
    if ($Branch) { $cloneArgs += @('--branch', $Branch) }
    $cloneArgs += @("https://github.com/$Repo.git", $Destination)
    $output = @(& git @cloneArgs 2>&1)
    if ($LASTEXITCODE -ne 0) { throw (($output | ForEach-Object ToString) -join "`n") }
}

function Set-ManagedSkillDirectory {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$SourceDirectoryPath)
    $destDir = Join-Path $SkillsRoot $Skill.Name
    $backupDir = Join-Path ([IO.Path]::GetTempPath()) ("aidev-skill-backup-{0}" -f [guid]::NewGuid().ToString('N'))
    $hadExisting = Test-Path -LiteralPath $destDir -PathType Container

    try {
        if ($hadExisting) {
            Move-Item -LiteralPath $destDir -Destination $backupDir -Force
        }
        $null = New-Item -ItemType Directory -Path $destDir -Force
        Get-ChildItem -LiteralPath $SourceDirectoryPath | Copy-Item -Destination $destDir -Recurse -Force
        if (-not (Test-SkillDirectory -Path $destDir -ExpectedName $Skill.ExpectedName)) {
            throw "Validacao pos-copia falhou para a skill $($Skill.Name)"
        }
    } catch {
        if (Test-Path -LiteralPath $destDir) {
            Remove-Item -LiteralPath $destDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if ($hadExisting -and (Test-Path -LiteralPath $backupDir)) {
            Move-Item -LiteralPath $backupDir -Destination $destDir -Force
        }
        throw
    } finally {
        if (Test-Path -LiteralPath $backupDir) {
            Remove-Item -LiteralPath $backupDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Test-IsCorrectJunction {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$ExpectedTarget)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item -or $item.LinkType -ne 'Junction') { return $false }
    $target = if ($item.Target -is [array]) { $item.Target[0] } else { $item.Target }
    if (-not $target) { return $false }
    $resolvedTarget = [IO.Path]::GetFullPath($target).TrimEnd('\', '/')
    $resolvedExpected = [IO.Path]::GetFullPath($ExpectedTarget).TrimEnd('\', '/')
    return ($resolvedTarget -ieq $resolvedExpected)
}

# --- Execution ---
Write-Host "AI-Dev-Machine v2: Canonical Skills Library Sync"
Write-Host "Target Library: $SkillsRoot"

if (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
    if (-not $DryRun) {
        $null = New-Item -ItemType Directory -Path $SkillsRoot -Force
    }
}

$localSkillsBase = Join-Path $PSScriptRoot 'skills'
$groups = $Managed | Group-Object -Property Repo
$tempWorkspaces = [System.Collections.Generic.List[string]]::new()
$failures = @()

try {
    foreach ($group in $groups) {
        $repo = $group.Name
        $skills = $group.Group
        $neededSkills = @()

        foreach ($skill in $skills) {
            $destDir = Join-Path $SkillsRoot $skill.Name
            $isValid = (Test-Path -LiteralPath $destDir -PathType Container) -and (Test-SkillDirectory -Path $destDir -ExpectedName $skill.ExpectedName)
            if ($Update -or -not $isValid) {
                $neededSkills += $skill
            } else {
                Write-Host "[PRESENT] $($skill.Name)"
            }
        }

        if ($neededSkills.Count -eq 0) { continue }

        if ($repo -eq 'LOCAL') {
            foreach ($skill in $neededSkills) {
                $localDir = Join-Path $localSkillsBase $skill.Name
                if (Test-Path -LiteralPath $localDir -PathType Container) {
                    if ($DryRun) {
                        Write-Host "[WOULD COPY LOCAL] $($skill.Name)"
                    } else {
                        try {
                            Set-ManagedSkillDirectory -Skill $skill -SourceDirectoryPath $localDir
                            Write-Host "[INSTALLED LOCAL] $($skill.Name)"
                        } catch {
                            $failures += "[ERROR] $($skill.Name): $($_.Exception.Message)"
                            Write-Host "[ERROR] $($skill.Name): $($_.Exception.Message)"
                        }
                    }
                } else {
                    $failures += "[MISSING LOCAL] $($skill.Name): Pasta $localDir nao encontrada"
                    Write-Host "[MISSING LOCAL] $($skill.Name)"
                }
            }
            continue
        }

        # Check local canonical cache if present before attempting network git clone
        $machineSkillsBase = Join-Path $env:USERPROFILE '.agents\skills'
        $unresolvedSkills = @()
        foreach ($skill in $neededSkills) {
            $machineSkillDir = Join-Path $machineSkillsBase $skill.Name
            if (-not $Update -and ($machineSkillsBase -ine $SkillsRoot) -and (Test-Path -LiteralPath $machineSkillDir -PathType Container) -and (Test-SkillDirectory -Path $machineSkillDir -ExpectedName $skill.ExpectedName)) {
                if ($DryRun) {
                    Write-Host "[WOULD COPY CACHED] $($skill.Name)"
                } else {
                    try {
                        Set-ManagedSkillDirectory -Skill $skill -SourceDirectoryPath $machineSkillDir
                        Write-Host "[INSTALLED CACHED] $($skill.Name)"
                    } catch {
                        $unresolvedSkills += $skill
                    }
                }
            } else {
                $unresolvedSkills += $skill
            }
        }
        $neededSkills = $unresolvedSkills
        if ($neededSkills.Count -eq 0) { continue }

        if ($DryRun) {
            foreach ($skill in $neededSkills) {
                Write-Host "[WOULD SYNC] $($skill.Name) from $repo"
            }
            continue
        }

        Write-Host "Fetching upstream repo: $repo"
        $tempRepo = Join-Path ([IO.Path]::GetTempPath()) ("aidev-repo-{0}" -f [guid]::NewGuid().ToString('N'))
        $tempWorkspaces.Add($tempRepo)

        try {
            $branch = if ($skills[0].PSObject.Properties.Name -contains 'Branch') { $skills[0].Branch } else { $null }
            Invoke-GitClone -Repo $repo -Destination $tempRepo -Branch $branch
            foreach ($skill in $neededSkills) {
                try {
                    if ($skill.PSObject.Properties.Name -contains 'Adapter' -and $skill.Adapter -eq 'custom-staging') {
                        $staging = Join-Path ([IO.Path]::GetTempPath()) ("aidev-stage-{0}" -f [guid]::NewGuid().ToString('N'))
                        $tempWorkspaces.Add($staging)
                        New-GraphifyStaging -Skill $skill -RepositoryPath $tempRepo -StagingPath $staging
                        Set-ManagedSkillDirectory -Skill $skill -SourceDirectoryPath $staging
                    } else {
                        $sourcePath = Resolve-SkillPath -Skill $skill -RepositoryPath $tempRepo
                        Set-ManagedSkillDirectory -Skill $skill -SourceDirectoryPath $sourcePath
                    }
                    Write-Host "[INSTALLED] $($skill.Name)"
                } catch {
                    $failures += "[ERROR] $($skill.Name): $($_.Exception.Message)"
                    Write-Host "[ERROR] $($skill.Name): $($_.Exception.Message)"
                }
            }
        } catch {
            $msg = $_.Exception.Message
            foreach ($skill in $neededSkills) {
                $failures += "[ERROR] $($skill.Name): $msg"
                Write-Host "[ERROR] $($skill.Name): $msg"
            }
        }
    }
} finally {
    foreach ($temp in $tempWorkspaces) {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- Global Exposure in Antigravity IDE (~/.gemini/config/skills) ---
# Synchronize canonical skills as physical directories so Antigravity IDE natively discovers all 33 skills
$globalGeminiSkills = Join-Path $effectiveUserProfile '.gemini\config\skills'
if (-not (Test-Path -LiteralPath $globalGeminiSkills -PathType Container)) {
    if (-not $DryRun) {
        $null = New-Item -ItemType Directory -Path $globalGeminiSkills -Force
    }
}

if (Test-Path -LiteralPath $SkillsRoot) {
    $existingGlobalItems = @(Get-ChildItem -LiteralPath $globalGeminiSkills -ErrorAction SilentlyContinue)
    if ($existingGlobalItems.Count -gt 0 -and -not $DryRun) {
        $backupDir = Join-Path $effectiveUserProfile (".gemini\config\skills_backup_" + (Get-Date -Format 'yyyyMMdd_HHmmss'))
        Copy-Item -LiteralPath $globalGeminiSkills -Destination $backupDir -Recurse -Force
        Write-Host "  [BACKUP CREATED] $backupDir" -ForegroundColor DarkGray
    }

    $proactiveDescriptions = @{
        'improve-codebase-architecture' = 'Use proactively whenever refactoring, restructuring modules, reducing coupling, fixing shallow modules, or improving codebase architecture and testability. Scans codebases for module-deepening opportunities and architectural friction.'
        'security-best-practices'       = 'Use proactively whenever writing, reviewing, or hardening Python, JavaScript/TypeScript, or Go code that touches auth, input validation, IPC, network, crypto, file I/O, or database queries to enforce secure-by-default patterns.'
        'security-threat-model'         = 'Use proactively when designing or reviewing architecture, authentication, IPC bridges, multi-tenant boundaries, remote control protocols, or APIs to enumerate trust boundaries, assets, attacker capabilities, abuse paths, and mitigations.'
        'devils-advocate'               = 'Use proactively to stress-test architectural plans, complex designs, risky migrations, and critical code changes via pre-mortem, inversion, and blind-spot analysis to catch failure modes early.'
        'code-review'                   = 'Use proactively when reviewing code changes, auditing diffs/PRs/branches, or validating that an implementation adheres to repository coding standards and task specifications.'
        'codebase-design'               = 'Use proactively whenever designing new modules/services/classes, refactoring interfaces, deciding where boundaries or seams belong, or improving code testability and modularity using deep-module principles.'
        'domain-modeling'               = 'Use proactively when modeling business domains, defining entities/types/schemas, clarifying codebase terminology, writing or editing CONTEXT.md, or recording architectural decision records (ADRs).'
        'diagnosing-bugs'               = 'Use proactively alongside systematic-debugging whenever investigating hard bugs, exceptions, test failures, race conditions, or performance regressions before proposing code fixes.'
        'web-design-guidelines'         = 'Use proactively whenever building, editing, or reviewing web/desktop UI components to enforce Web Interface Guidelines, accessibility, keyboard navigation, focus states, and UX polish.'
        'context-engineering'           = 'Use proactively when organizing project governance (AGENTS.md, GEMINI.md, .agents/rules), structuring context for large codebases, or optimizing progressive disclosure.'
        'review-skills'                 = 'Use proactively when auditing, organizing, or validating skill directories (.agents/skills) for duplicates, broken references, frontmatter validity, composability issues, and skill gaps.'
        'prompt-master'                 = 'Use whenever writing, refining, or calibrating system prompts, agent instructions, LLM prompts, rules, or subagent prompts.'
    }

    function Optimize-SkillFrontmatter {
        param([string]$SkillMdPath, [string]$SkillName)
        if (-not (Test-Path -LiteralPath $SkillMdPath -PathType Leaf)) { return }
        $raw = Get-Content -LiteralPath $SkillMdPath -Raw -Encoding utf8
        if ($raw -notmatch '(?s)^---\r?\n(.*?)\r?\n---(\r?\n.*)?$') { return }
        $fm = $matches[1]
        $body = $matches[2]
        $changed = $false

        # 1. Strip disable-model-invocation: true so Antigravity IDE never hides downloaded skills from <skills>
        if ($fm -match '(?m)^disable-model-invocation:\s*true\s*\r?\n?') {
            $fm = [regex]::Replace($fm, '(?m)^disable-model-invocation:\s*true\s*\r?\n?', '')
            $changed = $true
        }

        # 2. Replace restrictive upstream descriptions ("Trigger only when...", "Do not trigger...") with proactive autonomous descriptions
        if ($proactiveDescriptions.ContainsKey($SkillName)) {
            $newDesc = $proactiveDescriptions[$SkillName]
            $lines = @($fm -split "\r?\n")
            $newLines = [System.Collections.Generic.List[string]]::new()
            $inDescBlock = $false
            $replacedDesc = $false
            foreach ($line in $lines) {
                if ($line -match '^description:\s*(.*)$') {
                    $newLines.Add(('description: "' + $newDesc + '"'))
                    $replacedDesc = $true
                    $valPart = $matches[1].Trim()
                    if ($valPart -eq '>' -or $valPart -eq '>-' -or $valPart -eq '|' -or $valPart -eq '|-') {
                        $inDescBlock = $true
                    } else {
                        $inDescBlock = $false
                    }
                    continue
                }
                if ($inDescBlock) {
                    if ($line -match '^\s+') {
                        continue
                    } else {
                        $inDescBlock = $false
                    }
                }
                if ($line.Trim().Length -gt 0) {
                    $newLines.Add($line)
                }
            }
            if ($replacedDesc) {
                $fm = ($newLines -join "`r`n")
                $changed = $true
            }
        }

        if ($changed) {
            $updated = "---`r`n" + $fm.TrimEnd() + "`r`n---" + $body
            Set-Content -LiteralPath $SkillMdPath -Value $updated -Encoding utf8
        }
    }

    $allCanonicalSkills = @(Get-ChildItem -LiteralPath $SkillsRoot -Directory)
    $canonicalNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($skDir in $allCanonicalSkills) {
        $null = $canonicalNames.Add($skDir.Name)
        $skDest = Join-Path $globalGeminiSkills $skDir.Name
        $skMd = Join-Path $skDir.FullName 'SKILL.md'
        if (Test-Path -LiteralPath $skMd) {
            if (-not $DryRun) {
                Optimize-SkillFrontmatter -SkillMdPath $skMd -SkillName $skDir.Name
            }
            if (Test-IsCorrectJunction -Path $skDest -ExpectedTarget $skDir.FullName) {
                if (-not $DryRun) {
                    cmd /c "rmdir `"$skDest`"" | Out-Null
                }
            }
            if (-not $DryRun) {
                if (-not (Test-Path -LiteralPath $skDest)) {
                    Copy-Item -LiteralPath $skDir.FullName -Destination $skDest -Recurse -Force
                    Write-Host "[GLOBAL DISCOVERY READY] $($skDir.Name)" -ForegroundColor Green
                } else {
                    Remove-Item -LiteralPath $skDest -Recurse -Force
                    Copy-Item -LiteralPath $skDir.FullName -Destination $skDest -Recurse -Force
                    Write-Host "[GLOBAL DISCOVERY UPDATED] $($skDir.Name)" -ForegroundColor Green
                }
            } else {
                Write-Host "[WOULD EXPOSE GLOBALLY] $($skDir.Name)" -ForegroundColor Yellow
            }
        }
    }

    # Log preservation of external / custom user skills
    foreach ($item in $existingGlobalItems) {
        if ($item.PSIsContainer -and -not $canonicalNames.Contains($item.Name)) {
            Write-Host "[PRESERVE EXTERNAL SKILL] $($item.Name)" -ForegroundColor Cyan
        }
    }
}

# Clean up legacy global rule if present
$legacyGlobalRule = Join-Path $effectiveUserProfile '.gemini\config\rules\ai-dev-machine.md'
if (Test-Path -LiteralPath $legacyGlobalRule) {
    if (-not $DryRun) {
        Remove-Item -LiteralPath $legacyGlobalRule -Force -ErrorAction SilentlyContinue
        Write-Host "[REMOVED LEGACY GLOBAL RULE] ai-dev-machine.md" -ForegroundColor Cyan
    }
}

# Ensure global skill routing rule is active in Antigravity global configuration
$globalRulesDir = Join-Path $effectiveUserProfile '.gemini\config\rules'
if (-not (Test-Path -LiteralPath $globalRulesDir -PathType Container)) {
    if (-not $DryRun) { $null = New-Item -ItemType Directory -Path $globalRulesDir -Force }
}
$skillRoutingTemplate = Join-Path $PSScriptRoot 'templates\rules\skill-routing.md'
if (Test-Path -LiteralPath $skillRoutingTemplate) {
    $globalSkillRouting = Join-Path $globalRulesDir 'skill-routing.md'
    if (-not $DryRun) {
        Copy-Item -LiteralPath $skillRoutingTemplate -Destination $globalSkillRouting -Force
        Write-Host "[GLOBAL RULE SYNCED] skill-routing.md" -ForegroundColor Green
    } else {
        Write-Host "[WOULD SYNC GLOBAL RULE] skill-routing.md" -ForegroundColor Yellow
    }
}

if ($failures.Count -eq 0) {
    Write-Host "SUCCESS: Canonical skills library is up to date ($SkillsRoot) and globally exposed ($globalGeminiSkills)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "INCOMPLETE: $($failures.Count) skill(s) failed validation." -ForegroundColor Red
    exit 1
}
