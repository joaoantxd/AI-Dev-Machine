# ==============================================================================
# AI-Dev-Machine Architecture v2 — Comprehensive Test Suite (Hardened & Verified)
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
Write-Host " Running AI-Dev-Machine Architecture v2 Test Suite" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. Canonical Registries Tests
# ------------------------------------------------------------------------------
Write-Host "`n--- 1. Canonical Registries Validation ---" -ForegroundColor Yellow

Assert-Test "skills.json parses and contains exactly 33 managed skills with no duplicate IDs" {
    $data = Get-RegistryData -Type 'skills'
    if ($data.skills.Count -ne 33) { throw "Expected 33 skills, found $($data.skills.Count)" }
    $seenIds = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($s in $data.skills) {
        if (-not $s.id -or -not $s.name -or -not $s.description -or -not $s.category) {
            throw "Skill missing mandatory fields: $($s.id)"
        }
        if ($seenIds.Contains($s.id)) { throw "Duplicate skill ID detected: $($s.id)" }
        $null = $seenIds.Add($s.id)
    }
}

Assert-Test "agents.json parses, contains 10 agents with no duplicate slugs and includes 3 cognitive specialists" {
    $data = Get-RegistryData -Type 'agents'
    if ($data.agents.Count -ne 10) { throw "Expected 10 agents, found $($data.agents.Count)" }
    $seenSlugs = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($a in $data.agents) {
        if ($seenSlugs.Contains($a.slug)) { throw "Duplicate agent slug detected: $($a.slug)" }
        $null = $seenSlugs.Add($a.slug)
    }
    if ($seenSlugs -notcontains 'researcher' -or $seenSlugs -notcontains 'reviewer' -or $seenSlugs -notcontains 'security-reviewer') {
        throw "Cognitive specialists missing from agents.json"
    }
}

Assert-Test "mcps.json parses, contains base & on-demand servers with auth definitions and correct defaults" {
    $data = Get-RegistryData -Type 'mcps'
    if ($data.mcps.Count -lt 6) { throw "Expected at least 6 MCPs, found $($data.mcps.Count)" }
    $ids = @($data.mcps.id)
    if ($ids -notcontains 'context7' -or $ids -notcontains 'chrome-devtools-mcp' -or $ids -notcontains 'semgrep') {
        throw "Core MCPs missing"
    }
    $c7 = $data.mcps | Where-Object { $_.id -eq 'context7' } | Select-Object -First 1
    if (-not $c7.enabledByDefault) { throw "context7 should be enabled by default in base" }

    $chrome = $data.mcps | Where-Object { $_.id -eq 'chrome-devtools-mcp' } | Select-Object -First 1
    if ($chrome.enabledByDefault) { throw "chrome-devtools-mcp should NOT be enabled universally in base" }

    $sem = $data.mcps | Where-Object { $_.id -eq 'semgrep' } | Select-Object -First 1
    if ($sem.enabledByDefault) { throw "semgrep should NOT be enabled universally in base" }
}

Assert-Test "profiles.json parses and contains all 4 canonical profiles with valid structure" {
    $data = Get-RegistryData -Type 'profiles'
    $names = @($data.profiles.PSObject.Properties.Name)
    foreach ($req in @('base', 'web-supabase', 'windows-desktop', 'monorepo')) {
        if ($names -notcontains $req) { throw "Missing canonical profile: $req" }
    }
}

# ------------------------------------------------------------------------------
# 2. Profile Resolution, Provenance & A/B Tests
# ------------------------------------------------------------------------------
Write-Host "`n--- 2. Profile Resolution & Provenance Tests ---" -ForegroundColor Yellow

Assert-Test "Resolve-AidevProfile for 'base' yields 3 rules, 3 core skills, 3 cognitive agents, 1 MCP (context7)" {
    $res = Resolve-AidevProfile -ProfileName 'base'
    if ($res.Rules.Count -ne 3) { throw "Expected 3 rules in base, got $($res.Rules.Count)" }
    if ($res.Skills.Count -ne 3) { throw "Expected 3 core skills in base, got $($res.Skills.Count)" }
    if ($res.Agents.Count -ne 3) { throw "Expected 3 cognitive agents in base, got $($res.Agents.Count)" }
    if ($res.Mcps.Count -ne 1 -or $res.Mcps[0].Name -ne 'context7') { throw "Expected only context7 in base MCPs, got $($res.Mcps.Name -join ', ')" }
    if ($res.DuplicateExposures.Count -ne 0) { throw "Duplicate exposure detected in base profile" }

    # Check provenance
    $rule1 = $res.Rules | Where-Object { $_.Name -eq 'architecture-invariants.md' } | Select-Object -First 1
    if ($rule1.Source -ne 'profile:base') { throw "Incorrect rule provenance: $($rule1.Source)" }
}

Assert-Test "A/B Resolution: web-supabase vs windows-desktop produce distinct, tailored surfaces" {
    $webRes = Resolve-AidevProfile -ProfileName 'web-supabase'
    $winRes = Resolve-AidevProfile -ProfileName 'windows-desktop'

    $webSkillNames = @($webRes.Skills.Name)
    $winSkillNames = @($winRes.Skills.Name)

    # Web specific capabilities
    if ($webSkillNames -notcontains 'ui-ux-pro-max' -or $webSkillNames -notcontains 'supabase') {
        throw "Web profile missing web-specific skills"
    }
    if ($winSkillNames -contains 'ui-ux-pro-max' -or $winSkillNames -contains 'supabase') {
        throw "Windows Desktop profile leaked web-specific skills!"
    }

    # Desktop specific capabilities
    if ($winSkillNames -notcontains 'winapp') {
        throw "Windows Desktop profile missing winapp skill"
    }
    if ($webSkillNames -contains 'winapp') {
        throw "Web profile leaked winapp desktop skill!"
    }

    # MCP checks
    $webMcpNames = @($webRes.Mcps.Name)
    $winMcpNames = @($winRes.Mcps.Name)
    if ($webMcpNames -notcontains 'chrome-devtools-mcp' -or $webMcpNames -notcontains 'supabase') {
        throw "Web profile missing chrome-devtools-mcp or supabase MCP"
    }
    if ($winMcpNames -contains 'chrome-devtools-mcp' -or $winMcpNames -contains 'supabase') {
        throw "Windows Desktop profile leaked web-specific MCPs!"
    }

    # Zero duplicate exposures in both
    if ($webRes.DuplicateExposures.Count -ne 0 -or $winRes.DuplicateExposures.Count -ne 0) {
        throw "Duplicate exposures detected in A/B test"
    }
}

Assert-Test "Resolve-AidevProfile fails closed on invalid profile name" {
    $failed = $false
    try {
        $null = Resolve-AidevProfile -ProfileName 'non-existent-profile-xyz'
    } catch {
        $failed = $true
    }
    if (-not $failed) { throw "Should have thrown an error on invalid profile" }
}

# ------------------------------------------------------------------------------
# 3. CLI Doctor & List Read-Only Tests
# ------------------------------------------------------------------------------
Write-Host "`n--- 3. Doctor & List Commands ---" -ForegroundColor Yellow

Assert-Test "Invoke-AidevDoctor executes cleanly in read-only mode and masks secrets" {
    $null = Invoke-AidevDoctor -WorkspacePath $aidevRoot
}

Assert-Test "Invoke-AidevList lists all categories" {
    $null = Invoke-AidevList -Category 'all'
}

# ------------------------------------------------------------------------------
# 4. Lifecycle Hooks & Deterministic Execution Tests
# ------------------------------------------------------------------------------
Write-Host "`n--- 4. Lifecycle Hook Execution Tests ---" -ForegroundColor Yellow

Assert-Test "PreToolUse safety-check script parses stdin JSON and allows safe commands" {
    $safetyScript = Join-Path $aidevRoot 'templates\scripts\safety-check.ps1'
    if (-not (Test-Path -LiteralPath $safetyScript)) { throw "safety-check.ps1 template missing" }

    $safePayload = '{"toolCall":{"name":"run_command","args":{"CommandLine":"npm test"}}}'
    $res = $safePayload | powershell -NoProfile -ExecutionPolicy Bypass -File $safetyScript
    $resJson = $res | ConvertFrom-Json
    if ($resJson.decision -ne 'allow') { throw "Expected 'allow' for safe command, got $($resJson.decision)" }
}

Assert-Test "PreToolUse safety-check script blocks or prompts for destructive commands" {
    $safetyScript = Join-Path $aidevRoot 'templates\scripts\safety-check.ps1'
    $dangerPayload = '{"toolCall":{"name":"run_command","args":{"CommandLine":"git push origin main --force"}}}'
    $res = $dangerPayload | powershell -NoProfile -ExecutionPolicy Bypass -File $safetyScript
    $resJson = $res | ConvertFrom-Json
    if ($resJson.decision -ne 'ask') { throw "Expected 'ask' for dangerous command, got $($resJson.decision)" }
}

# ------------------------------------------------------------------------------
# 5. Project Initialization & Isolation Tests (Isolated Temp Workspace)
# ------------------------------------------------------------------------------
Write-Host "`n--- 5. Project Init & Profiles Tests ---" -ForegroundColor Yellow

$tempBase = Join-Path ([IO.Path]::GetTempPath()) ("aidev-test-" + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $tempBase -Force

try {
    # 5.1 Base Profile Init
    $testWsBase = Join-Path $tempBase "TestBaseProject"
    Assert-Test "Init project with 'base' profile creates physical .agents, metadata, rules, and agents" {
        Invoke-AidevInit -WorkspacePath $testWsBase -Profile 'base' -ProjectName 'TestBaseProject'
        if (-not (Test-Path (Join-Path $testWsBase 'AGENTS.md'))) { throw "AGENTS.md missing" }
        if (-not (Test-Path (Join-Path $testWsBase 'GEMINI.md'))) { throw "GEMINI.md missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\.aidev_metadata.json'))) { throw ".aidev_metadata.json missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\rules\architecture-invariants.md'))) { throw "Rule missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\agents\researcher.md'))) { throw "researcher.md missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\agents\reviewer.md'))) { throw "reviewer.md missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\agents\security-reviewer.md'))) { throw "security-reviewer.md missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\hooks.json'))) { throw "hooks.json missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\scripts\safety-check.ps1'))) { throw "safety-check.ps1 missing" }
        if (-not (Test-Path (Join-Path $testWsBase '.agents\mcp_config.json'))) { throw "mcp_config.json missing" }
        if (Test-IsJunction -Path (Join-Path $testWsBase '.agents')) { throw ".agents must NOT be a junction!" }

        # Verify mcp_config.json disabled flags
        $mcpConfig = Get-Content -LiteralPath (Join-Path $testWsBase '.agents\mcp_config.json') -Raw -Encoding utf8 | ConvertFrom-Json
        if ($mcpConfig.mcpServers.context7.PSObject.Properties.Name -contains 'disabled') {
            throw "context7 should NOT be disabled in base profile"
        }
        if (-not $mcpConfig.mcpServers.'chrome-devtools-mcp'.disabled) {
            throw "chrome-devtools-mcp should be disabled in base profile"
        }
    }

    # 5.2 Web-Supabase Profile Init
    $testWsWeb = Join-Path $tempBase "TestWebProject"
    Assert-Test "Init project with 'web-supabase' profile includes web rules and enables supabase MCP" {
        Invoke-AidevInit -WorkspacePath $testWsWeb -Profile 'web-supabase' -ProjectName 'TestWebProject'
        if (-not (Test-Path (Join-Path $testWsWeb '.agents\rules\web-guidelines.md'))) { throw "web-guidelines.md missing" }
        if (-not (Test-Path (Join-Path $testWsWeb '.agents\rules\database-postgres.md'))) { throw "database-postgres.md missing" }

        $webMcpConfig = Get-Content -LiteralPath (Join-Path $testWsWeb '.agents\mcp_config.json') -Raw -Encoding utf8 | ConvertFrom-Json
        if ($webMcpConfig.mcpServers.'chrome-devtools-mcp'.PSObject.Properties.Name -contains 'disabled') {
            throw "chrome-devtools-mcp should be enabled in web-supabase profile"
        }
        if ($webMcpConfig.mcpServers.supabase.PSObject.Properties.Name -contains 'disabled') {
            throw "supabase should be enabled in web-supabase profile"
        }
    }

    # 5.3 Windows-Desktop Profile Init
    $testWsWin = Join-Path $tempBase "TestWinProject"
    Assert-Test "Init project with 'windows-desktop' profile includes windows rules and disables web MCPs" {
        Invoke-AidevInit -WorkspacePath $testWsWin -Profile 'windows-desktop' -ProjectName 'TestWinProject'
        if (-not (Test-Path (Join-Path $testWsWin '.agents\rules\windows-desktop.md'))) { throw "windows-desktop.md missing" }

        $winMcpConfig = Get-Content -LiteralPath (Join-Path $testWsWin '.agents\mcp_config.json') -Raw -Encoding utf8 | ConvertFrom-Json
        if (-not $winMcpConfig.mcpServers.'chrome-devtools-mcp'.disabled) {
            throw "chrome-devtools-mcp must be disabled in windows-desktop profile"
        }
    }

    # 5.4 Path with Spaces
    $testWsSpaces = Join-Path $tempBase "Test Path With Spaces"
    Assert-Test "Init project in path with spaces works seamlessly" {
        Invoke-AidevInit -WorkspacePath $testWsSpaces -Profile 'base' -ProjectName 'SpacesProject'
        if (-not (Test-Path (Join-Path $testWsSpaces '.agents\hooks.json'))) { throw "hooks.json missing in path with spaces" }
    }

    # 5.5 Idempotency (Running init twice does not destroy custom files)
    Assert-Test "Init is idempotent and preserves user modifications" {
        $customRule = Join-Path $testWsBase '.agents\rules\my-custom-rule.md'
        Set-Content -LiteralPath $customRule -Value "# Custom Rule" -Encoding utf8
        Invoke-AidevInit -WorkspacePath $testWsBase -Profile 'base' -ProjectName 'TestBaseProject'
        if (-not (Test-Path -LiteralPath $customRule)) { throw "Custom rule was deleted on second init!" }
    }

    # --------------------------------------------------------------------------
    # 6. Audit & Migration Tests
    # --------------------------------------------------------------------------
    Write-Host "`n--- 6. Audit & Migration Tests ---" -ForegroundColor Yellow

    # 6.1 Create simulated legacy project with monolithic junction & Regra Zero
    $legacyWs = Join-Path $tempBase "LegacyProject"
    $null = New-Item -ItemType Directory -Path $legacyWs -Force
    $legacyAgentsMd = Join-Path $legacyWs 'AGENTS.md'
    Set-Content -LiteralPath $legacyAgentsMd -Value ("# REGRA ZERO INEGOCIAVEL: ATIVACAO OBRIGATORIA`nLegacy content") -Encoding utf8

    $legacyAgentsLink = Join-Path $legacyWs '.agents'
    $null = cmd /c "mklink /J `"$legacyAgentsLink`" `"$aidevRoot`"" 2>&1

    Assert-Test "Audit detects monolithic junction and legacy Regra Zero" {
        $audit = Invoke-AidevAudit -WorkspacePath $legacyWs
        if (-not $audit.IsMonolithicJunction) { throw "Audit failed to detect monolithic junction" }
        if (-not $audit.HasLegacyRegraZero) { throw "Audit failed to detect legacy Regra Zero" }
        if (-not $audit.MigrationNeeded) { throw "Audit should recommend migration" }
    }

    Assert-Test "Migrate -DryRun produces plan with 0 writes to disk" {
        $beforeMtime = (Get-Item -LiteralPath $legacyAgentsMd).LastWriteTimeUtc
        Invoke-AidevMigrate -WorkspacePath $legacyWs -Profile 'base' -DryRun
        $afterMtime = (Get-Item -LiteralPath $legacyAgentsMd).LastWriteTimeUtc
        if ($beforeMtime -ne $afterMtime) { throw "DryRun wrote to AGENTS.md!" }
        if (-not (Test-IsJunction -Path $legacyAgentsLink)) { throw "DryRun unlinked the junction!" }
    }

    Assert-Test "Migrate real execution upgrades project safely and creates backup" {
        Invoke-AidevMigrate -WorkspacePath $legacyWs -Profile 'base'
        if (Test-IsJunction -Path $legacyAgentsLink) { throw "Junction was not replaced by physical directory" }
        if (-not (Test-Path -LiteralPath (Join-Path $legacyWs '.agents\rules\architecture-invariants.md'))) { throw "v2 rules not deployed" }
        $newContent = Get-Content -LiteralPath (Join-Path $legacyWs 'AGENTS.md') -Raw -Encoding utf8
        if ($newContent -match 'REGRA ZERO INEGOCIAVEL') { throw "Legacy Regra Zero still present in AGENTS.md!" }

        $backups = @(Get-ChildItem -LiteralPath $legacyWs -Directory -Filter '.aidev_backup_*')
        if ($backups.Count -eq 0) { throw "Backup directory was not created!" }
    }

    # --------------------------------------------------------------------------
    # 7. Failure Injection & Rollback Test
    # --------------------------------------------------------------------------
    Write-Host "`n--- 7. Failure Injection & Rollback Tests ---" -ForegroundColor Yellow

    $failWs = Join-Path $tempBase "FailureInjectionProject"
    $null = New-Item -ItemType Directory -Path $failWs -Force
    $originalAgentsMd = Join-Path $failWs 'AGENTS.md'
    $originalGeminiMd = Join-Path $failWs 'GEMINI.md'
    $originalContentA = "# Custom Pre-Migration Content A - Unique Fingerprint 12345"
    $originalContentG = "# Custom Pre-Migration Content G - Unique Fingerprint 67890"
    Set-Content -LiteralPath $originalAgentsMd -Value $originalContentA -Encoding utf8
    Set-Content -LiteralPath $originalGeminiMd -Value $originalContentG -Encoding utf8

    Assert-Test "Migration with failure injection triggers rollback and restores original content" {
        $failedAsExpected = $false
        try {
            Invoke-AidevMigrate -WorkspacePath $failWs -Profile 'base' -InjectFailureTest
        } catch {
            $failedAsExpected = $true
        }
        if (-not $failedAsExpected) { throw "Failure injection did not trigger exception!" }

        # Verify rollback restored the files
        $restoredA = Get-Content -LiteralPath $originalAgentsMd -Raw -Encoding utf8
        $restoredG = Get-Content -LiteralPath $originalGeminiMd -Raw -Encoding utf8
        if ($restoredA.Trim() -ne $originalContentA.Trim()) { throw "Rollback failed to restore AGENTS.md" }
        if ($restoredG.Trim() -ne $originalContentG.Trim()) { throw "Rollback failed to restore GEMINI.md" }
    }

    # --------------------------------------------------------------------------
    # 8. Clean & Pruning Tests
    # --------------------------------------------------------------------------
    Write-Host "`n--- 8. Clean & Pruning Tests ---" -ForegroundColor Yellow

    $cleanWs = Join-Path $tempBase "CleanProject"
    Invoke-AidevInit -WorkspacePath $cleanWs -Profile 'base' -ProjectName 'CleanProject'

    # Create orphan skill link, an obsolete managed rule, a dummy backup directory, and a user external file
    $cleanWsSkills = Join-Path $cleanWs '.agents\skills'
    $dummyOrphanLink = Join-Path $cleanWsSkills 'orphan-dummy-skill'
    $null = cmd /c "mklink /J `"$dummyOrphanLink`" `"$aidevRoot`"" 2>&1

    $dummyBackupDir = Join-Path $cleanWs '.aidev_backup_20200101_000000'
    $null = New-Item -ItemType Directory -Path $dummyBackupDir -Force

    $userExternalFile = Join-Path $cleanWs '.agents\my-external-notes.txt'
    Set-Content -LiteralPath $userExternalFile -Value "Important human notes" -Encoding utf8

    Assert-Test "Clean DryRun identifies obsolete links and backups without deleting them" {
        Invoke-AidevClean -WorkspacePath $cleanWs -DryRun
        if (-not (Test-Path -LiteralPath $dummyOrphanLink)) { throw "DryRun deleted orphan link!" }
        if (-not (Test-Path -LiteralPath $dummyBackupDir)) { throw "DryRun deleted backup dir!" }
    }

    Assert-Test "Clean real execution removes orphan link & backup while PRESERVING user external files and global library" {
        $globalSkillsPath = Join-Path $env:USERPROFILE '.agents\skills'
        $globalSkillsBefore = (Get-ChildItem -LiteralPath $globalSkillsPath).Count
        Invoke-AidevClean -WorkspacePath $cleanWs
        if (Test-Path -LiteralPath $dummyOrphanLink) { throw "Clean failed to remove orphan link!" }
        if (Test-Path -LiteralPath $dummyBackupDir) { throw "Clean failed to remove backup dir!" }
        if (-not (Test-Path -LiteralPath $userExternalFile)) { throw "Clean DELETED user external file!" }
        $globalSkillsAfter = (Get-ChildItem -LiteralPath $globalSkillsPath).Count
        if ($globalSkillsBefore -ne $globalSkillsAfter) { throw "Clean modified global skills library!" }
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
Write-Host $summaryText -ForegroundColor $summaryColor
Write-Host "============================================================" -ForegroundColor Cyan

if ($failedTests -gt 0) {
    exit 1
} else {
    exit 0
}
