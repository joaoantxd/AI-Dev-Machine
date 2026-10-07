[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',

    [Parameter(Position = 1)]
    [string]$Target = '.',

    [Parameter()]
    [string]$Profile = '',

    [Parameter()]
    [switch]$DryRun,

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

switch ($Command.ToLower()) {
    'doctor' {
        Invoke-AidevDoctor -WorkspacePath $Target
    }
    'list' {
        Invoke-AidevList -Category $Category
    }
    'resolve' {
        Invoke-AidevResolve -WorkspacePath $Target -Profile $Profile
    }
    'audit' {
        Invoke-AidevAudit -WorkspacePath $Target
    }
    'init' {
        $prof = if ($Profile) { $Profile } else { 'base' }
        Invoke-AidevInit -WorkspacePath $Target -Profile $prof -Force:$Force
    }
    'migrate' {
        $prof = if ($Profile) { $Profile } else { 'base' }
        Invoke-AidevMigrate -WorkspacePath $Target -Profile $prof -DryRun:$DryRun -Force:$Force
    }
    'clean' {
        Invoke-AidevClean -WorkspacePath $Target -DryRun:$DryRun -Force:$Force
    }
    'prune' {
        Invoke-AidevClean -WorkspacePath $Target -DryRun:$DryRun -Force:$Force
    }
    'sync' {
        Invoke-AidevSync -Update:$Update -DryRun:$DryRun
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
        Write-Host " AI-Dev-Machine CLI -- Architecture v2" -ForegroundColor Cyan
        Write-Host "============================================================" -ForegroundColor Cyan
        Write-Host 'Usage: .\aidev.ps1 <command> [target] [options]'
        Write-Host ''
        Write-Host 'Commands:' -ForegroundColor Yellow
        Write-Host '  doctor [path]              : Inspect system, tools, registries, and workspace status (read-only)'
        Write-Host '  list [skills|agents|mcps]  : List managed skills, agents, MCPs, plugins, and profiles from registry'
        Write-Host '  resolve [path] [-Profile]  : Resolve and explain provenance of all components for a profile'
        Write-Host '  audit [path]               : Audit existing project architecture and compatibility (read-only)'
        Write-Host '  init [path] [-Profile ...] : Initialize a new project with Architecture v2'
        Write-Host '  migrate [path] [-DryRun]   : Upgrade project from legacy monolithic junction to v2 isolated structure'
        Write-Host '  clean [path] [-DryRun]     : Clean obsolete generated links and expired backups'
        Write-Host '  sync [-Update] [-DryRun]   : Synchronize canonical global library in %USERPROFILE%\.agents'
        Write-Host '  test                       : Execute the comprehensive automated test suite'
        Write-Host ''
        Write-Host 'Profiles available: base, web-supabase, windows-desktop, monorepo' -ForegroundColor Gray
    }
}
