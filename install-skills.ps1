[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Update,
    [string]$WorkspacePath,
    [switch]$ExposeGlobal
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================================================================
# AI-Dev-Machine v2 -- Canonical Skills Library Manager
# Canonical Storage (Library): %USERPROFILE%\.agents\skills
# ==============================================================================
$SkillsRoot = Join-Path $env:USERPROFILE '.agents\skills'

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
        Copy-Item -LiteralPath (Join-Path $SourceDirectoryPath '*') -Destination $destDir -Recurse -Force
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
$globalGeminiSkills = Join-Path $env:USERPROFILE '.gemini\config\skills'
if (-not (Test-Path -LiteralPath $globalGeminiSkills -PathType Container)) {
    if (-not $DryRun) {
        $null = New-Item -ItemType Directory -Path $globalGeminiSkills -Force
    }
}

if (Test-Path -LiteralPath $SkillsRoot) {
    $existingGlobalItems = @(Get-ChildItem -LiteralPath $globalGeminiSkills -ErrorAction SilentlyContinue)
    if ($existingGlobalItems.Count -gt 0 -and -not $DryRun) {
        $backupDir = Join-Path $env:USERPROFILE (".gemini\config\skills_backup_" + (Get-Date -Format 'yyyyMMdd_HHmmss'))
        Copy-Item -LiteralPath $globalGeminiSkills -Destination $backupDir -Recurse -Force
        Write-Host "  [BACKUP CREATED] $backupDir" -ForegroundColor DarkGray
    }

    $allCanonicalSkills = @(Get-ChildItem -LiteralPath $SkillsRoot -Directory)
    foreach ($skDir in $allCanonicalSkills) {
        $skDest = Join-Path $globalGeminiSkills $skDir.Name
        $skMd = Join-Path $skDir.FullName 'SKILL.md'
        if (Test-Path -LiteralPath $skMd) {
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
                    Copy-Item -LiteralPath (Join-Path $skDir.FullName '*') -Destination $skDest -Recurse -Force
                    Write-Host "[GLOBAL DISCOVERY UPDATED] $($skDir.Name)" -ForegroundColor Green
                }
            } else {
                Write-Host "[WOULD EXPOSE GLOBALLY] $($skDir.Name)" -ForegroundColor Yellow
            }
        }
    }
}

# Clean up legacy global rule if present
$legacyGlobalRule = Join-Path $env:USERPROFILE '.gemini\config\rules\ai-dev-machine.md'
if (Test-Path -LiteralPath $legacyGlobalRule) {
    if (-not $DryRun) {
        Remove-Item -LiteralPath $legacyGlobalRule -Force -ErrorAction SilentlyContinue
        Write-Host "[REMOVED LEGACY GLOBAL RULE] ai-dev-machine.md" -ForegroundColor Cyan
    }
}

if ($failures.Count -eq 0) {
    Write-Host "SUCCESS: Canonical skills library is up to date ($SkillsRoot) and globally exposed ($globalGeminiSkills)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "INCOMPLETE: $($failures.Count) skill(s) failed validation." -ForegroundColor Red
    exit 1
}
