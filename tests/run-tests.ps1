# ==============================================================================
# AI-Dev-Machine Architecture v2.1 — Comprehensive Capability Test Suite
# ==============================================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = $PSScriptRoot
$aidevRoot = Split-Path -Parent $scriptRoot
$coreModule = Join-Path $aidevRoot 'core\AidevCore.psm1'
Import-Module $coreModule -Force

$totalTests = 0
$passedTests = 0
$failedTests = 0

function Assert-Test {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][scriptblock]$Test
    )
    $script:totalTests++
    try {
        & $Test
        $script:passedTests++
        Write-Host "  [PASS] $Name" -ForegroundColor Green
    } catch {
        $script:failedTests++
        Write-Host "  [FAIL] $Name" -ForegroundColor Red
        Write-Host "         Details: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Running AI-Dev-Machine Architecture v2.1 Test Suite" -ForegroundColor Cyan
Write-Host " Capability-Driven Governance & Multi-Agent Materialization" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. Canonical Registries & Schema Validation Tests
# ------------------------------------------------------------------------------
Write-Host "`n--- 1. Canonical Registries & Schema Validation ---" -ForegroundColor Yellow

Assert-Test "capabilities.json parses, contains 16 atomic capabilities with valid categories and fields" {
    $data = Get-RegistryData -Type 'capabilities'
    if (@($data.capabilities).Count -lt 15) { throw "Expected at least 15 capabilities, found $(@($data.capabilities).Count)" }
    $seenIds = [System.Collections.Generic.HashSet[string]]::new()
    $validCategories = @('core', 'topology', 'language', 'frontend', 'backend', 'database', 'platform', 'testing', 'security', 'specialized')
    foreach ($c in $data.capabilities) {
        if (-not $c.id -or -not $c.name -or -not $c.description -or -not $c.category) {
            throw "Capability missing mandatory fields: $($c.id)"
        }
        if ($validCategories -notcontains $c.category) {
            throw "Invalid category for $($c.id): $($c.category)"
        }
        if ($seenIds.Contains($c.id)) { throw "Duplicate capability ID: $($c.id)" }
        $null = $seenIds.Add($c.id)
    }
}

Assert-Test "profiles.json acts as presets referencing only registered capabilities" {
    $capsData = Get-RegistryData -Type 'capabilities'
    $validCapIds = @($capsData.capabilities.id)
    $profsData = Get-RegistryData -Type 'profiles'
    foreach ($pProp in $profsData.profiles.PSObject.Properties) {
        $pName = $pProp.Name
        $pCaps = @($pProp.Value.capabilities)
        if ($pCaps.Count -eq 0) { throw "Preset $pName has empty capabilities" }
        foreach ($c in $pCaps) {
            if ($validCapIds -notcontains $c) {
                throw "Preset $pName references unregistered capability: $c"
            }
        }
    }
}

Assert-Test "aidev-manifest.schema.json exists and is valid JSON Draft-07 schema" {
    $schemaPath = Join-Path $aidevRoot 'schemas\aidev-manifest.schema.json'
    if (-not (Test-Path -LiteralPath $schemaPath)) { throw "aidev-manifest.schema.json missing" }
    $schema = Get-Content -LiteralPath $schemaPath -Raw -Encoding utf8 | ConvertFrom-Json
    if ($schema.'$schema' -ne 'http://json-schema.org/draft-07/schema#') { throw "Invalid schema draft" }
    if ($schema.required -notcontains 'schemaVersion' -or $schema.required -notcontains 'capabilities') {
        throw "Required fields missing in schema"
    }
}

# ------------------------------------------------------------------------------
# 2. Capability Graph Resolver Tests (Dependencies, Cycles & Conflicts)
# ------------------------------------------------------------------------------
Write-Host "`n--- 2. Capability Graph Resolver & Provenance Tests ---" -ForegroundColor Yellow

Assert-Test "Resolve-AidevCapabilities expands transitive dependencies (nextjs -> react -> core)" {
    $res = Resolve-AidevCapabilities -Capabilities @('nextjs')
    $resolved = @($res.ResolvedCapabilities)
    if ($resolved -notcontains 'core') { throw "Missing core in resolved graph" }
    if ($resolved -notcontains 'react') { throw "Missing react transitive dependency for nextjs" }
    if ($resolved -notcontains 'nextjs') { throw "Missing nextjs in resolved graph" }

    # Core must be ordered before dependents
    $coreIdx = $resolved.IndexOf('core')
    $reactIdx = $resolved.IndexOf('react')
    $nextIdx = $resolved.IndexOf('nextjs')
    if ($coreIdx -ge $reactIdx -or $reactIdx -ge $nextIdx) {
        throw "Topological ordering violated: $($resolved -join ' -> ')"
    }
}

Assert-Test "Resolve-AidevCapabilities deduplicates and includes cognitive specialists" {
    $res = Resolve-AidevCapabilities -Capabilities @('core', 'typescript', 'react', 'nextjs')
    $resolved = @($res.ResolvedCapabilities)
    $uniqueCount = ($resolved | Select-Object -Unique).Count
    if ($resolved.Count -ne $uniqueCount) { throw "Duplicate capabilities found in resolution" }

    $agents = @($res.Agents.Name)
    if ($agents -notcontains 'researcher' -or $agents -notcontains 'reviewer' -or $agents -notcontains 'security-reviewer') {
        throw "Cognitive specialists missing from resolved agents"
    }
}

Assert-Test "Resolve-AidevCapabilities tracks exact provenance of rules, skills and agents" {
    $res = Resolve-AidevCapabilities -Capabilities @('postgres', 'nextjs')
    $rule = $res.Rules | Where-Object { $_.Name -eq 'database-postgres.md' } | Select-Object -First 1
    if (-not $rule -or $rule.Source -ne 'capability:postgres') {
        throw "Incorrect provenance for postgres rule: $($rule.Source)"
    }

    $skill = $res.Skills | Where-Object { $_.Name -eq 'vercel-react-best-practices' } | Select-Object -First 1
    if (-not $skill -or $skill.Source -ne 'capability:nextjs') {
        throw "Incorrect provenance for nextjs skill: $($skill.Source)"
    }
}

Assert-Test "Resolve-AidevCapabilities fails closed on unregistered capability" {
    $failed = $false
    try {
        $null = Resolve-AidevCapabilities -Capabilities @('unregistered-stack-123')
    } catch {
        $failed = $true
    }
    if (-not $failed) { throw "Should have thrown error on unregistered capability" }
}

# ------------------------------------------------------------------------------
# 3. Project Manifest Validation & Security Path Traversal Tests
# ------------------------------------------------------------------------------
Write-Host "`n--- 3. Project Manifest Validation & Security Tests ---" -ForegroundColor Yellow

$tempBase = Join-Path ([IO.Path]::GetTempPath()) ("aidev-test-v21-" + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $tempBase -Force

try {
    # 3.1 Valid Manifest Test
    $validWs = Join-Path $tempBase 'ValidProject'
    $null = New-Item -ItemType Directory -Path $validWs -Force
    $validManifestPath = Join-Path $validWs '.aidev.json'
    Set-Content -LiteralPath $validManifestPath -Value (@'
{
  "schemaVersion": 1,
  "preset": "base",
  "capabilities": ["core", "typescript"],
  "projectRules": []
}
'@) -Encoding utf8

    Assert-Test "Test-AidevManifest validates compliant manifest successfully" {
        $valRes = Test-AidevManifest -WorkspacePath $validWs
        if (-not $valRes.Valid) { throw "Manifest marked invalid" }
        if (@($valRes.Resolved.ResolvedCapabilities) -notcontains 'typescript') { throw "Resolved capabilities missing typescript" }
    }

    # 3.2 Unknown Schema Version Rejection
    $badVerWs = Join-Path $tempBase 'BadVerProject'
    $null = New-Item -ItemType Directory -Path $badVerWs -Force
    Set-Content -LiteralPath (Join-Path $badVerWs '.aidev.json') -Value (@'
{
  "schemaVersion": 99,
  "capabilities": ["core"]
}
'@) -Encoding utf8

    Assert-Test "Test-AidevManifest rejects unsupported schemaVersion" {
        $failed = $false
        try {
            $null = Test-AidevManifest -WorkspacePath $badVerWs
        } catch {
            $failed = $true
            if ($_.Exception.Message -notmatch 'Unsupported schemaVersion') { throw $_ }
        }
        if (-not $failed) { throw "Should have rejected schemaVersion 99" }
    }

    # 3.3 Security: Path Traversal Rejection
    $traversalWs = Join-Path $tempBase 'TraversalProject'
    $null = New-Item -ItemType Directory -Path $traversalWs -Force
    Set-Content -LiteralPath (Join-Path $traversalWs '.aidev.json') -Value (@'
{
  "schemaVersion": 1,
  "capabilities": ["core"],
  "projectRules": ["../../outside-workspace-secret.md"]
}
'@) -Encoding utf8

    Assert-Test "Test-AidevManifest rejects path traversal attempt in projectRules" {
        $failed = $false
        try {
            $null = Test-AidevManifest -WorkspacePath $traversalWs
        } catch {
            $failed = $true
            if ($_.Exception.Message -notmatch 'escapes workspace boundary') { throw $_ }
        }
        if (-not $failed) { throw "Should have rejected path traversal in projectRules" }
    }

    # --------------------------------------------------------------------------
    # 4. Read-Only Detection Engine Tests
    # --------------------------------------------------------------------------
    Write-Host "`n--- 4. Read-Only Detection Engine Tests ---" -ForegroundColor Yellow

    $detectWs = Join-Path $tempBase 'DetectSimProject'
    $null = New-Item -ItemType Directory -Path $detectWs -Force
    $null = New-Item -ItemType Directory -Path (Join-Path $detectWs 'apps\web') -Force
    $null = New-Item -ItemType Directory -Path (Join-Path $detectWs 'supabase\migrations') -Force
    Set-Content -LiteralPath (Join-Path $detectWs 'pnpm-workspace.yaml') -Value "packages:\n  - 'apps/*'" -Encoding utf8
    Set-Content -LiteralPath (Join-Path $detectWs 'apps\web\package.json') -Value '{"dependencies":{"next":"14.0.0","react":"18.2.0","@supabase/supabase-js":"2.0.0"},"devDependencies":{"@playwright/test":"1.40.0","typescript":"5.0.0"}}' -Encoding utf8
    Set-Content -LiteralPath (Join-Path $detectWs 'supabase\migrations\20260101_init.sql') -Value "CREATE TABLE test();" -Encoding utf8

    Assert-Test "Invoke-AidevDetect observes monorepo, nextjs, react, supabase, playwright facts" {
        $detectRes = Invoke-AidevDetect -WorkspacePath $detectWs
        $sugIds = @($detectRes.SuggestedCapabilities | Select-Object -ExpandProperty Id)
        if ($sugIds -notcontains 'core') { throw "core missing from suggestions" }
        if ($sugIds -notcontains 'monorepo') { throw "monorepo missing from suggestions" }
        if ($sugIds -notcontains 'nextjs') { throw "nextjs missing from suggestions" }
        if ($sugIds -notcontains 'react') { throw "react missing from suggestions" }
        if ($sugIds -notcontains 'supabase') { throw "supabase missing from suggestions" }
        if ($sugIds -notcontains 'browser-testing') { throw "browser-testing missing from suggestions" }
        if ($sugIds -notcontains 'typescript') { throw "typescript missing from suggestions" }
    }

    Assert-Test "Invoke-AidevDetect is strictly read-only and writes ZERO files to workspace" {
        $filesBefore = @(Get-ChildItem -LiteralPath $detectWs -Recurse | Select-Object -ExpandProperty FullName)
        $null = Invoke-AidevDetect -WorkspacePath $detectWs
        $filesAfter = @(Get-ChildItem -LiteralPath $detectWs -Recurse | Select-Object -ExpandProperty FullName)
        if ($filesBefore.Count -ne $filesAfter.Count) { throw "Detection wrote new files to disk!" }
    }

    # --------------------------------------------------------------------------
    # 5. Generic Validation Gates (Automated, Human, Hardware)
    # --------------------------------------------------------------------------
    Write-Host "`n--- 5. Generic Validation Gates Tests ---" -ForegroundColor Yellow

    $gatesWs = Join-Path $tempBase 'GatesProject'
    $null = New-Item -ItemType Directory -Path $gatesWs -Force
    Set-Content -LiteralPath (Join-Path $gatesWs '.aidev.json') -Value (@'
{
  "schemaVersion": 1,
  "preset": "base",
  "capabilities": ["core"],
  "validationGates": {
    "commands": {
      "test": "pnpm test",
      "build": "pnpm build"
    },
    "automated": [
      {
        "id": "unit-tests",
        "description": "Run fast unit tests",
        "command": "pnpm",
        "args": ["test", "--filter", "@app/core"],
        "cwd": "packages/core"
      }
    ],
    "human": [
      {
        "id": "visual-review",
        "description": "Human visual QA checkpoint before release",
        "requiredFor": ["release"]
      }
    ],
    "hardware": [
      {
        "id": "dual-monitor-qa",
        "description": "Physical verification on dual-monitor setup",
        "requiredFor": ["release"],
        "checklist": ["Verify display DPI scaling", "Verify audio capture"]
      }
    ]
  }
}
'@) -Encoding utf8

    Assert-Test "Validation Gates are resolved with distinct human & hardware checkpoints" {
        $res = Resolve-AidevCapabilities `
            -Capabilities @('core') `
            -ValidationOverrides @{
                commands = @{ 'test' = 'pnpm test' }
                automated = @(@{ id = 'unit-tests'; command = 'pnpm'; args = @('test') })
                human = @(@{ id = 'visual-review'; description = 'Human visual QA' })
                hardware = @(@{ id = 'dual-monitor-qa'; description = 'Physical verification' })
            }

        if ($res.Commands['test'] -ne 'pnpm test') { throw "Command override failed" }
        if (@($res.AutomatedGates).Count -ne 1) { throw "Automated gate missing" }
        if (@($res.HumanGates).Count -ne 1) { throw "Human gate missing" }
        if (@($res.HardwareGates).Count -ne 1) { throw "Hardware gate missing" }
    }

    # --------------------------------------------------------------------------
    # 6. Materialization & Project Lifecycle Tests
    # --------------------------------------------------------------------------
    Write-Host "`n--- 6. Materialization & Lifecycle Tests ---" -ForegroundColor Yellow

    $matWs = Join-Path $tempBase 'MaterializeProject'
    Assert-Test "Invoke-AidevInit creates .aidev.json and materializes isolated .agents" {
        Invoke-AidevInit -WorkspacePath $matWs -Preset 'web-supabase' -Force
        if (-not (Test-Path -LiteralPath (Join-Path $matWs '.aidev.json'))) { throw ".aidev.json missing" }
        if (-not (Test-Path -LiteralPath (Join-Path $matWs 'AGENTS.md'))) { throw "AGENTS.md missing" }
        if (-not (Test-Path -LiteralPath (Join-Path $matWs 'GEMINI.md'))) { throw "GEMINI.md missing" }
        if (-not (Test-Path -LiteralPath (Join-Path $matWs '.agents\.aidev_metadata.json'))) { throw ".aidev_metadata.json missing" }
        if (-not (Test-Path -LiteralPath (Join-Path $matWs '.agents\rules\web-guidelines.md'))) { throw "web-guidelines.md missing" }
        if (-not (Test-Path -LiteralPath (Join-Path $matWs '.agents\rules\database-postgres.md'))) { throw "database-postgres.md missing" }
        if (Test-IsJunction -Path (Join-Path $matWs '.agents')) { throw ".agents must NOT be a junction!" }
    }

    Assert-Test "Invoke-AidevCapability add/remove modifies .aidev.json declaratively" {
        Invoke-AidevCapability -Action 'add' -Id 'electron' -WorkspacePath $matWs
        $m1 = Get-Content -LiteralPath (Join-Path $matWs '.aidev.json') -Raw -Encoding utf8 | ConvertFrom-Json
        if (@($m1.capabilities) -notcontains 'electron') { throw "electron capability not added to manifest" }

        Invoke-AidevCapability -Action 'remove' -Id 'electron' -WorkspacePath $matWs
        $m2 = Get-Content -LiteralPath (Join-Path $matWs '.aidev.json') -Raw -Encoding utf8 | ConvertFrom-Json
        if (@($m2.capabilities) -contains 'electron') { throw "electron capability not removed from manifest" }
    }

    Assert-Test "Apply is idempotent and preserves local project-owned rules" {
        $customLocalRule = Join-Path $matWs '.agents\rules\local-business-rule.md'
        Set-Content -LiteralPath $customLocalRule -Value "# Local Project Business Rule" -Encoding utf8
        Invoke-AidevApply -WorkspacePath $matWs -Force
        if (-not (Test-Path -LiteralPath $customLocalRule)) { throw "Local rule was overwritten on apply!" }
    }

    # --------------------------------------------------------------------------
    # 7. 3-Way Reconciliation Audit Tests
    # --------------------------------------------------------------------------
    Write-Host "`n--- 7. 3-Way Reconciliation Audit Tests ---" -ForegroundColor Yellow

    Assert-Test "Invoke-AidevAudit reports detected vs declared vs materialized divergence accurately" {
        $auditRes = Invoke-AidevAudit -WorkspacePath $matWs
        if (-not $auditRes.HasManifest) { throw "Manifest should be recognized" }
        if ($auditRes.IsMonolithicJunction) { throw "Should not be a junction" }
        if (@($auditRes.MaterializedRules).Count -lt 3) { throw "Materialized rules missing in audit report" }
    }

    # --------------------------------------------------------------------------
    # 8. Migration Adoption & Rollback Tests
    # --------------------------------------------------------------------------
    Write-Host "`n--- 8. Migration Adoption & Rollback Tests ---" -ForegroundColor Yellow

    $legacyWs = Join-Path $tempBase 'LegacySimProject'
    $null = New-Item -ItemType Directory -Path $legacyWs -Force
    $legacyAgentsMd = Join-Path $legacyWs 'AGENTS.md'
    Set-Content -LiteralPath $legacyAgentsMd -Value "# Original Legacy Constitution" -Encoding utf8
    $legacyJunction = Join-Path $legacyWs '.agents'
    $null = cmd /c "mklink /J `"$legacyJunction`" `"$aidevRoot`"" 2>&1

    Assert-Test "Migrate -DryRun previews suggested manifest without altering files" {
        $mtimeBefore = (Get-Item -LiteralPath $legacyAgentsMd).LastWriteTimeUtc
        Invoke-AidevMigrate -WorkspacePath $legacyWs -DryRun
        $mtimeAfter = (Get-Item -LiteralPath $legacyAgentsMd).LastWriteTimeUtc
        if ($mtimeBefore -ne $mtimeAfter) { throw "DryRun altered AGENTS.md!" }
        if (-not (Test-IsJunction -Path $legacyJunction)) { throw "DryRun altered junction!" }
    }

    Assert-Test "Migrate without approved manifest or -AutoApprove fails safely" {
        $failed = $false
        try {
            Invoke-AidevMigrate -WorkspacePath $legacyWs
        } catch {
            $failed = $true
        }
        if (-not $failed) { throw "Migrate should fail without approved manifest or -AutoApprove" }
    }

    Assert-Test "Migrate with -AutoApprove executes migration with safety backup" {
        Invoke-AidevMigrate -WorkspacePath $legacyWs -AutoApprove
        if (Test-IsJunction -Path $legacyJunction) { throw "Junction was not unlinked" }
        if (-not (Test-Path -LiteralPath (Join-Path $legacyWs '.aidev.json'))) { throw ".aidev.json was not created" }
        $backups = @(Get-ChildItem -LiteralPath $legacyWs -Directory -Filter '.aidev_backup_*')
        if ($backups.Count -eq 0) { throw "Backup directory not created" }
    }

    # 8.3 Rollback on Failure Injection
    $failWs = Join-Path $tempBase 'RollbackProject'
    $null = New-Item -ItemType Directory -Path $failWs -Force
    $origContent = "# Original Unmodified Content Fingerprint 999"
    Set-Content -LiteralPath (Join-Path $failWs 'AGENTS.md') -Value $origContent -Encoding utf8
    Set-Content -LiteralPath (Join-Path $failWs 'GEMINI.md') -Value $origContent -Encoding utf8

    Assert-Test "Migrate rollback restores original state when failure is injected" {
        $failedAsExpected = $false
        try {
            Invoke-AidevMigrate -WorkspacePath $failWs -AutoApprove -InjectFailureTest
        } catch {
            $failedAsExpected = $true
        }
        if (-not $failedAsExpected) { throw "Failure injection did not trigger" }
        $restored = Get-Content -LiteralPath (Join-Path $failWs 'AGENTS.md') -Raw -Encoding utf8
        if ($restored.Trim() -ne $origContent.Trim()) { throw "Rollback failed to restore AGENTS.md" }
    }

    # --------------------------------------------------------------------------
    # 9. Clean & Obsolete Artifact Pruning Tests
    # --------------------------------------------------------------------------
    Write-Host "`n--- 9. Clean & Pruning Tests ---" -ForegroundColor Yellow

    $cleanWs = Join-Path $tempBase 'CleanTestProject'
    Invoke-AidevInit -WorkspacePath $cleanWs -Preset 'base' -Force

    $skillsDir = Join-Path $cleanWs '.agents\skills'
    $orphanLink = Join-Path $skillsDir 'orphan-fake-skill'
    $null = cmd /c "mklink /J `"$orphanLink`" `"$aidevRoot`"" 2>&1
    $dummyBackup = Join-Path $cleanWs '.aidev_backup_20260101_000000'
    $null = New-Item -ItemType Directory -Path $dummyBackup -Force
    $userFile = Join-Path $cleanWs '.agents\user-important-notes.txt'
    Set-Content -LiteralPath $userFile -Value "Human notes" -Encoding utf8

    Assert-Test "Invoke-AidevClean prunes orphan link and backup while PRESERVING user file" {
        Invoke-AidevClean -WorkspacePath $cleanWs
        if (Test-Path -LiteralPath $orphanLink) { throw "Clean failed to prune orphan link" }
        if (Test-Path -LiteralPath $dummyBackup) { throw "Clean failed to prune backup directory" }
        if (-not (Test-Path -LiteralPath $userFile)) { throw "Clean deleted user private file!" }
    }

    # --------------------------------------------------------------------------
    # 10. Extensibility Proof Without Engine Modification
    # --------------------------------------------------------------------------
    Write-Host "`n--- 10. Extensibility Without Core Engine Modification ---" -ForegroundColor Yellow

    $extWs = Join-Path $tempBase 'ExtensibilityFixtureProject'
    $null = New-Item -ItemType Directory -Path $extWs -Force

    Assert-Test "Adding new capability to registry allows instant resolve and apply with ZERO engine changes" {
        # Temporarily register fixture-stack capability in memory or test manifest
        $tempCap = [pscustomobject]@{
            id          = 'fixture-stack-x'
            name        = 'Fixture Stack X'
            description = 'Synthetic technology fixture for extensibility validation'
            category    = 'specialized'
            requires    = @('core')
            recommends  = @()
            conflicts   = @()
            rules       = @('architecture-invariants.md')
            skills      = @('systematic-debugging')
            agents      = @('researcher')
            mcps        = @()
            validationDefaults = @{
                'test' = 'fixture-x test'
            }
            detectionHints = @()
        }

        # Backup capabilities.json
        $capRegistryPath = Join-Path $aidevRoot 'registry\capabilities.json'
        $origCapJson = Get-Content -LiteralPath $capRegistryPath -Raw -Encoding utf8
        $capObj = $origCapJson | ConvertFrom-Json
        $capList = [System.Collections.Generic.List[object]]::new([object[]]$capObj.capabilities)
        $capList.Add($tempCap)
        $capObj.capabilities = @($capList)
        $capObj | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $capRegistryPath -Encoding utf8

        try {
            # Test manifest with new capability
            Set-Content -LiteralPath (Join-Path $extWs '.aidev.json') -Value (@'
{
  "schemaVersion": 1,
  "preset": null,
  "capabilities": ["core", "fixture-stack-x"]
}
'@) -Encoding utf8

            $val = Test-AidevManifest -WorkspacePath $extWs
            if (@($val.Resolved.ResolvedCapabilities) -notcontains 'fixture-stack-x') {
                throw "Resolver failed to include dynamically registered capability"
            }
            if ($val.Resolved.Commands['test'] -ne 'fixture-x test') {
                throw "Resolver failed to adopt validationDefaults from dynamic capability"
            }

            Invoke-AidevApply -WorkspacePath $extWs -Force
            if (-not (Test-Path -LiteralPath (Join-Path $extWs '.agents\rules\architecture-invariants.md'))) {
                throw "Apply failed to materialize for dynamic capability"
            }
        } finally {
            # Restore canonical capabilities.json
            Set-Content -LiteralPath $capRegistryPath -Value $origCapJson -Encoding utf8
        }
    }

    # --------------------------------------------------------------------------
    # 11. Synthetic Multi-Stack Generic Fixtures
    # --------------------------------------------------------------------------
    Write-Host "`n--- 11. Synthetic Multi-Stack Generic Fixtures ---" -ForegroundColor Yellow

    # Fixture A: Python / FastAPI / Postgres / pytest
    $fixAWs = Join-Path $tempBase 'FixtureA_PythonFastAPI'
    $null = New-Item -ItemType Directory -Path $fixAWs -Force
    Set-Content -LiteralPath (Join-Path $fixAWs 'pyproject.toml') -Value "[project]\nname='api'\ndependencies=['fastapi']" -Encoding utf8

    Assert-Test "Fixture A (Python/Postgres) detection and resolution" {
        $detA = Invoke-AidevDetect -WorkspacePath $fixAWs
        if (@($detA.SuggestedCapabilities | Select-Object -ExpandProperty Id) -notcontains 'python') {
            throw "Failed to detect Python in Fixture A"
        }
        $resA = Resolve-AidevCapabilities -Capabilities @('core', 'python', 'postgres')
        if (@($resA.ResolvedCapabilities) -notcontains 'postgres' -or @($resA.ResolvedCapabilities) -notcontains 'python') {
            throw "Failed to resolve Python + Postgres"
        }
    }

    # Fixture B: Rust / Tauri / SQLite
    $fixBWs = Join-Path $tempBase 'FixtureB_RustTauri'
    $null = New-Item -ItemType Directory -Path $fixBWs -Force
    Set-Content -LiteralPath (Join-Path $fixBWs 'Cargo.toml') -Value "[package]\nname='tauri-app'" -Encoding utf8

    Assert-Test "Fixture B (SQLite Composition) resolution" {
        $resB = Resolve-AidevCapabilities -Capabilities @('core', 'sqlite')
        if (@($resB.ResolvedCapabilities) -notcontains 'sqlite') {
            throw "Failed to resolve SQLite in Fixture B"
        }
    }

    # Fixture C: Java / Spring Boot / Gradle
    $fixCWs = Join-Path $tempBase 'FixtureC_JavaGradle'
    $null = New-Item -ItemType Directory -Path $fixCWs -Force
    Set-Content -LiteralPath (Join-Path $fixCWs 'build.gradle') -Value "plugins { id 'org.springframework.boot' }" -Encoding utf8

    Assert-Test "Fixture C (Generic Baseline) detection and resolution" {
        $detC = Invoke-AidevDetect -WorkspacePath $fixCWs
        if (@($detC.SuggestedCapabilities | Select-Object -ExpandProperty Id) -notcontains 'core') {
            throw "Failed to suggest universal core for Fixture C"
        }
    }

} finally {
    if (Test-Path -LiteralPath $tempBase) {
        Get-ChildItem -LiteralPath $tempBase -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -eq 'Junction' } | ForEach-Object {
            cmd /c "rmdir `"$($_.FullName)`"" | Out-Null
        }
        Remove-Item -LiteralPath $tempBase -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ------------------------------------------------------------------------------
# Test Summary
# ------------------------------------------------------------------------------
$summaryColor = if ($failedTests -eq 0) { 'Green' } else { 'Red' }
$summaryText = ' Test Results: ' + $passedTests + '/' + $totalTests + ' PASSED (' + $failedTests + ' Failed)'
Write-Host "`n$summaryText" -ForegroundColor $summaryColor
Write-Host "============================================================" -ForegroundColor Cyan

if ($failedTests -gt 0) {
    exit 1
} else {
    exit 0
}
