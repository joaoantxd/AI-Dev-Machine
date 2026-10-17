[CmdletBinding()]
param([switch]$ValidateOnly)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$engineRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $engineRoot 'core\AidevCore.psm1') -Force
$graphifyScripts = & python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))"
if ($LASTEXITCODE -ne 0) { throw 'Python is required for local Graphify validation.' }
$env:Path += ';' + $graphifyScripts
$targets = @(
    @{ Path = 'D:\Desktop\nexus ai'; Workspace = $true },
    @{ Path = 'D:\Desktop\nexus ai\backend-nexusai'; Workspace = $false },
    @{ Path = 'D:\Desktop\nexus ai\Nexus-AI-Sports'; Workspace = $false },
    @{ Path = (Join-Path $env:USERPROFILE 'Desktop\JJ Elite Sports Site'); Workspace = $false }
)
$results = @()
foreach ($target in $targets) {
    $ws = $target.Path
    if (-not (Test-Path -LiteralPath $ws -PathType Container)) { throw "Workspace missing: $ws" }
    Write-Host "Configuring: $ws"
    $detected = Invoke-AidevDetect -WorkspacePath $ws
    if (-not $ValidateOnly) {
        $backup = Join-Path $ws ('.aidev_backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
        $null = New-Item -ItemType Directory -Path $backup
        foreach ($name in @('AGENTS.md','GEMINI.md','CLAUDE.md','.aidev.json','.gitignore')) {
            $source = Join-Path $ws $name
            if (Test-Path -LiteralPath $source -PathType Leaf) {
                Copy-Item -LiteralPath $source -Destination (Join-Path $backup $name)
            }
        }
        $manifestFile = Join-Path $ws '.aidev.json'
        if (-not (Test-Path -LiteralPath $manifestFile)) {
            $manifest = $detected.SuggestedManifest
            $commands = [ordered]@{}
            $packageFile = Join-Path $ws 'package.json'
            if (Test-Path -LiteralPath $packageFile) {
                $package = Get-Content -LiteralPath $packageFile -Raw | ConvertFrom-Json
                $commands.install = 'npm ci'
                foreach ($command in @('dev','build','lint','test','start')) {
                    if ($package.scripts.PSObject.Properties.Name -contains $command) {
                        $commands[$command] = 'npm run ' + $command
                    }
                }
                $commands.typecheck = 'npx tsc --noEmit'
                # Explicitly document absent scripts instead of inventing a runnable gate.
                if (-not $commands.Contains('test')) { $commands.test = '# No automated test script declared in package.json' }
            } else {
                foreach ($command in @('install','dev','build','lint','test','typecheck')) {
                    $commands[$command] = '# Run the command in backend-nexusai or Nexus-AI-Sports'
                }
            }
            $manifest.validationGates.commands = $commands
            $manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $manifestFile -Encoding utf8
        }
        Invoke-AidevApply -WorkspacePath $ws -DryRun
        Invoke-AidevApply -WorkspacePath $ws
        # apply initializes absent graphs; update also refreshes pre-existing graphs.
        & graphify update $ws
        if ($LASTEXITCODE -ne 0) { throw "Graphify update failed: $ws" }
        & graphify cluster-only $ws --no-label --no-viz
        if ($LASTEXITCODE -ne 0) { throw "Graphify report failed: $ws" }
    }
    $audit = Invoke-AidevAudit -WorkspacePath $ws
    Invoke-AidevDoctor -WorkspacePath $ws
    $skillDirs = @(Get-ChildItem -LiteralPath (Join-Path $ws '.agents\skills') -Directory)
    $skills = @($skillDirs | Where-Object { (Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')) -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) })
    $agents = @(Get-ChildItem -LiteralPath (Join-Path $ws '.agents\agents') -Filter '*.md')
    $codex = @(Get-ChildItem -LiteralPath (Join-Path $ws '.codex\agents') -Filter '*.toml')
    $claude = @(Get-ChildItem -LiteralPath (Join-Path $ws '.claude\agents') -Filter '*.md')
    if ($audit.MigrationNeeded) { throw "Audit requires migration: $ws" }
    if ($skills.Count -ne 33 -or $agents.Count -lt 10 -or $codex.Count -lt $agents.Count -or $claude.Count -lt $agents.Count) {
        throw "Incomplete catalog: $ws (skills=$($skills.Count), canonical=$($agents.Count), codex=$($codex.Count), claude=$($claude.Count))"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $ws 'graphify-out\graph.json'))) { throw "Graph missing: $ws" }
    $results += [pscustomobject]@{ Workspace=$ws; Skills=$skills.Count; Agents=$agents.Count; Codex=$codex.Count; Claude=$claude.Count; MigrationNeeded=$audit.MigrationNeeded }
}
$results | Format-Table -AutoSize
