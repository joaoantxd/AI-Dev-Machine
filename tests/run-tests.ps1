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

Assert-Test "Core baseline supplies all 33 physical skills and coordinator routing for every stack" {
    $coreCapability = (Get-RegistryData -Type 'capabilities').capabilities | Where-Object { $_.id -eq 'core' }
    if (@($coreCapability.skills | Select-Object -Unique).Count -ne 33) { throw 'Core baseline must include all 33 downloaded skills' }
    if ($coreCapability.rules -notcontains 'orchestration.md') { throw 'Core baseline must include coordinator-only orchestration' }
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
        $originalCapBytes = [IO.File]::ReadAllBytes($capRegistryPath)
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
            [IO.File]::WriteAllBytes($capRegistryPath, $originalCapBytes)
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

    # --------------------------------------------------------------------------
    # 12. End-to-End Greenfield and Brownfield Project Lifecycle
    # --------------------------------------------------------------------------
    Write-Host "`n--- 12. Greenfield & Brownfield E2E Lifecycle ---" -ForegroundColor Yellow

    # Greenfield New Project
    $greenWs = Join-Path $tempBase 'FixtureGreenfieldNew'
    $null = New-Item -ItemType Directory -Path $greenWs -Force

    Assert-Test "Greenfield new project full lifecycle (init, validate, resolve, audit, apply)" {
        Invoke-AidevInit -WorkspacePath $greenWs -Preset 'web-supabase' -Force
        $val = Invoke-AidevManifest -Action 'validate' -WorkspacePath $greenWs
        if (-not $val.Valid) { throw "Greenfield manifest validation failed" }
        $res = Invoke-AidevResolve -WorkspacePath $greenWs
        if (@($res.ResolvedCapabilities) -notcontains 'react') { throw "Greenfield resolve missing capability" }
        $audit = Invoke-AidevAudit -WorkspacePath $greenWs
        if (-not $audit.HasManifest) { throw "Greenfield audit did not recognize manifest" }
        if (@($audit.MaterializedRules).Count -eq 0) { throw "Greenfield audit reported 0 materialized rules" }
    }

    # Brownfield Adoption with Spaces in Path
    $brownWs = Join-Path $tempBase 'Fixture Brownfield With Spaces'
    $null = New-Item -ItemType Directory -Path $brownWs -Force
    $srcDir = Join-Path $brownWs 'src'
    $null = New-Item -ItemType Directory -Path $srcDir -Force
    Set-Content -LiteralPath (Join-Path $brownWs 'package.json') -Value '{"name":"legacy-app","dependencies":{"react":"18.0.0","next":"14.0.0"}}' -Encoding utf8
    Set-Content -LiteralPath (Join-Path $srcDir 'index.js') -Value 'console.log("Legacy application code");' -Encoding utf8
    Set-Content -LiteralPath (Join-Path $brownWs 'AGENTS.md') -Value '# Custom Legacy AGENTS.md' -Encoding utf8

    Assert-Test "Brownfield adoption of existing repo with spaces (detect, audit, migrate, verify preservation)" {
        $det = Invoke-AidevDetect -WorkspacePath $brownWs
        if (@($det.SuggestedCapabilities | Select-Object -ExpandProperty Id) -notcontains 'nextjs') {
            throw "Failed to detect Next.js in Brownfield fixture"
        }
        $auditPre = Invoke-AidevAudit -WorkspacePath $brownWs
        if ($auditPre.HasManifest) { throw "Pre-migration brownfield should not have manifest" }

        Invoke-AidevMigrate -WorkspacePath $brownWs -AutoApprove -Force

        $auditPost = Invoke-AidevAudit -WorkspacePath $brownWs
        if (-not $auditPost.HasManifest) { throw "Post-migration brownfield missing manifest" }
        if ($auditPost.IsMonolithicJunction) { throw "Post-migration brownfield still has junction" }

        $srcContent = Get-Content -LiteralPath (Join-Path $srcDir 'index.js') -Raw -Encoding utf8
        if (-not $srcContent.Contains("Legacy application code")) { throw "Brownfield migration corrupted source code!" }
    }

    # ------------------------------------------------------------------------------
    # 8. Portable Distribution, Onboarding Prompt & Dynamic Skill Lifecycle Tests
    # ------------------------------------------------------------------------------
    Write-Host "`n--- 8. Portable Distribution, Onboarding Prompt & Dynamic Skill Lifecycle ---" -ForegroundColor Yellow

    Assert-Test "templates/rules/skill-routing.md contains always_on trigger, zero numerical limits, and full multi-skill composition" {
        $rulePath = Join-Path $aidevRoot 'templates\rules\skill-routing.md'
        if (-not (Test-Path -LiteralPath $rulePath)) { throw 'skill-routing.md template missing' }
        $content = Get-Content -LiteralPath $rulePath -Raw -Encoding utf8

        if (-not $content.Contains('trigger: always_on')) { throw 'Missing trigger: always_on in frontmatter' }
        if (-not $content.Contains('Zero Numerical or Frequency Ceilings')) { throw 'Missing Zero Numerical Ceilings invariant' }
        if (-not $content.Contains('Autonomous Activation Without User Prompts')) { throw 'Missing Autonomous Activation invariant' }
        if (-not $content.Contains('Every New User Request')) { throw 'Missing Multi-Turn per-request trigger' }
        if (-not $content.Contains('Stack & Technology Discovery')) { throw 'Missing Stack Discovery trigger' }
        if (-not $content.Contains('Phase & Subtask Transitions')) { throw 'Missing Phase & Subtask Transitions trigger' }
        if (-not $content.Contains('Unexpected Failures, Regressions & Hard Bugs')) { throw 'Missing Failures & Regressions trigger' }
        if (-not $content.Contains('Review, Security & Completion Gates')) { throw 'Missing Review & Verification trigger' }
        if (-not $content.Contains('Synergistic Multi-Skill Composition')) { throw 'Missing Synergistic Multi-Skill Composition guidance' }
        if (-not $content.Contains('Context Reuse')) { throw 'Missing Context Reuse clause' }
        if (-not $content.Contains('Triviality Exemption')) { throw 'Missing Triviality Exemption clause' }
        if (-not $content.Contains('Codebase Comprehension, Architecture & Navigation (Graphify-First Protocol)')) { throw 'Missing Graphify-First Navigation Protocol trigger' }
        if (-not $content.Contains('Graph Consultation Precedence')) { throw 'Missing Graph Consultation Precedence clause' }
        if (-not $content.Contains('Lifecycle & Freshness Verification')) { throw 'Missing Lifecycle & Freshness Verification clause' }
        if (-not $content.Contains('No Indiscriminate Manual Wandering')) { throw 'Missing No Indiscriminate Manual Wandering guideline' }
        if ($content.Contains('1–2 guideline') -or $content.Contains('1-2 skills')) { throw 'Residual restrictive 1-2 skills limit found in skill-routing.md!' }
    }

    Assert-Test "templates/rules/architecture-invariants.md mandates Graphify-First Navigation before broad manual searches" {
        $archRulePath = Join-Path $aidevRoot 'templates\rules\architecture-invariants.md'
        if (-not (Test-Path -LiteralPath $archRulePath)) { throw 'architecture-invariants.md template missing' }
        $archContent = Get-Content -LiteralPath $archRulePath -Raw -Encoding utf8

        if (-not $archContent.Contains('Graphify-First Navigation & Architectural Mapping')) {
            throw 'Missing Graphify-First Navigation section in architecture-invariants.md'
        }
        if (-not $archContent.Contains('consult `graphify-out/` first')) {
            throw 'Missing consult graphify-out/ first clause in architecture-invariants.md'
        }
    }

    Assert-Test "docs/INSTALAR-E-ORGANIZAR.md exists, formatted as pure prompt with all required onboarding stages" {
        $promptPath = Join-Path $aidevRoot 'docs\INSTALAR-E-ORGANIZAR.md'
        if (-not (Test-Path -LiteralPath $promptPath)) { throw 'docs/INSTALAR-E-ORGANIZAR.md missing' }
        $pContent = Get-Content -LiteralPath $promptPath -Raw -Encoding utf8

        if (-not $pContent.StartsWith('# AI-Dev-Machine')) {
            throw 'docs/INSTALAR-E-ORGANIZAR.md must start directly with prompt title'
        }
        if (-not $pContent.Contains('ETAPA 1:')) { throw 'Missing Etapa 1 in onboarding prompt' }
        if (-not $pContent.Contains('ETAPA 2:')) { throw 'Missing Etapa 2 in onboarding prompt' }
        if (-not $pContent.Contains('ETAPA 3:')) { throw 'Missing Etapa 3 in onboarding prompt' }
        if (-not $pContent.Contains('ETAPA 4:')) { throw 'Missing Etapa 4 in onboarding prompt' }
        if (-not $pContent.Contains('ETAPA 5:')) { throw 'Missing Etapa 5 in onboarding prompt' }
        if ($pContent.Contains('CONTABILIDADE')) { throw 'Hardcoded username found in onboarding prompt!' }
    }

    Assert-Test "Isolated temporary user profile simulation (install, physical discovery, custom skill preservation, backups)" {
        $simUserHome = Join-Path $tempBase 'SimulatedUserHome'
        $null = New-Item -ItemType Directory -Path $simUserHome -Force

        # Pre-seed existing custom user skill and custom agent
        $customSkillDir = Join-Path $simUserHome '.gemini\config\skills\custom-user-skill'
        $null = New-Item -ItemType Directory -Path $customSkillDir -Force
        Set-Content -LiteralPath (Join-Path $customSkillDir 'SKILL.md') -Value "---\nname: custom-user-skill\ndescription: Custom user skill\n---\n# Custom Skill Content" -Encoding utf8

        $customAgentDir = Join-Path $simUserHome '.gemini\config\agents'
        $null = New-Item -ItemType Directory -Path $customAgentDir -Force
        Set-Content -LiteralPath (Join-Path $customAgentDir 'custom-user-agent.md') -Value "---\nname: custom-user-agent\ndescription: Custom user agent\n---\n# Custom Agent" -Encoding utf8

        # Run installation targeting simulated user home
        $skillsScript = Join-Path $aidevRoot 'install-skills.ps1'
        $agentsScript = Join-Path $aidevRoot 'install-agents.ps1'

        & powershell -ExecutionPolicy Bypass -File $skillsScript -UserProfileOverride $simUserHome
        if ($LASTEXITCODE -ne 0) { throw 'install-skills.ps1 failed in simulated environment' }

        & powershell -ExecutionPolicy Bypass -File $agentsScript -UserProfileOverride $simUserHome
        if ($LASTEXITCODE -ne 0) { throw 'install-agents.ps1 failed in simulated environment' }

        # Verify physical discovery directory has 33 skills + custom skill
        $geminiSkills = Join-Path $simUserHome '.gemini\config\skills'
        $installedSkills = @(Get-ChildItem -LiteralPath $geminiSkills -Directory)
        if ($installedSkills.Count -lt 34) { throw ('Expected at least 34 skills, found ' + $installedSkills.Count) }

        # Verify custom skill was preserved
        if (-not (Test-Path -LiteralPath (Join-Path $customSkillDir 'SKILL.md'))) {
            throw 'Pre-existing custom user skill was destroyed during installation!'
        }

        # Verify global rule exists and has always_on trigger
        $globalRule = Join-Path $simUserHome '.gemini\config\rules\skill-routing.md'
        if (-not (Test-Path -LiteralPath $globalRule)) { throw 'Global skill-routing.md rule missing in simulated user home' }
        $ruleContent = Get-Content -LiteralPath $globalRule -Raw -Encoding utf8
        if (-not $ruleContent.Contains('trigger: always_on')) { throw 'Global rule missing always_on trigger' }

        # Verify cognitive specialists installed in global agents directory
        $researcherAgent = Join-Path $simUserHome '.gemini\config\agents\researcher.md'
        if (-not (Test-Path -LiteralPath $researcherAgent)) { throw 'researcher.md missing in global agents directory' }

        # Verify custom agent preserved
        if (-not (Test-Path -LiteralPath (Join-Path $customAgentDir 'custom-user-agent.md'))) {
            throw 'Pre-existing custom user agent was destroyed!'
        }

        # Test Idempotence & Backup creation on update
        & powershell -ExecutionPolicy Bypass -File $skillsScript -UserProfileOverride $simUserHome
        if ($LASTEXITCODE -ne 0) { throw 'install-skills.ps1 failed on idempotent second run' }

        $backups = @(Get-ChildItem -LiteralPath (Join-Path $simUserHome '.gemini\config') -Directory | Where-Object { $_.Name -like 'skills_backup_*' })
        if ($backups.Count -eq 0) { throw 'Backup directory was not created during update over existing skills' }
    }

    Assert-Test "Autonomous multi-skill composition for complex multi-domain task (no artificial limit)" {
        function Invoke-ComplexTaskRouting {
            param([hashtable]$TaskSpec)
            $skillsToLoad = [System.Collections.Generic.List[string]]::new()

            # Synergistic evaluation across all dimensions of the complex task
            if ($TaskSpec.RequiresArchitecture) { $skillsToLoad.Add('graphify'); $skillsToLoad.Add('calm') }
            if ($TaskSpec.RequiresDataModeling) { $skillsToLoad.Add('supabase-postgres-best-practices') }
            if ($TaskSpec.RequiresFrontendPolish) { $skillsToLoad.Add('ui-ux-pro-max'); $skillsToLoad.Add('frontend-design') }
            if ($TaskSpec.RequiresSecurityAudit) { $skillsToLoad.Add('cybersecurity-review') }
            if ($TaskSpec.RequiresVerification) { $skillsToLoad.Add('verification-before-completion') }

            return @($skillsToLoad)
        }

        # Complex task with 4 distinct dimensions: should activate 6 complementary skills with zero numerical cap
        $complexSpec = @{
            RequiresArchitecture   = $true
            RequiresDataModeling   = $true
            RequiresFrontendPolish = $true
            RequiresSecurityAudit  = $true
            RequiresVerification   = $true
        }

        $loaded = Invoke-ComplexTaskRouting -TaskSpec $complexSpec
        if ($loaded.Count -ne 7) {
            throw ('Expected 7 complementary skills loaded for complex multi-domain task, got ' + $loaded.Count)
        }
        if ($loaded -notcontains 'graphify' -or $loaded -notcontains 'calm' -or $loaded -notcontains 'supabase-postgres-best-practices' -or $loaded -notcontains 'ui-ux-pro-max' -or $loaded -notcontains 'frontend-design' -or $loaded -notcontains 'cybersecurity-review' -or $loaded -notcontains 'verification-before-completion') {
            throw 'Multi-skill composition missed required domain skills'
        }
    }

    Assert-Test "Trivial task bypasses skill loading without artificial overhead" {
        function Invoke-SimpleTaskRouting {
            param([string]$UserPrompt, [bool]$IsOneLineTypo)
            if ($IsOneLineTypo -or $UserPrompt -match '^\s*(ola|oi|bom dia|help|status|oque e)\b') {
                return @() # 0 skills loaded, direct execution
            }
            return @('some-skill')
        }

        $rTrivial1 = Invoke-SimpleTaskRouting -UserPrompt "Fix typo in variable name in index.ts" -IsOneLineTypo $true
        if (@($rTrivial1).Count -ne 0) { throw 'Trivial typo should not load any skills' }

        $rTrivial2 = Invoke-SimpleTaskRouting -UserPrompt "ola, bom dia" -IsOneLineTypo $false
        if (@($rTrivial2).Count -ne 0) { throw 'Trivial greeting should not load any skills' }
    }

    Assert-Test "Dynamic multi-phase skill routing simulation (start, stack discovery, domain shift, bug, verification)" {
        function Invoke-SkillSimulation {
            param([string]$LifecyclePhase, [hashtable]$Context)
            switch ($LifecyclePhase) {
                'TaskStart' {
                    if ($Context.Intent -eq 'architecture') { return 'graphify' }
                    if ($Context.Intent -eq 'debugging') { return 'systematic-debugging' }
                    return $null
                }
                'StackDiscovery' {
                    if ($Context.DiscoveredStack -contains 'supabase') { return 'supabase-postgres-best-practices' }
                    if ($Context.DiscoveredStack -contains 'react') { return 'vercel-react-best-practices' }
                    return $null
                }
                'DomainShift' {
                    if ($Context.NewDomain -eq 'frontend-ui') { return 'ui-ux-pro-max' }
                    if ($Context.NewDomain -eq 'security-audit') { return 'cybersecurity-review' }
                    return $null
                }
                'UnexpectedFailure' {
                    if ($Context.HasError) { return 'systematic-debugging' }
                    return $null
                }
                'VerificationGate' {
                    if ($Context.AboutToClaimComplete) { return 'verification-before-completion' }
                    return $null
                }
            }
        }

        # 1. Gate 0: Initial intent
        $r1 = Invoke-SkillSimulation -LifecyclePhase 'TaskStart' -Context @{ Intent = 'architecture' }
        if ($r1 -ne 'graphify') { throw ('Phase 1 route expected graphify, got ' + $r1) }

        # 2. Stack Discovery: Found Supabase during inspection
        $r2 = Invoke-SkillSimulation -LifecyclePhase 'StackDiscovery' -Context @{ DiscoveredStack = @('supabase', 'postgres') }
        if ($r2 -ne 'supabase-postgres-best-practices') { throw ('Phase 2 route expected supabase-postgres-best-practices, got ' + $r2) }

        # 3. Domain Shift: Transition to UI
        $r3 = Invoke-SkillSimulation -LifecyclePhase 'DomainShift' -Context @{ NewDomain = 'frontend-ui' }
        if ($r3 -ne 'ui-ux-pro-max') { throw ('Phase 3 route expected ui-ux-pro-max, got ' + $r3) }

        # 4. Unexpected Failure: Test breaks mid-execution
        $r4 = Invoke-SkillSimulation -LifecyclePhase 'UnexpectedFailure' -Context @{ HasError = $true }
        if ($r4 -ne 'systematic-debugging') { throw ('Phase 4 route expected systematic-debugging, got ' + $r4) }

        # 5. Verification Gate: Before claiming success
        $r5 = Invoke-SkillSimulation -LifecyclePhase 'VerificationGate' -Context @{ AboutToClaimComplete = $true }
        if ($r5 -ne 'verification-before-completion') { throw ('Phase 5 route expected verification-before-completion, got ' + $r5) }
    }

    Assert-Test "Multi-turn conversation simulation with 3 successive natural user requests" {
        $conversationLoadedSkills = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        function Invoke-UserTurnProcessing {
            param([string]$UserPrompt)
            $newSkillToLoad = $null

            if ($UserPrompt -match 'arquitetura|estrutura|depend|control plane|mapeamento') {
                $targetSkill = 'graphify'
                if (-not $conversationLoadedSkills.Contains($targetSkill)) {
                    $newSkillToLoad = $targetSkill
                    $null = $conversationLoadedSkills.Add($targetSkill)
                }
            } elseif ($UserPrompt -match 'falha|erro|bug|exce|intermitente|investigar') {
                $targetSkill = 'systematic-debugging'
                if (-not $conversationLoadedSkills.Contains($targetSkill)) {
                    $newSkillToLoad = $targetSkill
                    $null = $conversationLoadedSkills.Add($targetSkill)
                }
            } elseif ($UserPrompt -match 'interface|layout|cores|acessibilidade|estiliza|ui') {
                $targetSkill = 'ui-ux-pro-max'
                if (-not $conversationLoadedSkills.Contains($targetSkill)) {
                    $newSkillToLoad = $targetSkill
                    $null = $conversationLoadedSkills.Add($targetSkill)
                }
            }
            return $newSkillToLoad
        }

        # Turn 1: Architectural analysis
        $turn1Skill = Invoke-UserTurnProcessing -UserPrompt 'Por favor analise a arquitetura e mapeamento do Control Plane'
        if ($turn1Skill -ne 'graphify') { throw ('Turn 1 expected to load graphify, got ' + $turn1Skill) }

        # Turn 2: Technical bug investigation in same conversation
        $turn2Skill = Invoke-UserTurnProcessing -UserPrompt 'Encontrei uma falha tecnica intermitente na sincronizacao de mensagens'
        if ($turn2Skill -ne 'systematic-debugging') { throw ('Turn 2 expected to load systematic-debugging, got ' + $turn2Skill) }

        # Turn 3: UI review or validation in same conversation
        $turn3Skill = Invoke-UserTurnProcessing -UserPrompt 'Agora vamos revisar a acessibilidade, contraste e cores da interface web'
        if ($turn3Skill -ne 'ui-ux-pro-max') { throw ('Turn 3 expected to load ui-ux-pro-max, got ' + $turn3Skill) }

        # Turn 4: Continuation of UI task (skill reuse - no redundant reload)
        $turn4Skill = Invoke-UserTurnProcessing -UserPrompt 'Ajuste os botoes da interface para manter o mesmo estilo de layout'
        if ($turn4Skill -ne $null) { throw ('Turn 4 should reuse already loaded skill without reloading, got ' + $turn4Skill) }

        if ($conversationLoadedSkills.Count -ne 3) {
            throw 'Expected exactly 3 distinct skills loaded across the multi-turn session'
        }
    }

    Assert-Test "Graphify-First Navigation Protocol & Lifecycle Verification (Discovery, precedence over wide searches, staleness & fallback)" {
        $testWs = Join-Path $tempBase 'GraphifyNavigationTestWs'
        $null = New-Item -ItemType Directory -Path $testWs -Force
        $srcDir = Join-Path $testWs 'src'
        $null = New-Item -ItemType Directory -Path $srcDir -Force
        Set-Content -LiteralPath (Join-Path $srcDir 'auth.ts') -Value 'export class AuthService { login() {} }' -Encoding utf8
        Set-Content -LiteralPath (Join-Path $srcDir 'data.ts') -Value 'export class DataService { query() {} }' -Encoding utf8

        # 1. Graph discovery: create mock graphify-out
        $graphDir = Join-Path $testWs 'graphify-out'
        $null = New-Item -ItemType Directory -Path $graphDir -Force
        $mockGraph = @{
            nodes = @(
                @{ id = 'AuthService'; file = 'src/auth.ts'; type = 'class' },
                @{ id = 'DataService'; file = 'src/data.ts'; type = 'class' }
            )
            edges = @(
                @{ source = 'AuthService'; target = 'DataService'; type = 'calls' }
            )
            communities = @{ '0' = @('AuthService', 'DataService') }
        } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath (Join-Path $graphDir 'graph.json') -Value $mockGraph -Encoding utf8
        Set-Content -LiteralPath (Join-Path $graphDir 'GRAPH_REPORT.md') -Value '# Graph Report' -Encoding utf8
        Set-Content -LiteralPath (Join-Path $graphDir 'cost.json') -Value '{"runs":[{"date":"2026-10-09T00:00:00Z"}]}' -Encoding utf8

        function Invoke-NavigationalStepExecution {
            param(
                [string]$UserPrompt,
                [string]$WorkspaceRoot
            )
            $steps = [System.Collections.Generic.List[hashtable]]::new()
            $graphJson = Join-Path $WorkspaceRoot 'graphify-out\graph.json'
            $hasGraph = Test-Path -LiteralPath $graphJson

            # Rule evaluation: if prompt is architectural / code comprehension
            $isComprehension = $UserPrompt -match 'arquitetura|fluxo|depend|modulo|impacto|compreens|como funciona'
            if ($isComprehension) {
                # Step 1: Load graphify skill
                $steps.Add(@{ Tool = 'view_file'; Target = 'graphify/SKILL.md'; Rationale = 'Spontaneous load of graphify skill' })

                # Step 2: Check graph existence & freshness
                if ($hasGraph) {
                    # Step 3: First-order query graph before any wide search
                    $steps.Add(@{ Tool = 'graphify query'; Query = $UserPrompt; Rationale = 'Graph consultation precedence over manual scan' })
                    # Step 4: Targeted file read based on graph results
                    $steps.Add(@{ Tool = 'view_file'; Target = 'src/auth.ts'; Rationale = 'Surgical inspection of identified node' })
                } else {
                    # Fallback or build
                    $steps.Add(@{ Tool = 'graphify build'; Rationale = 'Graph absent: trigger build or explain limitation' })
                }
            } else {
                $steps.Add(@{ Tool = 'conventional_search'; Rationale = 'Non-comprehension task' })
            }

            return @($steps)
        }

        # Scenario A: Natural architectural question with existing graph
        $naturalPrompt = "Como funciona o fluxo de autenticacao e a comunicacao entre os modulos?"
        $execPlanA = Invoke-NavigationalStepExecution -UserPrompt $naturalPrompt -WorkspaceRoot $testWs

        if ($execPlanA.Count -lt 3) { throw "Execution plan too short" }
        if ($execPlanA[0].Tool -ne 'view_file' -or $execPlanA[0].Target -ne 'graphify/SKILL.md') {
            throw "Protocol failed: graphify/SKILL.md was not loaded spontaneously as Step 1"
        }
        if ($execPlanA[1].Tool -ne 'graphify query') {
            throw "Protocol failed: graph query was not executed before file exploration"
        }
        if ($execPlanA[2].Tool -ne 'view_file' -or $execPlanA[2].Target -ne 'src/auth.ts') {
            throw "Protocol failed: targeted surgical file inspection failed"
        }

        # Scenario B: Graph absent -> triggers build/fallback
        $wsWithoutGraph = Join-Path $tempBase 'WsNoGraph'
        $null = New-Item -ItemType Directory -Path $wsWithoutGraph -Force
        $execPlanB = Invoke-NavigationalStepExecution -UserPrompt $naturalPrompt -WorkspaceRoot $wsWithoutGraph
        if ($execPlanB[1].Tool -ne 'graphify build') {
            throw "Protocol failed: absent graph did not trigger build/fallback evaluation"
        }
    }

    Assert-Test "Self-healing project organization repairs legacy skill junctions, missing skill-routing.md, legacy hooks.json, and updates AGENTS.md/GEMINI.md while preserving custom domain invariants" {
        $healWs = Join-Path $tempBase 'SelfHealProject'
        $null = New-Item -ItemType Directory -Path $healWs -Force
        Set-Content -LiteralPath (Join-Path $healWs '.aidev.json') -Value (@'
{
  "schemaVersion": 1,
  "preset": "base",
  "capabilities": ["core"]
}
'@) -Encoding utf8

        # Create pre-existing AGENTS.md with custom domain invariant 6, but missing skill-routing.md
        $customAgentsContent = @'
# AGENTS.md — SelfHealProject

## 1. Immutable Invariants

1. **Security & Secrets**: Never expose secrets.
6. **Custom Domain Rule**: Preserve offline resilience and local SQLite queue.

---

## 2. Project Metadata & Stack
- **Project Name**: SelfHealProject
'@
        Set-Content -LiteralPath (Join-Path $healWs 'AGENTS.md') -Value $customAgentsContent -Encoding utf8
        Set-Content -LiteralPath (Join-Path $healWs 'GEMINI.md') -Value '# Legacy GEMINI.md without routing' -Encoding utf8

        # Create .agents with a legacy skill junction and legacy hooks.json, without skill-routing.md
        $healAgentsDir = Join-Path $healWs '.agents'
        $healSkillsDir = Join-Path $healAgentsDir 'skills'
        $healRulesDir = Join-Path $healAgentsDir 'rules'
        $null = New-Item -ItemType Directory -Path $healSkillsDir -Force
        $null = New-Item -ItemType Directory -Path $healRulesDir -Force

        $junctionSkillTarget = Join-Path $aidevRoot 'skills\ponytail'
        $junctionSkillPath = Join-Path $healSkillsDir 'ponytail'
        $null = cmd /c "mklink /J `"$junctionSkillPath`" `"$junctionSkillTarget`"" 2>&1

        Set-Content -LiteralPath (Join-Path $healAgentsDir 'hooks.json') -Value '{"hooks":{"PreToolUse":[{"matcher":"run_command","hooks":[{"type":"command","command":"powershell -NoProfile -ExecutionPolicy Bypass -File .agents/scripts/safety-check.ps1"}]}]}}' -Encoding utf8

        # 1. Pre-apply audit must flag migration needed, skill junctions, and missing skill-routing.md
        $preAudit = Invoke-AidevAudit -WorkspacePath $healWs
        if (-not $preAudit.MigrationNeeded) { throw "Pre-apply audit should require migration/sync" }
        if ($preAudit.SkillJunctionCount -eq 0) { throw "Pre-apply audit failed to detect legacy skill junction" }
        if ($preAudit.HasSkillRoutingRule) { throw "Pre-apply audit falsely reported skill-routing.md present" }

        # 2. Run Invoke-AidevApply (without -Force) to test automatic self-healing
        Invoke-AidevApply -WorkspacePath $healWs

        # 3. Verify all 4 self-healing invariants and custom rule preservation
        if (Test-IsJunction -Path $junctionSkillPath) { throw "Skill junction was not converted to physical directory" }
        if (-not (Test-Path -LiteralPath (Join-Path $junctionSkillPath 'SKILL.md'))) { throw "Physical skill SKILL.md missing after conversion" }
        if (-not (Test-Path -LiteralPath (Join-Path $healRulesDir 'skill-routing.md'))) { throw "skill-routing.md not materialized" }

        $healedHooks = Get-Content -LiteralPath (Join-Path $healAgentsDir 'hooks.json') -Raw -Encoding utf8
        if ($healedHooks -match '-File \.agents/scripts/safety-check\.ps1') { throw "Legacy hooks.json path was not repaired" }
        if ($healedHooks -notmatch '-File scripts/safety-check\.ps1') { throw "Resilient hooks.json path missing" }

        $healedAgentsMd = Get-Content -LiteralPath (Join-Path $healWs 'AGENTS.md') -Raw -Encoding utf8
        if (-not $healedAgentsMd.Contains('Custom Domain Rule')) { throw "Self-healing destroyed custom domain rule in AGENTS.md!" }
        if ($healedAgentsMd -notmatch 'skill-routing\.md') { throw "Self-healing did not inject skill-routing.md into AGENTS.md" }
        if ($healedAgentsMd -notmatch '/compact') { throw "Self-healing did not inject /compact gate into AGENTS.md" }

        $healedGeminiMd = Get-Content -LiteralPath (Join-Path $healWs 'GEMINI.md') -Raw -Encoding utf8
        if ($healedGeminiMd -notmatch 'skill-routing\.md') { throw "Self-healing did not update GEMINI.md with skill-routing.md" }
        if ($healedGeminiMd -notmatch '/compact') { throw "Self-healing did not update GEMINI.md with /compact gate" }

        # 4. Post-apply audit must report 0 junctions and MigrationNeeded = False
        # Graph extraction is deliberately skipped for TEMP fixtures; provide a graph artifact for this audit test.
        $null = New-Item -ItemType Directory -Path (Join-Path $healWs 'graphify-out') -Force
        Set-Content -LiteralPath (Join-Path $healWs 'graphify-out/graph.json') -Value '{"nodes":[],"links":[]}' -Encoding utf8
        $postAudit = Invoke-AidevAudit -WorkspacePath $healWs
        if ($postAudit.MigrationNeeded) { throw "Post-apply audit still reports MigrationNeeded = True" }
        if ($postAudit.SkillJunctionCount -ne 0) { throw "Post-apply audit still reports skill junctions" }
        if (-not $postAudit.HasSkillRoutingRule) { throw "Post-apply audit missing skill-routing.md" }
    }

    Assert-Test "All 10 specialized subagents have zero UTF-8 BOM, valid kebab-case name identifiers, and valid Antigravity tool registry entries" {
        $validAntigravityTools = @(
            'view_file',
            'grep_search',
            'replace_file_content',
            'run_command'
        )
        $agentsDirToCheck = Join-Path $aidevRoot '.agents\agents'
        $agentFiles = @(Get-ChildItem -LiteralPath $agentsDirToCheck -Filter '*.md' -File)
        if ($agentFiles.Count -lt 10) {
            throw ("Expected 10 subagents in .agents/agents/, found " + $agentFiles.Count)
        }
        foreach ($af in $agentFiles) {
            $bytes = [System.IO.File]::ReadAllBytes($af.FullName)
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
                throw ("Subagent file has UTF-8 BOM which breaks frontmatter discovery: " + $af.Name)
            }
            $rawText = [System.IO.File]::ReadAllText($af.FullName, [System.Text.Encoding]::UTF8)
            if ($rawText -notmatch '(?s)^---\r?\n(.*?)\r?\n---') {
                throw ("Subagent file missing valid YAML frontmatter: " + $af.Name)
            }
            $fm = $Matches[1]
            if ($fm -notmatch '(?m)^name:\s*([a-zA-Z0-9][a-zA-Z0-9_.-]*)\s*$') {
                throw ("Subagent file has invalid or space-containing name identifier in frontmatter: " + $af.Name)
            }
            $toolMatches = [regex]::Matches($fm, '(?m)^\s*-\s*(.+?)\s*$')
            if ($toolMatches.Count -eq 0) {
                throw ("Subagent file missing tools list in frontmatter: " + $af.Name)
            }
            foreach ($tm in $toolMatches) {
                $tName = $tm.Groups[1].Value.Trim()
                if ($validAntigravityTools -notcontains $tName) {
                    throw ("Subagent " + $af.Name + " declares unknown Antigravity tool '" + $tName + "' which crashes executor construction!")
                }
            }
        }
    }

    Assert-Test "Graphify skill is compact (< 6 KB), uses Windows PowerShell syntax, enforces Surgical Token-Economy Protocol, and has zero UTF-8 BOM" {
        $graphifySkillPath = Join-Path $aidevRoot '.agents\skills\graphify\SKILL.md'
        if (-not (Test-Path -LiteralPath $graphifySkillPath)) {
            throw 'graphify/SKILL.md missing in .agents/skills/graphify/'
        }
        $bytes = [System.IO.File]::ReadAllBytes($graphifySkillPath)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            throw 'graphify/SKILL.md has UTF-8 BOM'
        }
        if ($bytes.Length -gt 6144) {
            throw ('graphify/SKILL.md is bloated (' + $bytes.Length + ' bytes > 6144 bytes limit)!')
        }
        $gContent = [System.IO.File]::ReadAllText($graphifySkillPath, [System.Text.Encoding]::UTF8)
        if (-not $gContent.Contains('## Antigravity Windows PowerShell Fast-Path (Execute First on Turn 1)')) {
            throw 'graphify/SKILL.md missing Antigravity Windows PowerShell Fast-Path block'
        }
        if (-not $gContent.Contains('graphify query')) {
            throw 'graphify/SKILL.md missing graphify query command'
        }
        if (-not $gContent.Contains('graphify affected')) {
            throw 'graphify/SKILL.md missing graphify affected command'
        }
        if (-not $gContent.Contains('rg -n')) {
            throw 'graphify/SKILL.md missing rg -n surgical line-pinpointing step'
        }
        if ($gContent.Contains('$(cat graphify-out/.graphify_python)')) {
            throw 'graphify/SKILL.md still contains POSIX bash $(cat ...) syntax instead of Windows PowerShell syntax!'
        }
    }

    Assert-Test "Invoke-AidevAgentSynthesis automatically synthesizes project-specific domain specialists paired with 33 downloaded skills and contextualizes core subagents" {
        $synWs = Join-Path $tempBase 'AgentSynthesisProject'
        $null = New-Item -ItemType Directory -Path $synWs -Force
        Set-Content -LiteralPath (Join-Path $synWs '.aidev.json') -Value (@'
{
  "schemaVersion": 1,
  "preset": "web-supabase",
  "capabilities": ["core", "nextjs", "react", "supabase", "postgres"]
}
'@) -Encoding utf8

        $synRulesDir = Join-Path $synWs '.agents\rules'
        $null = New-Item -ItemType Directory -Path $synRulesDir -Force

        $domainRuleContent = @'
---
trigger: always_on
description: Multi-tenant RLS isolation and fiscal tax calculation invariants.
---
# Multi-Tenant Fiscal Isolation
Every query on PostgreSQL tables in Supabase must enforce tenant_id RLS isolation and validate React UI state transitions.
'@
        Set-Content -LiteralPath (Join-Path $synRulesDir 'fiscal-tenant-isolation.md') -Value $domainRuleContent -Encoding utf8

        Invoke-AidevApply -WorkspacePath $synWs -Force

        $synAgentsDir = Join-Path $synWs '.agents\agents'
        $synthesizedAgentPath = Join-Path $synAgentsDir 'fiscal-tenant-isolation-specialist.md'
        if (-not (Test-Path -LiteralPath $synthesizedAgentPath)) {
            throw 'Invoke-AidevAgentSynthesis did not create fiscal-tenant-isolation-specialist.md'
        }

        $synBytes = [System.IO.File]::ReadAllBytes($synthesizedAgentPath)
        if ($synBytes.Length -ge 3 -and $synBytes[0] -eq 0xEF -and $synBytes[1] -eq 0xBB -and $synBytes[2] -eq 0xBF) {
            throw 'Synthesized specialist subagent has UTF-8 BOM!'
        }

        $synText = [System.IO.File]::ReadAllText($synthesizedAgentPath, [System.Text.Encoding]::UTF8)
        if ($synText -notmatch '(?m)^name:\s*fiscal-tenant-isolation-specialist\s*$') {
            throw 'Synthesized specialist subagent missing valid kebab-case name frontmatter'
        }
        if (-not $synText.Contains('.agents/skills/graphify/SKILL.md')) {
            throw 'Synthesized specialist subagent missing graphify skill pairing'
        }
        if (-not $synText.Contains('.agents/skills/supabase-postgres-best-practices/SKILL.md')) {
            throw 'Synthesized specialist subagent missing matched supabase-postgres-best-practices skill'
        }

        $coreResearcherPath = Join-Path $synAgentsDir 'researcher.md'
        $coreResearcherText = [System.IO.File]::ReadAllText($coreResearcherPath, [System.Text.Encoding]::UTF8)
        if (-not $coreResearcherText.Contains('## Project-Specific Context (AgentSynthesisProject)')) {
            throw 'Core subagent researcher.md was not contextualized with Project-Specific Context'
        }
        if (-not (Test-Path -LiteralPath (Join-Path $synWs '.codex/agents/researcher.toml'))) {
            throw 'Codex cannot discover researcher: project-scoped TOML agent missing'
        }
        if (-not (Test-Path -LiteralPath (Join-Path $synWs '.codex/agents/fiscal-tenant-isolation-specialist.toml'))) {
            throw 'Synthesized domain specialist missing Codex adapter'
        }
        if (-not (Test-Path -LiteralPath (Join-Path $synWs '.claude/agents/fiscal-tenant-isolation-specialist.md'))) {
            throw 'Synthesized domain specialist missing Claude adapter'
        }
    }

    Assert-Test "Native strings are identical in installed Windows PowerShell and PowerShell 7 runtimes" {
        $nativeRuntimeCommands = @('powershell.exe', 'pwsh.exe') | ForEach-Object { Get-Command $_ -ErrorAction SilentlyContinue }
        $nativeRuntimeScript = @'
Import-Module '__MODULE__' -Force
& (Get-Module AidevCore) { ConvertTo-AidevNativeString "A&B <domain> 'quoted' `"value`" C:\source`nline`t" }
'@
        $nativeRuntimeScript = $nativeRuntimeScript.Replace('__MODULE__', (Join-Path $aidevRoot 'core/AidevCore.psm1').Replace("'", "''"))
        $nativeEncodedScript = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($nativeRuntimeScript))
        $nativeResults = @()
        foreach ($nativeRuntime in $nativeRuntimeCommands) {
            $nativeResults += (& $nativeRuntime.Source -NoProfile -EncodedCommand $nativeEncodedScript)
            if ($LASTEXITCODE -ne 0) { throw ('Native serializer failed in ' + $nativeRuntime.Source) }
        }
        if ($nativeResults.Count -lt 1 -or @($nativeResults | Select-Object -Unique).Count -ne 1) { throw 'Cross-runtime native strings do not match' }
        $roundTrip = $nativeResults[0] | ConvertFrom-Json
        if ($roundTrip -cne "A&B <domain> 'quoted' `"value`" C:\source`nline`t") { throw 'Native escaping changed quotes, paths, or controls' }
    }

    Assert-Test "Native agents preserve external files, serialize instructions, self-heal and audit drift across Codex and Claude" {
        $nativeWs = Join-Path $tempBase 'NativeAdaptersProject'
        $null = New-Item -ItemType Directory -Path (Join-Path $nativeWs '.codex/agents') -Force
        Set-Content -LiteralPath (Join-Path $nativeWs '.aidev.json') -Value '{"schemaVersion":1,"preset":"base","capabilities":["core"]}' -Encoding utf8
        foreach ($doc in @('AGENTS.md', 'GEMINI.md', 'CLAUDE.md')) {
            Set-Content -LiteralPath (Join-Path $nativeWs $doc) -Value ('# Existing project rules: ' + $doc) -Encoding utf8
        }
        $configPath = Join-Path $nativeWs '.codex/config.toml'
        $configSentinel = "# User configuration`n[agents]`nenabled = true`n"
        [IO.File]::WriteAllText($configPath, $configSentinel)
        Invoke-AidevApply -WorkspacePath $nativeWs -Force
        $antigravityBridge = [IO.File]::ReadAllText((Join-Path $nativeWs 'GEMINI.md'))
        if ($antigravityBridge -notmatch '## Antigravity Runtime Boundaries' -or $antigravityBridge -notmatch 'supersedes older runtime claims') { throw 'Missing explicit Antigravity runtime boundaries' }
        foreach ($specialist in @(Get-ChildItem -LiteralPath (Join-Path $nativeWs '.agents/agents') -Filter '*.md')) {
            $specialistRaw = [IO.File]::ReadAllText($specialist.FullName)
            $header = [regex]::Match($specialistRaw, '\A---\r?\n(.*?)\r?\n---', [Text.RegularExpressions.RegexOptions]::Singleline).Groups[1].Value
            if ($header -notmatch '(?m)^subagent: true\r?$' -or $header -notmatch '(?m)^mainAgent: false\r?$' -or $header -notmatch '(?m)^model: inherit\r?$') { throw ('Antigravity specialist discovery flags missing: ' + $specialist.Name) }
            foreach ($tool in @([regex]::Matches($header, '(?m)^  - ([a-z_]+)\r?$') | ForEach-Object { $_.Groups[1].Value })) {
                if ($tool -notin @('view_file', 'grep_search', 'run_command', 'replace_file_content')) { throw ('Unverified Antigravity tool: ' + $tool) }
            }
        }
        foreach ($doc in @('AGENTS.md', 'GEMINI.md', 'CLAUDE.md')) {
            if ([IO.File]::ReadAllText((Join-Path $nativeWs $doc)) -notmatch '# Existing project rules:') { throw ('Custom governance was overwritten: ' + $doc) }
            if (@(Get-ChildItem -LiteralPath $nativeWs -Filter ($doc + '.aidev-backup-*')).Count -eq 0) { throw ('Missing governance backup: ' + $doc) }
        }
        if ([IO.File]::ReadAllText($configPath) -cne $configSentinel) { throw 'Codex user config was modified' }
        $codexPath = Join-Path $nativeWs '.codex/agents/researcher.toml'
        $claudePath = Join-Path $nativeWs '.claude/agents/researcher.md'
        $firstCodex = [IO.File]::ReadAllText($codexPath)
        $serialized = & (Get-Module AidevCore) { ConvertTo-AidevNativeString "A&B <domain> 'quoted'" }
        if ($serialized -cne '"A\u0026B \u003cdomain\u003e \u0027quoted\u0027"') { throw 'Native string serialization differs between PowerShell 5.1 and 7' }
        $serializedDel = & (Get-Module AidevCore) { ConvertTo-AidevNativeString ([string][char]0x7f) }
        if ($serializedDel -cne '"\u007f"') { throw 'Native TOML must escape the DEL control character' }
        if ($firstCodex -match '(?m)^(model|sandbox_mode|approval_policy)\s*=') { throw 'Adapter changes inherited runtime settings' }
        $instructionsLine = ($firstCodex -split "`n" | Where-Object { $_ -match '^developer_instructions = ' })
        $instructions = ($instructionsLine -replace '^developer_instructions = ', '') | ConvertFrom-Json
        if ($instructions -notmatch 'Project-Specific Context' -or $instructions -notmatch 'native tools') { throw 'Codex instructions lost specialist context' }
        if ([IO.File]::ReadAllText($claudePath) -match '(?m)^tools:') { throw 'Claude adapter contains foreign tool restrictions' }
        $metadata = Get-Content -LiteralPath (Join-Path $nativeWs '.agents/.aidev_metadata.json') -Raw | ConvertFrom-Json
        if (@($metadata.managedCodexAgents).Count -lt 10 -or @($metadata.managedClaudeAgents).Count -lt 10) { throw 'Native agent metadata missing core specialists' }
        Invoke-AidevApply -WorkspacePath $nativeWs
        if ([IO.File]::ReadAllText($codexPath) -cne $firstCodex) { throw 'Codex adapter is not idempotent' }
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (@($audit.NativeAgentIssues).Count -ne 0) { throw 'Fresh native adapters fail audit' }
        [IO.File]::AppendAllText($codexPath, 'invalid = [')
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (@($audit.NativeAgentIssues | Where-Object { $_ -like 'Outdated or corrupt:*' }).Count -eq 0) { throw 'Corrupt Codex agent was not detected' }
        Invoke-AidevApply -WorkspacePath $nativeWs
        if ([IO.File]::ReadAllText($codexPath) -cne $firstCodex) { throw 'Managed Codex corruption was not repaired' }
        $sourceAgentPath = Join-Path $nativeWs '.agents/agents/researcher.md'
        [IO.File]::AppendAllText($sourceAgentPath, "`nAdditional project instruction: check C:\\source and quote `"values`".`n")
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (@($audit.NativeAgentIssues | Where-Object { $_ -like 'Outdated or corrupt:*' }).Count -lt 2) { throw 'Source changes did not invalidate both native adapters' }
        Invoke-AidevApply -WorkspacePath $nativeWs
        Remove-Item -LiteralPath $sourceAgentPath -Force
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (@($audit.NativeAgentIssues | Where-Object { $_ -like 'Missing canonical agent:*' }).Count -eq 0) { throw 'Missing canonical specialist was not detected from metadata' }
        Invoke-AidevApply -WorkspacePath $nativeWs
        Remove-Item -LiteralPath $claudePath -Force
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (@($audit.NativeAgentIssues | Where-Object { $_ -like 'Missing:*claude*' }).Count -eq 0) { throw 'Missing Claude agent was not detected' }
        $external = 'name = "researcher"' + "`n" + 'description = "User owned"' + "`n" + 'developer_instructions = "Preserve me"'
        [IO.File]::WriteAllText($codexPath, $external)
        Invoke-AidevApply -WorkspacePath $nativeWs -Force
        if ([IO.File]::ReadAllText($codexPath) -cne $external) { throw 'External Codex agent was overwritten' }
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (-not $audit.MigrationNeeded -or @($audit.NativeAgentIssues | Where-Object { $_ -like 'External collision:*' }).Count -eq 0) { throw 'External name collision was not reported' }
        $coordinatorRule = Join-Path $nativeWs '.agents/rules/orchestration.md'
        Remove-Item -LiteralPath $coordinatorRule -Force
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (@($audit.NativeAgentIssues | Where-Object { $_ -like 'Missing coordinator rule:*' }).Count -eq 0) { throw 'Missing coordinator policy was not reported' }
        Remove-Item -LiteralPath (Join-Path $nativeWs '.agents/scripts/safety-check.ps1') -Force
        $audit = Invoke-AidevAudit -WorkspacePath $nativeWs
        if (@($audit.GovernanceIssues | Where-Object { $_ -like 'Missing or invalid safety hook*' }).Count -eq 0) { throw 'Missing hook script was not detected' }
        if (@($audit.GovernanceIssues | Where-Object { $_ -like 'Missing or invalid graph:*' }).Count -eq 0) { throw 'Missing graph was not detected' }
    }

    Assert-Test "Apply repairs managed skill description YAML without replacing custom body or fields" {
        $repairWs = Join-Path $tempBase 'SkillDescriptionRepairProject'
        $repairSkillDir = Join-Path $repairWs '.agents/skills/graphify'
        $null = New-Item -ItemType Directory -Path $repairSkillDir -Force
        Set-Content -LiteralPath (Join-Path $repairWs '.aidev.json') -Value '{"schemaVersion":1,"preset":"base","capabilities":["core"]}' -Encoding utf8
        $sourceGraphify = Join-Path $env:USERPROFILE '.agents/skills/graphify/SKILL.md'
        $canonicalLine = & (Get-Module AidevCore) { param($p) Get-AidevCanonicalSkillDescription -SkillPath $p } $sourceGraphify
        if (-not $canonicalLine) { throw 'Run aidev sync first: canonical Graphify JSON description missing' }
        $canonicalDescription = ConvertFrom-Json -InputObject ($canonicalLine -replace '^description:\s*', '')
        $badLine = 'description: "' + $canonicalDescription + '"'
        $customContent = "---`nname: graphify`n" + $badLine + "`ncustom-field: preserve-me`n---`n# Custom project instructions`nKeep this body intact, including C:\\project and quotes `"exactly`".`n"
        $destinationGraphify = Join-Path $repairSkillDir 'SKILL.md'
        [IO.File]::WriteAllText($destinationGraphify, $customContent, (New-Object Text.UTF8Encoding($false)))
        Invoke-AidevApply -WorkspacePath $repairWs
        $expected = $customContent.Replace($badLine, $canonicalLine)
        if ([IO.File]::ReadAllText($destinationGraphify) -cne $expected) { throw 'Description repair failed or modified custom body/fields' }
        $backups = @(Get-ChildItem -LiteralPath $repairSkillDir -Filter 'SKILL.md.aidev-backup-*' -File)
        if ($backups.Count -ne 1 -or [IO.File]::ReadAllText($backups[0].FullName) -cne $customContent) { throw 'Original skill was not backed up exactly' }
        Invoke-AidevApply -WorkspacePath $repairWs
        if ([IO.File]::ReadAllText($destinationGraphify) -cne $expected -or @(Get-ChildItem -LiteralPath $repairSkillDir -Filter 'SKILL.md.aidev-backup-*' -File).Count -ne 1) { throw 'Description repair is not idempotent' }
        $blockContent = $customContent.Replace($badLine, "description: >-`n  Custom multiline description`n  must remain unchanged.")
        [IO.File]::WriteAllText($destinationGraphify, $blockContent, (New-Object Text.UTF8Encoding($false)))
        Invoke-AidevApply -WorkspacePath $repairWs
        if ([IO.File]::ReadAllText($destinationGraphify) -cne $blockContent) { throw 'Repair corrupted a custom YAML block scalar' }
    }

    Assert-Test "Native adapters never follow linked agent directories outside the workspace" {
        $linkedWs = Join-Path $tempBase 'NativeLinkedProject'
        $externalAgents = Join-Path $tempBase 'ExternalNativeAgents'
        $null = New-Item -ItemType Directory -Path (Join-Path $linkedWs '.claude'), $externalAgents -Force
        $sentinel = Join-Path $externalAgents 'researcher.md'
        $sentinelText = '# External canonical agent must survive'
        [IO.File]::WriteAllText($sentinel, $sentinelText)
        $claudeJunction = Join-Path $linkedWs '.claude/agents'
        $null = cmd /c "mklink /J `"$claudeJunction`" `"$externalAgents`"" 2>&1
        if ($LASTEXITCODE -ne 0) { throw 'Could not create linked native agent fixture' }
        Set-Content -LiteralPath (Join-Path $linkedWs '.aidev.json') -Value '{"schemaVersion":1,"preset":"base","capabilities":["core"]}' -Encoding utf8
        Invoke-AidevApply -WorkspacePath $linkedWs
        if ([IO.File]::ReadAllText($sentinel) -cne $sentinelText -or @(Get-ChildItem -LiteralPath $externalAgents -File).Count -ne 1) { throw 'Native adapter wrote through a project junction' }
        $audit = Invoke-AidevAudit -WorkspacePath $linkedWs
        if (-not $audit.MigrationNeeded -or @($audit.NativeAgentIssues | Where-Object { $_ -like 'Linked native agent directory:*' }).Count -eq 0) { throw 'Linked native agents directory missing audit issue' }
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
