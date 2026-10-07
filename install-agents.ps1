[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Update,
    [string]$WorkspacePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================================================================
# AI-Dev-Machine v2 -- Canonical Specialists Library Manager
# Canonical Storage (Library): %USERPROFILE%\.agents\agents
# ==============================================================================
$AgentsRoot = Join-Path $env:USERPROFILE '.agents\agents'

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

function Test-AgentFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedName
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    if ((Get-Item -LiteralPath $Path).Length -le 0) { return $false }
    $lines = @(Get-Content -LiteralPath $Path -Encoding utf8 -ErrorAction Stop)
    if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '---') { return $false }
    $closing = @($lines | Select-Object -Skip 1 | Where-Object { $_.Trim() -eq '---' })
    if ($closing.Count -eq 0) { return $false }
    $nameLine = $lines | Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1
    if (-not $nameLine) { return $false }
    $nameMatch = [regex]::Match([string]$nameLine, '^name:\s*(.+)$')
    if (-not $nameMatch.Success) { return $false }
    $declaredName = $nameMatch.Groups[1].Value.Trim().Trim('"', "'")
    if ($declaredName -ne $ExpectedName) { return $false }
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

# Preservacao de agentes locais customizados
if (Test-Path -LiteralPath $AgentsRoot -PathType Container) {
    $managedSlugs = @($ManagedAgents.Slug | ForEach-Object { "$_.md" })
    foreach ($external in @(Get-ChildItem -LiteralPath $AgentsRoot -Filter '*.md' -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $managedSlugs })) {
        Write-Host "[PRESERVE EXTERNAL] $($external.Name)"
    }
}

if ($failures.Count -eq 0) {
    Write-Host "SUCCESS: Canonical specialists library is up to date ($AgentsRoot)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "INCOMPLETE: $($failures.Count) agent(s) failed validation." -ForegroundColor Red
    exit 1
}
