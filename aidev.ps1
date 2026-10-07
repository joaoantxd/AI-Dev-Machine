[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',

    [Parameter(Position = 1)]
    [string]$Arg1 = '',

    [Parameter(Position = 2)]
    [string]$Arg2 = '',

    [Parameter(Position = 3)]
    [string]$Arg3 = '',

    [Parameter()]
    [string]$Preset = '',

    [Parameter()]
    [string]$Profile = '',

    [Parameter()]
    [string[]]$Capability = @(),

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$AutoApprove,

    [Parameter()]
    [switch]$Update,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [string]$Category = 'all'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$coreModule = Join-Path $PSScriptRoot 'core\AidevCore.psm1'
Import-Module $coreModule -Force

$effectivePreset = if ($Preset) { $Preset } elseif ($Profile) { $Profile } else { '' }

switch ($Command.ToLower()) {
    'doctor' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        Invoke-AidevDoctor -WorkspacePath $target
    }
    'detect' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        Invoke-AidevDetect -WorkspacePath $target
    }
    'manifest' {
        $action = if ($Arg1) { $Arg1 } else { 'show' }
        $target = if ($Arg2) { $Arg2 } else { '.' }
        $p = if ($effectivePreset) { $effectivePreset } else { 'base' }
        Invoke-AidevManifest -Action $action -WorkspacePath $target -Preset $p -Capabilities $Capability -Force:$Force
    }
    'capability' {
        $action = if ($Arg1) { $Arg1 } else { 'list' }
        $id = if ($Arg2) { $Arg2 } else { $null }
        $target = if ($Arg3) { $Arg3 } else { '.' }
        Invoke-AidevCapability -Action $action -Id $id -WorkspacePath $target
    }
    'resolve' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        Invoke-AidevResolve -WorkspacePath $target -Preset $effectivePreset -Capabilities $Capability
    }
    'init' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        $p = if ($effectivePreset) { $effectivePreset } else { 'base' }
        Invoke-AidevInit -WorkspacePath $target -Preset $p -Capabilities $Capability -Force:$Force
    }
    'apply' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        Invoke-AidevApply -WorkspacePath $target -DryRun:$DryRun -Force:$Force
    }
    'audit' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        Invoke-AidevAudit -WorkspacePath $target
    }
    'migrate' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        $p = if ($effectivePreset) { $effectivePreset } else { 'base' }
        Invoke-AidevMigrate -WorkspacePath $target -Preset $p -Capabilities $Capability -DryRun:$DryRun -AutoApprove:$AutoApprove -Force:$Force
    }
    'clean' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        Invoke-AidevClean -WorkspacePath $target -DryRun:$DryRun -Force:$Force
    }
    'prune' {
        $target = if ($Arg1) { $Arg1 } else { '.' }
        Invoke-AidevClean -WorkspacePath $target -DryRun:$DryRun -Force:$Force
    }
    'sync' {
        Invoke-AidevSync -Update:$Update -DryRun:$DryRun
    }
    'list' {
        $cat = if ($Arg1) { $Arg1 } else { $Category }
        Invoke-AidevList -Category $cat
    }
    'test' {
        $testScript = Join-Path $PSScriptRoot 'tests\run-tests.ps1'
        if (Test-Path -LiteralPath $testScript) {
            & powershell -ExecutionPolicy Bypass -File $testScript
        } else {
            Write-Host "Test runner not found at $testScript" -ForegroundColor Red
        }
    }
    default {
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host " AI-Dev-Machine CLI -- Architecture v2.1" -ForegroundColor Cyan
        Write-Host " Capability-Driven Governance & Multi-Agent Materialization" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host 'Usage: .\aidev.ps1 <command> [args...] [options]'
        Write-Host ''
        Write-Host 'Inspection Commands (Read-Only):' -ForegroundColor Yellow
        Write-Host '  doctor [path]                  : Comprehensive 6-point system, schema, and workspace diagnostic'
        Write-Host '  detect [path]                  : Heuristic fact observation and manifest suggestion (read-only)'
        Write-Host '  manifest validate [path]       : Validate .aidev.json against schema v1 and capability graph'
        Write-Host '  manifest show [path]           : Display current project manifest (.aidev.json)'
        Write-Host '  capability list                : List all atomic capabilities registered in registry/capabilities.json'
        Write-Host '  capability show <id>           : Show details, rules, skills, and agents of a capability'
        Write-Host '  resolve [path]                 : Resolve effective graph configuration, provenance, and gates'
        Write-Host '  audit [path]                   : 3-way reconciliation (Detected Reality vs Declared vs Materialized)'
        Write-Host '  list [capabilities|profiles...] : List registry categories'
        Write-Host ''
        Write-Host 'Materialization & Project Commands (Write/Mutative):' -ForegroundColor Yellow
        Write-Host '  manifest init [path] [-Preset] : Initialize .aidev.json manifest without materializing'
        Write-Host '  capability add <id> [path]     : Add an atomic capability to .aidev.json'
        Write-Host '  capability remove <id> [path]  : Remove a capability from .aidev.json'
        Write-Host '  init [path] [-Preset]          : Initialize a new project with .aidev.json and apply materialization'
        Write-Host '  apply [path] [-DryRun]         : Explicitly materialize .aidev.json into .agents/, rules, and configs'
        Write-Host '  migrate [path] [-DryRun]       : Adopt legacy project with backup and automatic rollback on failure'
        Write-Host '  clean [path] [-DryRun]         : Prune obsolete managed rules, orphan skill junctions, and expired backups'
        Write-Host '  sync [-Update] [-DryRun]       : Sync global canonical library in %USERPROFILE%\.agents'
        Write-Host '  test                           : Execute comprehensive automated test suite'
        Write-Host ''
        Write-Host 'Convenience Presets: base, web-supabase, windows-desktop, monorepo' -ForegroundColor Gray
    }
}
