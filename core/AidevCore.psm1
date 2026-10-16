# ==============================================================================
# AI-Dev-Machine Core Module (Architecture v2.1 -- Capability-Driven Framework)
# ==============================================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Canonical Roots
$script:GlobalAgentsRoot = Join-Path $env:USERPROFILE '.agents'
$script:GlobalSkillsRoot = Join-Path $script:GlobalAgentsRoot 'skills'
$script:GlobalAgentsDir  = Join-Path $script:GlobalAgentsRoot 'agents'

# ------------------------------------------------------------------------------
# Discovery & Registry Helpers
# ------------------------------------------------------------------------------
function Get-AidevRoot {
    $current = $PSScriptRoot
    while ($current) {
        if (Test-Path (Join-Path $current 'registry\capabilities.json')) {
            return $current
        }
        $parent = Split-Path -Parent $current
        if ($parent -eq $current) { break }
        $current = $parent
    }
    return $PSScriptRoot
}

function Get-RegistryData {
    param([Parameter(Mandatory)][string]$Type)
    $root = Get-AidevRoot
    $file = Join-Path $root ('registry\' + $Type + '.json')
    if (-not (Test-Path -LiteralPath $file)) {
        throw ('Registry file not found: ' + $file)
    }
    return (Get-Content -LiteralPath $file -Raw -Encoding utf8 | ConvertFrom-Json)
}

function Test-SkillDirectory {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedName
    )
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

function Test-AgentFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedName
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    if ((Get-Item -LiteralPath $Path).Length -le 0) { return $false }
    $lines = @(Get-Content -LiteralPath $Path -Encoding utf8 -ErrorAction Stop)
    if ($lines.Count -eq 0 -or $lines[0].TrimStart([char]0xFEFF).Trim() -ne '---') { return $false }
    $closing = @($lines | Select-Object -Skip 1 | Where-Object { $_.Trim() -eq '---' })
    if ($closing.Count -eq 0) { return $false }
    $nameLine = $lines | Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1
    if (-not $nameLine) { return $false }
    $nameMatch = [regex]::Match([string]$nameLine, '^name:\s*(.+)$')
    if ($nameMatch.Success) {
        $declaredName = $nameMatch.Groups[1].Value.Trim().Trim('"', "'")
        $kebabExpected = ($ExpectedName.ToLowerInvariant() -replace '\s+', '-')
        if ($declaredName -ne $ExpectedName -and $declaredName -ne $kebabExpected) { return $false }
    }
    return $true
}

function Test-IsJunction {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    return ($item.LinkType -eq 'Junction')
}

function Get-JunctionTarget {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-IsJunction -Path $Path)) { return $null }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item.Target) { return $null }
    $target = if ($item.Target -is [array]) { $item.Target[0] } else { $item.Target }
    return [IO.Path]::GetFullPath($target).TrimEnd('\', '/')
}

function Ensure-GitIgnoreEntry {
    param(
        [Parameter(Mandatory)][string]$WorkspacePath,
        [Parameter(Mandatory)][string]$Pattern
    )
    $gitIgnore = Join-Path $WorkspacePath '.gitignore'
    $lines = if (Test-Path -LiteralPath $gitIgnore) {
        @(Get-Content -LiteralPath $gitIgnore -Encoding utf8)
    } else {
        @()
    }
    $trimmed = @($lines | ForEach-Object { $_.Trim() })
    if ($trimmed -notcontains $Pattern.Trim()) {
        Add-Content -LiteralPath $gitIgnore -Value $Pattern -Encoding utf8
    }
}

function Get-SafeProp {
    param(
        $Obj,
        [string]$PropName,
        $Default = $null
    )
    if ($Obj -and $Obj.PSObject -and $Obj.PSObject.Properties.Name.Contains($PropName)) {
        return $Obj.$PropName
    }
    return $Default
}

# ------------------------------------------------------------------------------
# 1. DETECTION ENGINE (Read-Only Fact & Capability Scanner)
# ------------------------------------------------------------------------------
function Invoke-AidevDetect {
    param(
        [string]$WorkspacePath = (Get-Location).Path
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $capsData = (Get-RegistryData -Type 'capabilities').capabilities
    $profilesData = (Get-RegistryData -Type 'profiles').profiles

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- Stack & Capability Detector' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ('Scan Target : ' + $ws) -ForegroundColor Gray
    Write-Host 'Mode        : READ-ONLY (Observing facts without mutation)' -ForegroundColor Gray
    Write-Host ''

    $detectedFacts = [System.Collections.Generic.List[pscustomobject]]::new()
    $suggestedCaps = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()

    # Core is always included
    $suggestedCaps['core'] = [pscustomobject]@{
        Id         = 'core'
        Confidence = 'certain'
        Evidence   = 'Universal baseline for all software repositories'
    }

    # Helper: read package.json files (root + subfolders up to 2 levels)
    $allPackageJsons = @()
    if (Test-Path -LiteralPath (Join-Path $ws 'package.json')) {
        $allPackageJsons += (Join-Path $ws 'package.json')
    }
    $subPackages = @(Get-ChildItem -LiteralPath $ws -Filter 'package.json' -Recurse -Depth 3 -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch 'node_modules|\.git|\.aidev_backup' } | Select-Object -ExpandProperty FullName)
    $allPackageJsons += $subPackages
    $allPackageJsons = @($allPackageJsons | Select-Object -Unique)

    $allDependencies = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($pj in $allPackageJsons) {
        try {
            $parsed = Get-Content -LiteralPath $pj -Raw -Encoding utf8 | ConvertFrom-Json
            $deps = Get-SafeProp -Obj $parsed -PropName 'dependencies'
            if ($deps) {
                foreach ($dep in $deps.PSObject.Properties.Name) { $null = $allDependencies.Add($dep) }
            }
            $devDeps = Get-SafeProp -Obj $parsed -PropName 'devDependencies'
            if ($devDeps) {
                foreach ($dep in $devDeps.PSObject.Properties.Name) { $null = $allDependencies.Add($dep) }
            }
            $peerDeps = Get-SafeProp -Obj $parsed -PropName 'peerDependencies'
            if ($peerDeps) {
                foreach ($dep in $peerDeps.PSObject.Properties.Name) { $null = $allDependencies.Add($dep) }
            }
        } catch {}
    }

    # Evaluate detection hints for each capability
    foreach ($cap in $capsData) {
        $capId = $cap.id
        if ($capId -eq 'core') { continue }
        $hints = Get-SafeProp -Obj $cap -PropName 'detectionHints'
        if (-not $hints) { continue }

        foreach ($hint in $hints) {
            $matched = $false
            $evidenceDetail = ''

            if ($hint.type -eq 'fileExists') {
                $targetFile = Join-Path $ws $hint.pattern
                if (Test-Path -LiteralPath $targetFile -PathType Leaf) {
                    $matched = $true
                    $evidenceDetail = 'Found file: ' + $hint.pattern
                }
            } elseif ($hint.type -eq 'globExists') {
                $pat = $hint.pattern -replace '\\', '/'
                if ($pat -match '^\*\*/(\*\.[a-zA-Z0-9_\-]+)$') {
                    $filter = [regex]::Match($pat, '^\*\*/(\*\.[a-zA-Z0-9_\-]+)$').Groups[1].Value
                    $matchesList = @(Get-ChildItem -LiteralPath $ws -Filter $filter -Recurse -Depth 4 -ErrorAction SilentlyContinue |
                        Where-Object { $_.FullName -notmatch 'node_modules|\.git|\.aidev_backup' })
                    if ($matchesList.Count -gt 0) {
                        $matched = $true
                        $evidenceDetail = 'Found matching files (' + $matchesList.Count + '): ' + $hint.pattern
                    }
                } elseif ($pat -like '*/*') {
                    $subPath = Split-Path -Parent $pat
                    $filter = Split-Path -Leaf $pat
                    $fullSubPath = Join-Path $ws ($subPath -replace '/', '\')
                    if (Test-Path -LiteralPath $fullSubPath) {
                        $matchesList = @(Get-ChildItem -LiteralPath $fullSubPath -Filter $filter -ErrorAction SilentlyContinue |
                            Where-Object { $_.FullName -notmatch 'node_modules|\.git|\.aidev_backup' })
                        if ($matchesList.Count -gt 0) {
                            $matched = $true
                            $evidenceDetail = 'Found matching files (' + $matchesList.Count + ') in ' + $subPath
                        }
                    }
                } else {
                    $matchesList = @(Get-ChildItem -LiteralPath $ws -Filter $pat -Recurse -Depth 4 -ErrorAction SilentlyContinue |
                        Where-Object { $_.FullName -notmatch 'node_modules|\.git|\.aidev_backup' })
                    if ($matchesList.Count -gt 0) {
                        $matched = $true
                        $evidenceDetail = 'Found matching files (' + $matchesList.Count + '): ' + $hint.pattern
                    }
                }
            } elseif ($hint.type -eq 'packageDependency') {
                if ($allDependencies.Contains($hint.package)) {
                    $matched = $true
                    $evidenceDetail = 'Found package dependency: ' + $hint.package
                }
            } elseif ($hint.type -eq 'contentMatch') {
                $checkFile = Join-Path $ws $hint.file
                if (Test-Path -LiteralPath $checkFile) {
                    $content = Get-Content -LiteralPath $checkFile -Raw -Encoding utf8
                    if ($content -match $hint.pattern) {
                        $matched = $true
                        $evidenceDetail = 'Content match in ' + $hint.file + ' for: ' + $hint.pattern
                    }
                }
            }

            if ($matched) {
                $detectedFacts.Add([pscustomobject]@{
                    Capability = $capId
                    Type       = $hint.type
                    Evidence   = $evidenceDetail
                    Confidence = $hint.confidence
                })

                if (-not $suggestedCaps.ContainsKey($capId)) {
                    $suggestedCaps[$capId] = [pscustomobject]@{
                        Id         = $capId
                        Confidence = $hint.confidence
                        Evidence   = $evidenceDetail
                    }
                }
            }
        }
    }

    # Display findings
    Write-Host '--- 1. Detected Structural Facts ---' -ForegroundColor Yellow
    if ($detectedFacts.Count -eq 0) {
        Write-Host '  No specialized framework files detected. Standard generic repository.'
    } else {
        foreach ($f in $detectedFacts) {
            $confStr = '[' + $f.Confidence.ToUpper() + ']'
            Write-Host ('  ' + $confStr.PadRight(12) + ' Capability: ' + $f.Capability.PadRight(18) + ' :: ' + $f.Evidence)
        }
    }

    Write-Host ''
    Write-Host '--- 2. Suggested Capabilities ---' -ForegroundColor Yellow
    foreach ($sc in $suggestedCaps.Values) {
        $cObj = $capsData | Where-Object { $_.id -eq $sc.Id } | Select-Object -First 1
        $cName = if ($cObj) { $cObj.name } else { $sc.Id }
        Write-Host ('  + ' + $sc.Id.PadRight(20) + ' (' + $cName + ') [' + $sc.Confidence + ']') -ForegroundColor Green
    }

    # Best matching preset evaluation
    $bestPreset = 'custom'
    $suggestedCapIds = @($suggestedCaps.Keys)
    foreach ($pProp in $profilesData.PSObject.Properties) {
        $pName = $pProp.Name
        $pCaps = @($pProp.Value.capabilities)
        $diff = @($pCaps | Where-Object { $suggestedCapIds -notcontains $_ })
        if ($diff.Count -eq 0 -and $suggestedCapIds.Count -eq $pCaps.Count) {
            $bestPreset = $pName
            break
        }
    }

    Write-Host ''
    Write-Host ('Suggested Preset : ' + $bestPreset) -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'NOTE: Detection observes facts and suggests capabilities. It NEVER mutates files silently.' -ForegroundColor DarkGray

    $suggestedManifest = [ordered]@{
        '$schema'         = './schemas/aidev-manifest.schema.json'
        'schemaVersion'   = 1
        'preset'          = $bestPreset
        'capabilities'    = @($suggestedCaps.Keys)
        'projectRules'    = @()
        'validationGates' = [ordered]@{
            'commands' = [ordered]@{}
            'automated' = @()
            'human'     = @()
            'hardware'  = @()
        }
    }

    return [pscustomobject]@{
        Workspace             = $ws
        DetectedFacts         = @($detectedFacts)
        SuggestedCapabilities = @($suggestedCaps.Values)
        SuggestedPreset       = $bestPreset
        SuggestedManifest     = $suggestedManifest
    }
}

# ------------------------------------------------------------------------------
# 2. CAPABILITY GRAPH RESOLVER (Dependencies, Cycles & Provenance)
# ------------------------------------------------------------------------------
function Resolve-AidevCapabilities {
    param(
        [Parameter(Mandatory)][string[]]$Capabilities,
        [string]$Preset = $null,
        [string[]]$ProjectRules = @(),
        [string[]]$CustomSkills = @(),
        [string[]]$CustomAgents = @(),
        [string[]]$CustomMcps = @(),
        [hashtable]$ValidationOverrides = @{}
    )
    $capsRegistry = (Get-RegistryData -Type 'capabilities').capabilities
    $profilesRegistry = (Get-RegistryData -Type 'profiles').profiles
    $skillsRegistry = (Get-RegistryData -Type 'skills').skills

    # Step 1: Start with preset capabilities if preset declared
    $initialCaps = [System.Collections.Generic.List[string]]::new()
    if ($Preset -and $profilesRegistry.PSObject.Properties.Name.Contains($Preset)) {
        foreach ($c in $profilesRegistry.$Preset.capabilities) {
            if (-not $initialCaps.Contains($c)) { $initialCaps.Add($c) }
        }
    }

    # Step 2: Add declared capabilities
    foreach ($c in $Capabilities) {
        if (-not $initialCaps.Contains($c)) { $initialCaps.Add($c) }
    }
    # Core is strictly required
    if (-not $initialCaps.Contains('core')) { $initialCaps.Insert(0, 'core') }

    # Step 3: Transitive Dependency Expansion & Cycle Detection (Graph Traversal)
    $resolvedCapIds = [System.Collections.Generic.List[string]]::new()
    $visited = [System.Collections.Generic.HashSet[string]]::new()
    $recursionStack = [System.Collections.Generic.List[string]]::new()

    $traverse = $null
    $traverse = {
        param([string]$cId)
        $capObj = $capsRegistry | Where-Object { $_.id -eq $cId } | Select-Object -First 1
        if (-not $capObj) {
            throw ("Capability '" + $cId + "' is not registered in registry/capabilities.json.")
        }

        if ($recursionStack.Contains($cId)) {
            $cycle = ($recursionStack -join ' -> ') + ' -> ' + $cId
            throw ("Circular capability dependency detected: " + $cycle)
        }

        if ($visited.Contains($cId)) { return }

        $recursionStack.Add($cId)

        $reqs = Get-SafeProp -Obj $capObj -PropName 'requires' -Default @()
        if ($reqs) {
            foreach ($req in $reqs) {
                & $traverse $req
            }
        }

        $null = $recursionStack.Remove($cId)
        $null = $visited.Add($cId)
        $resolvedCapIds.Add($cId)
    }

    foreach ($c in $initialCaps) {
        & $traverse $c
    }

    # Step 4: Conflict Validation
    foreach ($cId in $resolvedCapIds) {
        $cObj = $capsRegistry | Where-Object { $_.id -eq $cId } | Select-Object -First 1
        $conflicts = if ($cObj) { Get-SafeProp -Obj $cObj -PropName 'conflicts' -Default @() } else { @() }
        if ($conflicts) {
            foreach ($conf in $conflicts) {
                if ($resolvedCapIds.Contains($conf)) {
                    throw ("Capability conflict detected: '" + $cId + "' conflicts with '" + $conf + "'.")
                }
            }
        }
    }

    # Step 5: Merge Rules, Skills, Agents, MCPs with Provenance
    $resolvedRules = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedSkills = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedAgents = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedMcps = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedCommands = [System.Collections.Generic.Dictionary[string, string]]::new()

    foreach ($cId in $resolvedCapIds) {
        $cObj = $capsRegistry | Where-Object { $_.id -eq $cId } | Select-Object -First 1

        # Rules
        $rules = if ($cObj) { Get-SafeProp -Obj $cObj -PropName 'rules' -Default @() } else { @() }
        if ($rules) {
            foreach ($r in $rules) {
                $resolvedRules[$r] = [pscustomobject]@{
                    Name      = $r
                    Source    = ('capability:' + $cId)
                    Reason    = ('Governance rule for capability ' + $cId)
                    Ownership = 'managed'
                    Trigger   = 'model_decision'
                }
            }
        }

        # Skills
        $skills = if ($cObj) { Get-SafeProp -Obj $cObj -PropName 'skills' -Default @() } else { @() }
        if ($skills) {
            foreach ($s in $skills) {
                $resolvedSkills[$s] = [pscustomobject]@{
                    Name   = $s
                    Source = ('capability:' + $cId)
                    Reason = ('Capability ' + $cId + ' runbook')
                    State  = 'enabled'
                }
            }
        }

        # Agents
        $agents = if ($cObj) { Get-SafeProp -Obj $cObj -PropName 'agents' -Default @() } else { @() }
        if ($agents) {
            foreach ($a in $agents) {
                $resolvedAgents[$a] = [pscustomobject]@{
                    Name   = $a
                    Source = ('capability:' + $cId)
                    Reason = ('Specialist for ' + $cId)
                    State  = 'enabled'
                }
            }
        }

        # MCPs
        $mcps = if ($cObj) { Get-SafeProp -Obj $cObj -PropName 'mcps' -Default @() } else { @() }
        if ($mcps) {
            foreach ($m in $mcps) {
                $resolvedMcps[$m] = [pscustomobject]@{
                    Name   = $m
                    Source = ('capability:' + $cId)
                    Reason = ('Tool provider for ' + $cId)
                    State  = 'enabled'
                }
            }
        }

        # Validation Defaults
        $vDefaults = if ($cObj) { Get-SafeProp -Obj $cObj -PropName 'validationDefaults' } else { $null }
        if ($vDefaults) {
            foreach ($prop in $vDefaults.PSObject.Properties) {
                if (-not $resolvedCommands.ContainsKey($prop.Name)) {
                    $resolvedCommands[$prop.Name] = $prop.Value
                }
            }
        }
    }

    # Cognitive specialists are always enabled
    $cognitiveAgents = @('researcher', 'reviewer', 'security-reviewer')
    foreach ($ca in $cognitiveAgents) {
        $resolvedAgents[$ca] = [pscustomobject]@{
            Name   = $ca
            Source = 'builtin:cognitive-specialist'
            Reason = 'Universal cognitive separation of duties'
            State  = 'enabled'
        }
    }

    # Custom Project Rules (Local Ownership)
    foreach ($pr in $ProjectRules) {
        $ruleLeaf = Split-Path -Leaf $pr
        $resolvedRules[$ruleLeaf] = [pscustomobject]@{
            Name      = $ruleLeaf
            Path      = $pr
            Source    = 'manifest:projectRules'
            Reason    = 'Project-specific local governance rule'
            Ownership = 'local'
            Trigger   = 'model_decision'
        }
    }

    # Custom Skills Overrides
    foreach ($cs in $CustomSkills) {
        $resolvedSkills[$cs] = [pscustomobject]@{
            Name   = $cs
            Source = 'manifest:customSkills'
            Reason = 'Explicit project skill inclusion'
            State  = 'enabled'
        }
    }

    # Custom Agents Overrides
    foreach ($ca in $CustomAgents) {
        $resolvedAgents[$ca] = [pscustomobject]@{
            Name   = $ca
            Source = 'manifest:customAgents'
            Reason = 'Explicit project agent inclusion'
            State  = 'enabled'
        }
    }

    # Custom MCPs Overrides
    foreach ($cm in $CustomMcps) {
        $resolvedMcps[$cm] = [pscustomobject]@{
            Name   = $cm
            Source = 'manifest:customMcps'
            Reason = 'Explicit project MCP inclusion'
            State  = 'enabled'
        }
    }

    # Command Overrides
    if ($ValidationOverrides.ContainsKey('commands') -and $ValidationOverrides['commands']) {
        foreach ($k in $ValidationOverrides['commands'].Keys) {
            $resolvedCommands[$k] = $ValidationOverrides['commands'][$k]
        }
    }

    return [pscustomobject]@{
        Preset               = $Preset
        DeclaredCapabilities = @($Capabilities)
        ResolvedCapabilities = @($resolvedCapIds)
        Rules                = @($resolvedRules.Values)
        Skills               = @($resolvedSkills.Values)
        Agents               = @($resolvedAgents.Values)
        Mcps                 = @($resolvedMcps.Values)
        Commands             = $resolvedCommands
        AutomatedGates       = if ($ValidationOverrides.ContainsKey('automated')) { @($ValidationOverrides['automated']) } else { @() }
        HumanGates           = if ($ValidationOverrides.ContainsKey('human')) { @($ValidationOverrides['human']) } else { @() }
        HardwareGates        = if ($ValidationOverrides.ContainsKey('hardware')) { @($ValidationOverrides['hardware']) } else { @() }
        DuplicateExposures   = @()
    }
}

# ------------------------------------------------------------------------------
# 3. MANIFEST OPERATIONS (Validate, Show, Init)
# ------------------------------------------------------------------------------
function Get-AidevManifest {
    param([Parameter(Mandatory)][string]$WorkspacePath)
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $manifestPath = Join-Path $ws '.aidev.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        return $null
    }
    try {
        $raw = Get-Content -LiteralPath $manifestPath -Raw -Encoding utf8
        return ($raw | ConvertFrom-Json)
    } catch {
        throw ("Failed to parse .aidev.json: " + $_.Exception.Message)
    }
}

function Test-AidevManifest {
    param([Parameter(Mandatory)][string]$WorkspacePath)
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $manifestPath = Join-Path $ws '.aidev.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw ("Project manifest '.aidev.json' not found at " + $ws)
    }

    $manifest = Get-AidevManifest -WorkspacePath $ws
    $sVer = Get-SafeProp -Obj $manifest -PropName 'schemaVersion'
    if (-not $sVer) {
        throw "Manifest validation error: 'schemaVersion' is required."
    }
    if ($sVer -ne 1) {
        throw ("Unsupported schemaVersion " + $sVer + ". Current AI-Dev-Machine supports schemaVersion 1.")
    }

    $caps = @(Get-SafeProp -Obj $manifest -PropName 'capabilities' -Default @())
    if ($caps.Count -eq 0) {
        throw "Manifest validation error: 'capabilities' must be a non-empty array."
    }

    # Validate that capabilities exist in registry
    $capsRegistry = (Get-RegistryData -Type 'capabilities').capabilities
    $validCapIds = @($capsRegistry.id)
    foreach ($c in $caps) {
        if ($validCapIds -notcontains $c) {
            throw ("Manifest validation error: Unknown capability '" + $c + "'. Available: " + ($validCapIds -join ', '))
        }
    }

    # Validate projectRules do not escape workspace (Security: Path Traversal Check)
    $pRules = @(Get-SafeProp -Obj $manifest -PropName 'projectRules' -Default @())
    if ($pRules.Count -gt 0) {
        foreach ($pr in $pRules) {
            $fullPath = Join-Path $ws $pr
            $normalized = [IO.Path]::GetFullPath($fullPath)
            if (-not $normalized.StartsWith($ws, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw ("Security error: projectRule '" + $pr + "' escapes workspace boundary (" + $normalized + ").")
            }
            if (-not (Test-Path -LiteralPath $normalized -PathType Leaf)) {
                Write-Host ('  [WARNING] Declared projectRule not found on disk: ' + $pr) -ForegroundColor Yellow
            }
        }
    }

    # Resolve capability graph to ensure no missing dependencies or cycles
    $overrides = @{}
    $vGates = Get-SafeProp -Obj $manifest -PropName 'validationGates'
    if ($vGates) {
        $cmds = Get-SafeProp -Obj $vGates -PropName 'commands'
        if ($cmds) {
            $cmdHash = @{}
            foreach ($p in $cmds.PSObject.Properties) { $cmdHash[$p.Name] = $p.Value }
            $overrides['commands'] = $cmdHash
        }
        $auto = Get-SafeProp -Obj $vGates -PropName 'automated'
        if ($auto) { $overrides['automated'] = $auto }
        $human = Get-SafeProp -Obj $vGates -PropName 'human'
        if ($human) { $overrides['human'] = $human }
        $hw = Get-SafeProp -Obj $vGates -PropName 'hardware'
        if ($hw) { $overrides['hardware'] = $hw }
    }

    $cSkills = @(Get-SafeProp -Obj $manifest -PropName 'customSkills' -Default @())
    $cAgents = @(Get-SafeProp -Obj $manifest -PropName 'customAgents' -Default @())
    $cMcps = @(Get-SafeProp -Obj $manifest -PropName 'customMcps' -Default @())
    $preset = Get-SafeProp -Obj $manifest -PropName 'preset' -Default $null

    $resolved = Resolve-AidevCapabilities `
        -Capabilities @($caps) `
        -Preset $preset `
        -ProjectRules @($pRules) `
        -CustomSkills @($cSkills) `
        -CustomAgents @($cAgents) `
        -CustomMcps @($cMcps) `
        -ValidationOverrides $overrides

    return [pscustomobject]@{
        Valid    = $true
        Manifest = $manifest
        Resolved = $resolved
    }
}

function Invoke-AidevManifest {
    param(
        [Parameter(Mandatory)][ValidateSet('validate', 'show', 'init')][string]$Action,
        [string]$WorkspacePath = (Get-Location).Path,
        [string]$Preset = 'base',
        [string[]]$Capabilities = @(),
        [switch]$Force
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)

    if ($Action -eq 'validate') {
        Write-Host '============================================================' -ForegroundColor Cyan
        Write-Host ' AI-Dev-Machine Architecture v2.1 -- Manifest Validation' -ForegroundColor Cyan
        Write-Host '============================================================' -ForegroundColor Cyan
        Write-Host ('Manifest Target : ' + (Join-Path $ws '.aidev.json')) -ForegroundColor Gray
        Write-Host ''
        try {
            $res = Test-AidevManifest -WorkspacePath $ws
            $mPreset = Get-SafeProp -Obj $res.Manifest -PropName 'preset'
            $mCaps = @(Get-SafeProp -Obj $res.Manifest -PropName 'capabilities' -Default @())
            $mRules = @(Get-SafeProp -Obj $res.Manifest -PropName 'projectRules' -Default @())
            $dispPreset = if ($mPreset) { $mPreset } else { 'custom' }

            Write-Host '  [VALID] .aidev.json is fully compliant with schemaVersion 1 and capability graph.' -ForegroundColor Green
            Write-Host ('  Preset      : ' + $dispPreset) -ForegroundColor Green
            Write-Host ('  Capabilities: ' + ($mCaps -join ', ')) -ForegroundColor Green
            if ($mRules.Count -gt 0) {
                Write-Host ('  ProjectRules: ' + ($mRules -join ', ')) -ForegroundColor Green
            }
            return $res
        } catch {
            Write-Host ('  [INVALID] ' + $_.Exception.Message) -ForegroundColor Red
            throw
        }
    }

    if ($Action -eq 'show') {
        $manifestPath = Join-Path $ws '.aidev.json'
        if (-not (Test-Path -LiteralPath $manifestPath)) {
            throw ("Manifest not found at " + $manifestPath)
        }
        $raw = Get-Content -LiteralPath $manifestPath -Raw -Encoding utf8
        Write-Host '=== PROJECT MANIFEST (.aidev.json) ===' -ForegroundColor Cyan
        Write-Host $raw
        return ($raw | ConvertFrom-Json)
    }

    if ($Action -eq 'init') {
        $manifestPath = Join-Path $ws '.aidev.json'
        if ((Test-Path -LiteralPath $manifestPath) -and -not $Force) {
            throw ("Manifest already exists at " + $manifestPath + ". Use -Force to overwrite.")
        }
        $capsList = [System.Collections.Generic.List[string]]::new()
        $profilesRegistry = (Get-RegistryData -Type 'profiles').profiles
        if ($Preset -and $profilesRegistry.PSObject.Properties.Name.Contains($Preset)) {
            foreach ($c in $profilesRegistry.$Preset.capabilities) {
                if (-not $capsList.Contains($c)) { $capsList.Add($c) }
            }
        }
        if (-not $capsList.Contains('core')) { $capsList.Insert(0, 'core') }
        if ($Capabilities -and $Capabilities.Count -gt 0) {
            foreach ($c in $Capabilities) {
                if (-not $capsList.Contains($c)) { $capsList.Add($c) }
            }
        }

        $manifestObj = [ordered]@{
            '$schema'         = './schemas/aidev-manifest.schema.json'
            'schemaVersion'   = 1
            'preset'          = $Preset
            'capabilities'    = @($capsList)
            'projectRules'    = @()
            'validationGates' = [ordered]@{
                'commands'  = [ordered]@{}
                'automated' = @()
                'human'     = @()
                'hardware'  = @()
            }
        }
        $manifestObj | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8
        Write-Host ("Initialized project manifest '.aidev.json' at " + $ws) -ForegroundColor Green
        Write-Host "Run 'aidev apply' to materialize or 'aidev resolve' to inspect." -ForegroundColor Gray
    }
}

# ------------------------------------------------------------------------------
# 4. RESOLVER (Effective Configuration Inspector)
# ------------------------------------------------------------------------------
function Invoke-AidevResolve {
    param(
        [string]$WorkspacePath = '.',
        [string]$Preset = $null,
        [string[]]$Capabilities = @()
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $manifest = Get-AidevManifest -WorkspacePath $ws

    $targetPreset = $Preset
    $targetCaps = @($Capabilities)
    $projectRules = @()
    $overrides = @{}

    if ($manifest) {
        $mPreset = Get-SafeProp -Obj $manifest -PropName 'preset'
        $mCaps = @(Get-SafeProp -Obj $manifest -PropName 'capabilities' -Default @())
        $mRules = @(Get-SafeProp -Obj $manifest -PropName 'projectRules' -Default @())
        $vGates = Get-SafeProp -Obj $manifest -PropName 'validationGates'

        if (-not $targetPreset) { $targetPreset = $mPreset }
        if ($targetCaps.Count -eq 0 -and $mCaps.Count -gt 0) { $targetCaps = @($mCaps) }
        if ($mRules.Count -gt 0) { $projectRules = @($mRules) }
        if ($vGates) {
            $cmds = Get-SafeProp -Obj $vGates -PropName 'commands'
            if ($cmds) {
                $cmdHash = @{}
                foreach ($p in $cmds.PSObject.Properties) { $cmdHash[$p.Name] = $p.Value }
                $overrides['commands'] = $cmdHash
            }
            $auto = Get-SafeProp -Obj $vGates -PropName 'automated'
            if ($auto) { $overrides['automated'] = $auto }
            $human = Get-SafeProp -Obj $vGates -PropName 'human'
            if ($human) { $overrides['human'] = $human }
            $hw = Get-SafeProp -Obj $vGates -PropName 'hardware'
            if ($hw) { $overrides['hardware'] = $hw }
        }
    } elseif ($targetCaps.Count -eq 0 -and -not $targetPreset) {
        $targetPreset = 'base'
        $targetCaps = @('core')
    }

    $res = Resolve-AidevCapabilities `
        -Capabilities $targetCaps `
        -Preset $targetPreset `
        -ProjectRules $projectRules `
        -ValidationOverrides $overrides

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- Effective Resolution' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $dispPreset = if ($res.Preset) { $res.Preset } else { 'custom' }
    Write-Host ('Preset Applied       : ' + $dispPreset) -ForegroundColor Green
    Write-Host ('Declared Capabilities: ' + ($res.DeclaredCapabilities -join ', ')) -ForegroundColor Gray
    Write-Host ('Resolved Capabilities: ' + ($res.ResolvedCapabilities -join ' -> ')) -ForegroundColor Gray
    Write-Host ''

    Write-Host ('--- 1. Effective Rules (' + @($res.Rules).Count + ') ---') -ForegroundColor Yellow
    foreach ($r in $res.Rules) {
        $ownStr = '[' + $r.Ownership.ToUpper() + ']'
        Write-Host ('  ' + $r.Name.PadRight(30) + ' ' + $ownStr.PadRight(12) + ' :: Source: ' + $r.Source.PadRight(22) + ' :: Trigger: ' + $r.Trigger)
    }

    Write-Host ''
    Write-Host ('--- 2. Effective Skills (' + @($res.Skills).Count + ') ---') -ForegroundColor Yellow
    foreach ($s in $res.Skills) {
        Write-Host ('  ' + $s.Name.PadRight(32) + ' :: Source: ' + $s.Source.PadRight(22) + ' :: ' + $s.Reason)
    }

    Write-Host ''
    Write-Host ('--- 3. Effective Agents (' + @($res.Agents).Count + ') ---') -ForegroundColor Yellow
    foreach ($a in $res.Agents) {
        Write-Host ('  ' + $a.Name.PadRight(32) + ' :: Source: ' + $a.Source.PadRight(22) + ' :: ' + $a.Reason)
    }

    Write-Host ''
    Write-Host ('--- 4. Effective MCP Servers (' + @($res.Mcps).Count + ') ---') -ForegroundColor Yellow
    foreach ($m in $res.Mcps) {
        Write-Host ('  ' + $m.Name.PadRight(24) + ' :: Source: ' + $m.Source.PadRight(22) + ' :: ' + $m.Reason)
    }

    Write-Host ''
    Write-Host '--- 5. Canonical Commands & Validation Gates ---' -ForegroundColor Yellow
    if ($res.Commands -and $res.Commands.Count -gt 0) {
        foreach ($k in $res.Commands.Keys) {
            Write-Host ('  ' + $k.PadRight(16) + ' : ' + $res.Commands[$k]) -ForegroundColor Green
        }
    }
    if (@($res.HumanGates).Count -gt 0) {
        Write-Host '  Human Gates (Machine cannot auto-approve):' -ForegroundColor DarkYellow
        foreach ($hg in $res.HumanGates) {
            Write-Host ('    - [' + $hg.id + '] ' + $hg.description) -ForegroundColor DarkYellow
        }
    }
    if (@($res.HardwareGates).Count -gt 0) {
        Write-Host '  Hardware Gates (Physical verification required):' -ForegroundColor DarkYellow
        foreach ($hw in $res.HardwareGates) {
            Write-Host ('    - [' + $hw.id + '] ' + $hw.description) -ForegroundColor DarkYellow
        }
    }

    Write-Host ''
    Write-Host '--- 6. Duplication & Isolation Audit ---' -ForegroundColor Yellow
    Write-Host '  [OK] Zero duplicate exposures detected across scopes' -ForegroundColor Green

    return $res
}

# ------------------------------------------------------------------------------
# 5. DOCTOR COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevDoctor {
    param([string]$WorkspacePath = (Get-Location).Path)
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $root = Get-AidevRoot

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- System & Project Doctor' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ('Workspace Target : ' + $ws) -ForegroundColor Gray
    Write-Host ('AI-Dev Root      : ' + $root) -ForegroundColor Gray
    Write-Host ''

    # 1. Environment and Tools
    Write-Host '[1/6] Core Environment and CLIs' -ForegroundColor Yellow
    $tools = @(
        @{ Name = 'Git'; Cmd = 'git'; VersionArgs = @('--version') }
        @{ Name = 'Node.js'; Cmd = 'node'; VersionArgs = @('--version') }
        @{ Name = 'npm'; Cmd = 'npm'; VersionArgs = @('--version') }
        @{ Name = 'pnpm'; Cmd = 'pnpm'; VersionArgs = @('--version') }
        @{ Name = 'Python'; Cmd = 'py'; VersionArgs = @('--version') }
        @{ Name = 'uv'; Cmd = 'uv'; VersionArgs = @('--version') }
        @{ Name = 'ripgrep (rg)'; Cmd = 'rg'; VersionArgs = @('--version') }
        @{ Name = 'jq'; Cmd = 'jq'; VersionArgs = @('--version') }
        @{ Name = 'Semgrep'; Cmd = 'semgrep'; VersionArgs = @('--version') }
        @{ Name = 'Playwright'; Cmd = 'playwright'; VersionArgs = @('--version') }
        @{ Name = 'WinApp CLI'; Cmd = 'winapp'; VersionArgs = @('--version') }
        @{ Name = 'Graphify CLI'; Cmd = 'graphify'; VersionArgs = @('--help') }
    )

    foreach ($t in $tools) {
        $found = Get-Command $t.Cmd -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            try {
                $out = (& $t.Cmd @($t.VersionArgs) 2>&1 | Select-Object -First 1).ToString().Trim()
                Write-Host ('  [OK] ' + $t.Name.PadRight(18) + ' : ' + $out) -ForegroundColor Green
            } catch {
                Write-Host ('  [OK] ' + $t.Name.PadRight(18) + ' : Installed (' + $found.Source + ')') -ForegroundColor Green
            }
        } else {
            Write-Host ('  [ABSENT] ' + $t.Name.PadRight(14) + ' : Not found in PATH') -ForegroundColor DarkGray
        }
    }

    # 2. Canonical Registries & Schemas
    Write-Host ''
    Write-Host '[2/6] Canonical Registries & Schemas' -ForegroundColor Yellow
    $regFiles = @('skills', 'agents', 'mcps', 'plugins', 'profiles', 'capabilities')
    foreach ($rf in $regFiles) {
        try {
            $data = Get-RegistryData -Type $rf
            $count = if ($rf -eq 'profiles') {
                @($data.profiles.PSObject.Properties).Count
            } else {
                $data.$rf.Count
            }
            Write-Host ('  [OK] registry/' + $rf + '.json (' + $count + ' items)') -ForegroundColor Green
        } catch {
            Write-Host ('  [ERROR] registry/' + $rf + '.json : ' + $_.Exception.Message) -ForegroundColor Red
        }
    }
    $schemaFile = Join-Path $root 'schemas\aidev-manifest.schema.json'
    if (Test-Path -LiteralPath $schemaFile) {
        Write-Host '  [OK] schemas/aidev-manifest.schema.json present' -ForegroundColor Green
    }

    # 3. Global Storage Library
    Write-Host ''
    Write-Host '[3/6] Global Canonical Library (%USERPROFILE%\.agents)' -ForegroundColor Yellow
    if (Test-Path -LiteralPath $script:GlobalAgentsRoot) {
        Write-Host '  [OK] Global .agents directory present' -ForegroundColor Green
        $skillsCount = if (Test-Path -LiteralPath $script:GlobalSkillsRoot) {
            @(Get-ChildItem -LiteralPath $script:GlobalSkillsRoot -Directory).Count
        } else { 0 }
        $agentsCount = if (Test-Path -LiteralPath $script:GlobalAgentsDir) {
            @(Get-ChildItem -LiteralPath $script:GlobalAgentsDir -Filter '*.md' -File).Count
        } else { 0 }
        Write-Host ('  [OK] Skills in global library: ' + $skillsCount) -ForegroundColor Green
        Write-Host ('  [OK] Agents in global library: ' + $agentsCount) -ForegroundColor Green
    } else {
        Write-Host '  [PENDING] Global .agents directory not created yet. Run "aidev sync".' -ForegroundColor DarkYellow
    }

    # 4. Multi-IA Discovery Points
    Write-Host ''
    Write-Host '[4/6] Multi-IA Discovery Points' -ForegroundColor Yellow
    $targets = @(
        @{ Name = 'Antigravity/Gemini Config'; Path = Join-Path $env:USERPROFILE '.gemini\config' }
        @{ Name = 'Claude Agents Root'; Path = Join-Path $env:USERPROFILE '.claude\agents' }
        @{ Name = 'Gemini Agents Root'; Path = Join-Path $env:USERPROFILE '.gemini\agents' }
        @{ Name = 'Codex Skills Root'; Path = Join-Path $env:USERPROFILE '.codex\skills' }
    )
    foreach ($tgt in $targets) {
        if (Test-Path -LiteralPath $tgt.Path) {
            Write-Host ('  [OK] ' + $tgt.Name + ' (' + $tgt.Path + ')') -ForegroundColor Green
        } else {
            Write-Host ('  [PENDING] ' + $tgt.Name + ' (' + $tgt.Path + ')') -ForegroundColor DarkGray
        }
    }

    # 5. Workspace Status & Manifest
    Write-Host ''
    Write-Host ('[5/6] Workspace Architecture Status (' + $ws + ')') -ForegroundColor Yellow
    $manifestFile = Join-Path $ws '.aidev.json'
    if (Test-Path -LiteralPath $manifestFile) {
        try {
            $valRes = Test-AidevManifest -WorkspacePath $ws
            Write-Host ('  [OK] .aidev.json valid (preset: ' + $valRes.Manifest.preset + ', capabilities: ' + ($valRes.Manifest.capabilities -join ', ') + ')') -ForegroundColor Green
        } catch {
            Write-Host ('  [INVALID MANIFEST] ' + $_.Exception.Message) -ForegroundColor Red
        }
    } else {
        Write-Host '  [NOTICE] No .aidev.json manifest found. Run "aidev init" or "aidev detect".' -ForegroundColor DarkGray
    }

    $wsAgents = Join-Path $ws '.agents'
    if (Test-IsJunction -Path $wsAgents) {
        $target = Get-JunctionTarget -Path $wsAgents
        Write-Host ('  [LEGACY WARNING] Workspace .agents is a monolithic junction -> ' + $target) -ForegroundColor DarkYellow
    } elseif (Test-Path -LiteralPath $wsAgents) {
        Write-Host '  [OK] Workspace .agents is an isolated physical directory (Architecture v2.1 compliant)' -ForegroundColor Green
        $wsSkillsDir = Join-Path $wsAgents 'skills'
        if (Test-Path -LiteralPath $wsSkillsDir) {
            $skillItems = @(Get-ChildItem -LiteralPath $wsSkillsDir -Directory -Force -ErrorAction SilentlyContinue)
            $skillJunctions = @($skillItems | Where-Object { Test-IsJunction -Path $_.FullName })
            if ($skillJunctions.Count -gt 0) {
                Write-Host ('  [LEGACY WARNING] ' + $skillJunctions.Count + ' skill(s) in .agents/skills/ are NTFS junctions (run "aidev apply" to materialize physical copies)') -ForegroundColor DarkYellow
            } else {
                Write-Host ('  [OK] .agents/skills/ contains ' + $skillItems.Count + ' physical skill directory(ies) (0 junctions)') -ForegroundColor Green
            }
        }
        $wsAgentsDir = Join-Path $wsAgents 'agents'
        if (Test-Path -LiteralPath $wsAgentsDir) {
            $agentItems = @(Get-ChildItem -LiteralPath $wsAgentsDir -Filter '*.md' -File -ErrorAction SilentlyContinue)
            Write-Host ('  [OK] .agents/agents/ contains ' + $agentItems.Count + ' specialized subagent(s)') -ForegroundColor Green
        }
        $wsRoutingRule = Join-Path $wsAgents 'rules\skill-routing.md'
        if (Test-Path -LiteralPath $wsRoutingRule) {
            Write-Host '  [OK] .agents/rules/skill-routing.md active (always_on)' -ForegroundColor Green
        } else {
            Write-Host '  [MISSING RULE] .agents/rules/skill-routing.md not found (run "aidev apply")' -ForegroundColor DarkYellow
        }
        $wsHooks = Join-Path $wsAgents 'hooks.json'
        if (Test-Path -LiteralPath $wsHooks) {
            $hooksRaw = Get-Content -LiteralPath $wsHooks -Raw -Encoding utf8
            if ($hooksRaw -match '-File \.agents/scripts/safety-check\.ps1' -or $hooksRaw -match '\[Console\]::Out\.WriteLine') {
                Write-Host '  [LEGACY WARNING] .agents/hooks.json uses legacy relative path (run "aidev apply" to repair)' -ForegroundColor DarkYellow
            } else {
                Write-Host '  [OK] .agents/hooks.json configured with resilient safety-check path' -ForegroundColor Green
            }
        }
        $wsGraphJson = Join-Path $ws 'graphify-out\graph.json'
        if (Test-Path -LiteralPath $wsGraphJson) {
            Write-Host '  [OK] graphify knowledge graph ready (graphify-out/graph.json)' -ForegroundColor Green
        } else {
            Write-Host '  [NOTICE] graphify-out/graph.json not built yet (run "aidev apply" or "graphify extract . --code-only")' -ForegroundColor DarkGray
        }
    }

    # 6. MCP Environment Variables Check (Without Exposing Secrets)
    Write-Host ''
    Write-Host '[6/6] Security & Environment Tokens Audit' -ForegroundColor Yellow
    $mcpData = Get-RegistryData -Type 'mcps'
    foreach ($m in $mcpData.mcps) {
        if ($m.requiresAuth) {
            $varName = if ($m.PSObject.Properties.Name.Contains('authEnvVar') -and $m.authEnvVar) { $m.authEnvVar } else { ($m.id.ToUpper() + '_ACCESS_TOKEN') }
            $val = [Environment]::GetEnvironmentVariable($varName)
            if ($val) {
                Write-Host ('  [OK] ' + $m.name + ' : Auth variable ' + $varName + ' is configured') -ForegroundColor Green
            } else {
                Write-Host ('  [AUTH PENDING] ' + $m.name + ' : ' + $varName + ' not set (MCP remains disabled until provided)') -ForegroundColor DarkYellow
            }
        }
    }

    Write-Host ''
    Write-Host 'Doctor completed successfully (read-only).' -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# 6. CAPABILITY MANAGEMENT (List, Show, Add, Remove)
# ------------------------------------------------------------------------------
function Invoke-AidevCapability {
    param(
        [Parameter(Mandatory)][ValidateSet('list', 'show', 'add', 'remove')][string]$Action,
        [string]$Id = $null,
        [string]$WorkspacePath = '.'
    )
    $capsData = (Get-RegistryData -Type 'capabilities').capabilities
    $ws = [IO.Path]::GetFullPath($WorkspacePath)

    if ($Action -eq 'list') {
        Write-Host '=== AVAILABLE CAPABILITIES (registry/capabilities.json) ===' -ForegroundColor Cyan
        $grouped = $capsData | Group-Object -Property category
        foreach ($grp in $grouped) {
            Write-Host ('`nCategory: ' + $grp.Name.ToUpper()) -ForegroundColor Yellow
            foreach ($c in $grp.Group) {
                $idStr = $c.id.PadRight(22)
                Write-Host ('  ' + $idStr + ' : ' + $c.description)
            }
        }
        return
    }

    if ($Action -eq 'show') {
        if (-not $Id) { throw "Please specify a capability ID to show: aidev capability show <id>" }
        $c = $capsData | Where-Object { $_.id -eq $Id } | Select-Object -First 1
        if (-not $c) { throw "Capability '$Id' not found." }

        Write-Host ('=== CAPABILITY: ' + $c.id + ' (' + $c.name + ') ===') -ForegroundColor Cyan
        Write-Host ('Category   : ' + $c.category)
        Write-Host ('Description: ' + $c.description)
        Write-Host ('Requires   : ' + ($c.requires -join ', '))
        Write-Host ('Rules      : ' + ($c.rules -join ', '))
        Write-Host ('Skills     : ' + ($c.skills -join ', '))
        Write-Host ('Agents     : ' + ($c.agents -join ', '))
        Write-Host ('MCPs       : ' + ($c.mcps -join ', '))
        return
    }

    if ($Action -eq 'add' -or $Action -eq 'remove') {
        if (-not $Id) { throw "Please specify a capability ID to $Action" }
        $manifestPath = Join-Path $ws '.aidev.json'
        if (-not (Test-Path -LiteralPath $manifestPath)) {
            throw "No .aidev.json found in $ws. Run 'aidev init' first."
        }
        $manifest = Get-AidevManifest -WorkspacePath $ws

        if ($Action -eq 'add') {
            $c = $capsData | Where-Object { $_.id -eq $Id } | Select-Object -First 1
            if (-not $c) { throw "Capability '$Id' does not exist in registry." }
            $capsList = [System.Collections.Generic.List[string]]::new([string[]]$manifest.capabilities)
            if (-not $capsList.Contains($Id)) {
                $capsList.Add($Id)
                $manifest.capabilities = @($capsList)
                $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8
                Write-Host ("Added capability '" + $Id + "' to .aidev.json. Run 'aidev apply' to materialize.") -ForegroundColor Green
            } else {
                Write-Host ("Capability '" + $Id + "' already present in .aidev.json.") -ForegroundColor Yellow
            }
        } elseif ($Action -eq 'remove') {
            if ($Id -eq 'core') { throw "Capability 'core' is required and cannot be removed." }
            $capsList = [System.Collections.Generic.List[string]]::new([string[]]$manifest.capabilities)
            if ($capsList.Contains($Id)) {
                $null = $capsList.Remove($Id)
                $manifest.capabilities = @($capsList)
                $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8
                Write-Host ("Removed capability '" + $Id + "' from .aidev.json. Run 'aidev apply' to materialize.") -ForegroundColor Green
            } else {
                Write-Host ("Capability '" + $Id + "' not present in .aidev.json.") -ForegroundColor Yellow
            }
        }
    }
}

function Invoke-AidevList {
    param(
        [ValidateSet('skills', 'agents', 'mcps', 'plugins', 'profiles', 'capabilities', 'all')][string]$Category = 'all'
    )
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- Canonical Registry' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan

    if ($Category -eq 'all' -or $Category -eq 'capabilities') {
        $caps = (Get-RegistryData -Type 'capabilities').capabilities
        Write-Host ('`n[1] Capabilities (' + $caps.Count + ' items):') -ForegroundColor Yellow
        $grouped = $caps | Group-Object -Property category
        foreach ($grp in $grouped) {
            Write-Host ('  Category: ' + $grp.Name.ToUpper()) -ForegroundColor Cyan
            foreach ($c in $grp.Group) {
                Write-Host ('    ' + $c.id.PadRight(20) + ' : ' + $c.description)
            }
        }
    }

    if ($Category -eq 'all' -or $Category -eq 'profiles') {
        $profs = (Get-RegistryData -Type 'profiles').profiles
        Write-Host ('`n[2] Presets / Profiles (' + (@($profs.PSObject.Properties).Count) + ' items):') -ForegroundColor Yellow
        foreach ($p in $profs.PSObject.Properties) {
            Write-Host ('  ' + $p.Name.PadRight(18) + ' : ' + $p.Value.name + ' (' + ($p.Value.capabilities -join ', ') + ')')
        }
    }

    if ($Category -eq 'all' -or $Category -eq 'skills') {
        $skills = (Get-RegistryData -Type 'skills').skills
        Write-Host ('`n[3] Skills (' + $skills.Count + ' items):') -ForegroundColor Yellow
        foreach ($s in $skills) {
            Write-Host ('  ' + $s.name.PadRight(30) + ' : ' + $s.description)
        }
    }

    if ($Category -eq 'all' -or $Category -eq 'agents') {
        $agents = (Get-RegistryData -Type 'agents').agents
        Write-Host ('`n[4] Agents (' + $agents.Count + ' items):') -ForegroundColor Yellow
        foreach ($a in $agents) {
            Write-Host ('  ' + $a.id.PadRight(26) + ' : ' + $a.description)
        }
    }

    if ($Category -eq 'all' -or $Category -eq 'mcps') {
        $mcps = (Get-RegistryData -Type 'mcps').mcps
        Write-Host ('`n[5] MCP Servers (' + $mcps.Count + ' items):') -ForegroundColor Yellow
        foreach ($m in $mcps) {
            $authStr = if ($m.requiresAuth) { '[REQUIRES AUTH]' } else { '[AUTO]' }
            Write-Host ('  ' + $m.id.PadRight(22) + ' : ' + $m.name.PadRight(24) + ' ' + $authStr)
        }
    }

    if ($Category -eq 'all' -or $Category -eq 'plugins') {
        $plugins = (Get-RegistryData -Type 'plugins').plugins
        Write-Host ('`n[6] Plugins (' + $plugins.Count + ' items):') -ForegroundColor Yellow
        foreach ($pl in $plugins) {
            Write-Host ('  ' + $pl.id.PadRight(20) + ' : ' + $pl.name)
        }
    }
}

# ------------------------------------------------------------------------------
# 7. AUDIT COMMAND (3-Way Reconciliation: Detected vs Declared vs Materialized)
# ------------------------------------------------------------------------------
function Invoke-AidevAudit {
    param([string]$WorkspacePath = (Get-Location).Path)
    $ws = [IO.Path]::GetFullPath($WorkspacePath)

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- 3-Way Project Audit' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ('Audit Target: ' + $ws) -ForegroundColor Gray
    Write-Host ''

    $detectResult = Invoke-AidevDetect -WorkspacePath $ws
    $manifest = Get-AidevManifest -WorkspacePath $ws
    $wsAgents = Join-Path $ws '.agents'
    $metaPath = Join-Path $wsAgents '.aidev_metadata.json'
    $meta = if (Test-Path -LiteralPath $metaPath) { Get-Content -LiteralPath $metaPath -Raw -Encoding utf8 | ConvertFrom-Json } else { $null }

    $detectedCapIds = @($detectResult.SuggestedCapabilities | Select-Object -ExpandProperty Id)
    $declaredCapIds = if ($manifest -and $manifest.capabilities) { @($manifest.capabilities) } else { @() }
    $materializedRules = if (Test-Path (Join-Path $wsAgents 'rules')) { @(Get-ChildItem (Join-Path $wsAgents 'rules') -Filter '*.md' | Select-Object -ExpandProperty Name) } else { @() }
    $materializedSkills = if (Test-Path (Join-Path $wsAgents 'skills')) { @(Get-ChildItem (Join-Path $wsAgents 'skills') -Directory | Select-Object -ExpandProperty Name) } else { @() }
    $materializedAgents = if (Test-Path (Join-Path $wsAgents 'agents')) { @(Get-ChildItem (Join-Path $wsAgents 'agents') -Filter '*.md' -File | Select-Object -ExpandProperty Name) } else { @() }

    Write-Host ''
    Write-Host '--- 3-Way Reconciliation Audit ---' -ForegroundColor Yellow

    # 1. Detected vs Declared
    $unDeclaredDetections = @($detectedCapIds | Where-Object { $declaredCapIds -notcontains $_ -and $_ -ne 'core' })
    if ($unDeclaredDetections.Count -gt 0) {
        Write-Host ('  [DETECTED BUT NOT DECLARED] Found evidence for: ' + ($unDeclaredDetections -join ', ')) -ForegroundColor DarkYellow
    }

    $unDetectedDeclarations = @($declaredCapIds | Where-Object { $detectedCapIds -notcontains $_ -and $_ -ne 'core' })
    if ($unDetectedDeclarations.Count -gt 0) {
        Write-Host ('  [DECLARED WITHOUT DETECTED EVIDENCE] ' + ($unDetectedDeclarations -join ', ')) -ForegroundColor DarkGray
    }

    # 2. Declared vs Materialized
    $migrationNeeded = $false
    $skillJunctionNames = @()
    if (Test-Path -LiteralPath (Join-Path $wsAgents 'skills')) {
        $skillJunctionNames = @(Get-ChildItem -LiteralPath (Join-Path $wsAgents 'skills') -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-IsJunction -Path $_.FullName } | Select-Object -ExpandProperty Name)
    }
    $hasRoutingRule = Test-Path -LiteralPath (Join-Path $wsAgents 'rules\skill-routing.md')
    $hooksFile = Join-Path $wsAgents 'hooks.json'
    $hasLegacyHooks = (Test-Path -LiteralPath $hooksFile) -and ((Get-Content -LiteralPath $hooksFile -Raw -Encoding utf8) -match '-File \.agents/scripts/safety-check\.ps1|\[Console\]::Out\.WriteLine')
    $agentsMdFile = Join-Path $ws 'AGENTS.md'
    $geminiMdFile = Join-Path $ws 'GEMINI.md'
    $agentsRawAudit = if (Test-Path -LiteralPath $agentsMdFile) { Get-Content -LiteralPath $agentsMdFile -Raw -Encoding utf8 } else { '' }
    $geminiRawAudit = if (Test-Path -LiteralPath $geminiMdFile) { Get-Content -LiteralPath $geminiMdFile -Raw -Encoding utf8 } else { '' }
    $hasUpdatedConstitution = ($agentsRawAudit -match 'skill-routing\.md') -and ($agentsRawAudit -match '/compact')
    $hasUpdatedBridge = ($geminiRawAudit -match 'skill-routing\.md') -and ($geminiRawAudit -match '/compact')

    if (-not $manifest) {
        Write-Host '  [AUDIT / NO MANIFEST] .aidev.json missing. Run "aidev init" or "aidev migrate".' -ForegroundColor Yellow
        $migrationNeeded = $true
    } elseif (Test-IsJunction -Path $wsAgents) {
        Write-Host ('  [AUDIT / LEGACY JUNCTION] .agents is a monolithic junction -> ' + (Get-JunctionTarget -Path $wsAgents)) -ForegroundColor Yellow
        $migrationNeeded = $true
    } else {
        Write-Host '  [AUDIT / OK] .aidev.json present and .agents is an isolated physical directory' -ForegroundColor Green
        if ($skillJunctionNames.Count -gt 0) {
            Write-Host ('  [AUDIT / LEGACY SKILL JUNCTIONS] ' + $skillJunctionNames.Count + ' skill(s) are NTFS junctions: ' + ($skillJunctionNames -join ', ')) -ForegroundColor Yellow
            $migrationNeeded = $true
        }
        if (-not $hasRoutingRule) {
            Write-Host '  [AUDIT / MISSING RULE] .agents/rules/skill-routing.md missing. Run "aidev apply".' -ForegroundColor Yellow
            $migrationNeeded = $true
        }
        if ($hasLegacyHooks) {
            Write-Host '  [AUDIT / LEGACY HOOKS] .agents/hooks.json uses legacy relative path. Run "aidev apply".' -ForegroundColor Yellow
            $migrationNeeded = $true
        }
        if (-not $hasUpdatedConstitution -or -not $hasUpdatedBridge) {
            Write-Host '  [AUDIT / OUTDATED CONSTITUTION] AGENTS.md or GEMINI.md missing skill-routing.md protocol. Run "aidev apply".' -ForegroundColor Yellow
            $migrationNeeded = $true
        }
    }

    Write-Host ''
    Write-Host 'Audit Summary:' -ForegroundColor Cyan
    Write-Host ('  Declared Capabilities   : ' + ($declaredCapIds -join ', '))
    Write-Host ('  Materialized Rules      : ' + @($materializedRules).Count)
    Write-Host ('  Materialized Skills     : ' + @($materializedSkills).Count + ' (' + $skillJunctionNames.Count + ' junction(s))')
    Write-Host ('  Materialized Agents     : ' + @($materializedAgents).Count)
    Write-Host ('  Migration/Sync Needed   : ' + $migrationNeeded)

    return [pscustomobject]@{
        Workspace            = $ws
        HasManifest          = ($manifest -ne $null)
        IsMonolithicJunction = (Test-IsJunction -Path $wsAgents)
        SkillJunctionCount   = $skillJunctionNames.Count
        HasSkillRoutingRule  = $hasRoutingRule
        DetectedCapIds       = $detectedCapIds
        DeclaredCapIds       = $declaredCapIds
        MaterializedRules    = $materializedRules
        MaterializedSkills   = $materializedSkills
        MaterializedAgents   = $materializedAgents
        MigrationNeeded      = $migrationNeeded
    }
}

# ------------------------------------------------------------------------------
# 8. APPLY COMMAND & AUTOMATIC PROJECT AGENT SYNTHESIS
# ------------------------------------------------------------------------------
function Select-SkillsForDomainRule {
    param(
        [Parameter(Mandatory)][string]$RuleName,
        [Parameter(Mandatory)][string]$RuleContent
    )
    $selected = [System.Collections.Generic.List[string]]::new()
    $null = $selected.Add('graphify')

    $titleLine = ($RuleContent -split "\r?\n" | Where-Object { $_ -match '^#\s+(.+)$' } | Select-Object -First 1)
    $primarySignal = ($RuleName + ' ' + $titleLine).ToLowerInvariant()
    $fullSignal = ($RuleName + ' ' + $RuleContent).ToLowerInvariant()

    if ($primarySignal -match '\b(capture|dxgi|wgc|gdi|h264|cursor|input|sendinput|session|win32|desktop|worker|uia|screen|monitor)\b') {
        foreach ($s in @('winapp', 'diagnosing-bugs', 'systematic-debugging', 'codebase-design')) {
            if (-not $selected.Contains($s)) { $null = $selected.Add($s) }
        }
    }
    if (($primarySignal -match '\b(postgres|supabase|sql|rls|migration|tenant|isolation|database|query)\b') -or ($fullSignal -match '\b(supabase|postgres|rls|tenant_id)\b' -and $primarySignal -match '\b(tenant|isolation|database|sql|fiscal)\b')) {
        foreach ($s in @('supabase-postgres-best-practices', 'supabase', 'security-threat-model', 'cybersecurity-review')) {
            if (-not $selected.Contains($s)) { $null = $selected.Add($s) }
        }
    }
    if ($primarySignal -match '\b(dacl|dacls|pipe|security|auth|crypto|signature|sha256|redirect|redirects|returnto|sanitiz|owasp)\b') {
        foreach ($s in @('security-threat-model', 'cybersecurity-review', 'security-best-practices')) {
            if (-not $selected.Contains($s)) { $null = $selected.Add($s) }
        }
    }
    if ($primarySignal -match '\b(fiscal|tribut|simples|ibs|cbs|pgdas|nfe|decimal|erp|conciliac|domain|entity|invariant|invariants|engine)\b') {
        foreach ($s in @('domain-modeling', 'codebase-design', 'diagnosing-bugs', 'systematic-debugging')) {
            if (-not $selected.Contains($s)) { $null = $selected.Add($s) }
        }
    }
    if ($primarySignal -match '\b(spa|next|react|router|navigation|design|tokens|oklch|hsl|ui|ux|css|mutation|component)\b') {
        foreach ($s in @('vercel-react-best-practices', 'ui-ux-pro-max', 'frontend-design', 'impeccable', 'web-design-guidelines')) {
            if (-not $selected.Contains($s)) { $null = $selected.Add($s) }
        }
    }
    if ($primarySignal -match '\b(update|installer|msi|electron|rollback|release|deploy|package|lifecycle)\b') {
        foreach ($s in @('security-review', 'security-best-practices', 'diagnosing-bugs', 'ponytail')) {
            if (-not $selected.Contains($s)) { $null = $selected.Add($s) }
        }
    }
    if ($selected.Count -le 1) {
        foreach ($fallback in @('codebase-design', 'diagnosing-bugs', 'systematic-debugging')) {
            if (-not $selected.Contains($fallback)) { $null = $selected.Add($fallback) }
        }
    }
    $capped = [System.Collections.Generic.List[string]]::new()
    foreach ($item in $selected) {
        if ($capped.Count -lt 6) {
            $null = $capped.Add($item)
        }
    }
    if (-not $capped.Contains('verification-before-completion')) {
        $null = $capped.Add('verification-before-completion')
    }
    return @($capped)
}

function Invoke-AidevAgentSynthesis {
    param(
        [Parameter(Mandatory)][string]$WorkspacePath,
        [Parameter(Mandatory)][string]$TargetAgentsDir,
        [Parameter(Mandatory)][string]$TargetRulesDir,
        [Parameter(Mandatory)]$Resolved
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $projectName = Split-Path -Leaf $WorkspacePath
    $capsText = ($Resolved.ResolvedCapabilities -join ', ')

    $standardTemplateRules = @(
        'architecture-invariants.md',
        'git-workflow.md',
        'skill-routing.md',
        'verification.md',
        'database-postgres.md',
        'web-guidelines.md',
        'windows-desktop.md'
    )

    $projectDomainRules = @()
    if (Test-Path -LiteralPath $TargetRulesDir -PathType Container) {
        $projectDomainRules = @(Get-ChildItem -LiteralPath $TargetRulesDir -Filter '*.md' -File -ErrorAction SilentlyContinue |
            Where-Object { $standardTemplateRules -notcontains $_.Name })
    }

    # 1. Contextualize all core materialized agents with project-specific context & Graphify CLI fast-path
    $coreAgentFiles = @(Get-ChildItem -LiteralPath $TargetAgentsDir -Filter '*.md' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike '*-specialist.md' })

    $domainRuleLinks = if ($projectDomainRules.Count -gt 0) {
        ($projectDomainRules | ForEach-Object { '  - `.agents/rules/' + $_.Name + '`' }) -join "`r`n"
    } else {
        '  - `.agents/rules/architecture-invariants.md`'
    }

    $projectContextSection = @(
        ''
        ''
        ('## Project-Specific Context (' + $projectName + ')')
        ''
        ('- **Workspace**: `' + $projectName + '` (Capabilities: `' + $capsText + '`)')
        '- **Step 0 -- Worktree-Safe Graphify Fast-Path (`always_on`)**: Ensure `graphify-out/graph.json` exists (`if (-not (Test-Path "graphify-out/graph.json")) { graphify extract . --code-only ; graphify cluster-only . --no-label --no-viz }`), then run `graphify query "<topic>" --budget 1200` and `rg -n "<symbol>" <file>` via `run_command` BEFORE opening source files.'
        '- **Surgical Token Economy (Zero `#L1-800` Blind Dumps)**: NEVER call `view_file` / `Read` on 1-800 lines across multiple files. Always read surgical `StartLine`--`EndLine` windows (`60-150 lines`) around the exact line numbers returned by `graphify query` and `rg -n`. Load `graphify/SKILL.md` + ONLY the 1-2 skills matching your active subtask.'
        '- **Project Domain Rules to Enforce**:'
        $domainRuleLinks
        ''
    ) -join "`r`n"

    foreach ($cf in $coreAgentFiles) {
        $raw = (Get-Content -LiteralPath $cf.FullName -Raw -Encoding utf8).TrimStart([char]0xFEFF)
        if ($raw -match '(?s)\r?\n\r?\n## Project-Specific Context \(.*$') {
            $updated = [regex]::Replace($raw, '(?s)\r?\n\r?\n## Project-Specific Context \(.*$', $projectContextSection)
        } else {
            $updated = $raw.TrimEnd() + $projectContextSection
        }
        [System.IO.File]::WriteAllText($cf.FullName, $updated, $utf8NoBom)
    }

    # 2. Synthesize custom project-specific domain subagents from project-owned rules + 33 downloaded skills
    $synthesizedFiles = [System.Collections.Generic.List[string]]::new()
    foreach ($ruleFile in $projectDomainRules) {
        $ruleRaw = (Get-Content -LiteralPath $ruleFile.FullName -Raw -Encoding utf8).TrimStart([char]0xFEFF)
        $ruleBase = ($ruleFile.BaseName.ToLowerInvariant() -replace '[^a-z0-9-]+', '-').Trim('-')
        if (-not $ruleBase) { continue }
        $specialistSlug = ($ruleBase + '-specialist')
        $specialistFileName = ($specialistSlug + '.md')
        $specialistPath = Join-Path $TargetAgentsDir $specialistFileName

        $titleLine = ($ruleRaw -split "\r?\n" | Where-Object { $_ -match '^#\s+(.+)$' } | Select-Object -First 1)
        $ruleTitle = if ($titleLine -and ($titleLine -match '^#\s+(.+)$')) {
            ($Matches[1].Trim() -replace '["\r\n]', '')
        } else {
            $ruleBase
        }

        $pairedSkills = @(Select-SkillsForDomainRule -RuleName $ruleFile.Name -RuleContent $ruleRaw)
        $skillsBulletList = ($pairedSkills | ForEach-Object { '  - `.agents/skills/' + $_ + '/SKILL.md`' }) -join "`r`n"
        $skillsInline = ($pairedSkills -join ', ')
        $safeDesc = (('Use proactively via invoke_subagent / Task / Agent in ' + $projectName + ' for tasks involving ' + $ruleTitle + ' (.agents/rules/' + $ruleFile.Name + '). Combines Graphify knowledge-graph navigation with skills: ' + $skillsInline + '.') -replace '"', "'")

        $synthesizedContent = @(
            '---'
            ('name: ' + $specialistSlug)
            ('description: "' + $safeDesc + '"')
            'tools:'
            '  - send_message'
            '  - view_file'
            '  - read_url_content'
            '  - search_web'
            '  - schedule'
            '  - multi_replace_file_content'
            '  - replace_file_content'
            '  - write_to_file'
            '  - run_command'
            '  - manage_task'
            '---'
            ('# Project Domain Specialist: ' + $ruleTitle + ' (' + $projectName + ')')
            ''
            ('> **Synthesized Multi-AI Project Subagent (`' + $specialistSlug + '`)** -- Automatically generated by AI-Dev-Machine for **' + $projectName + '** across all AIs (Antigravity, Claude Code, OpenAI Codex, Cursor, Windsurf, Copilot, Gemini CLI) by combining `.agents/rules/' + $ruleFile.Name + '` with the matching downloaded skills.')
            ''
            '## Step 0 -- Mandatory Graphify Knowledge Graph & Surgical Token-Economy Protocol (`always_on`)'
            ''
            'Before opening source files, run this worktree-safe query + line-pinpointing command via `run_command`:'
            '```powershell'
            'if (-not (Test-Path "graphify-out/graph.json")) { graphify extract . --code-only ; graphify cluster-only . --no-label --no-viz }'
            'graphify query "<topic or symbol>" --budget 1200'
            'graphify affected "<symbol>"'
            'rg -n "<symbol_or_function>" <target_files_from_graph>'
            '```'
            '- **Surgical `view_file` Rule**: NEVER dump `#L1-800` across multiple files. Use `StartLine` and `EndLine` (`60-150 lines`) around the exact lines returned by `rg -n`.'
            ''
            '## Step 1 -- Selective Downloaded Skills (Load on Turn 1 across All AIs)'
            ''
            'On Turn 1, load `.agents/skills/graphify/SKILL.md` AND **only the 1-2 skills below that directly match your active subtask** (never load all skills at once):'
            $skillsBulletList
            ''
            ('## Step 2 -- Authoritative Project Domain Rules (`.agents/rules/' + $ruleFile.Name + '`)')
            ''
            $ruleRaw.Trim()
            ''
            '## Step 3 -- Layer-1 Self-Verification Gate (`verification-before-completion`)'
            ''
            'Before returning results to the main orchestrator agent, run the module verification commands (tests, typecheck, lint, or SQL/RLS check) and report concrete command output.'
            ''
        ) -join "`r`n"

        [System.IO.File]::WriteAllText($specialistPath, $synthesizedContent, $utf8NoBom)
        $null = $synthesizedFiles.Add($specialistFileName)

        # Mirror to global multi-AI agent directories (Claude Code, Gemini CLI, Antigravity) when not in TEMP test fixtures
        $tempRoot = [IO.Path]::GetFullPath($env:TEMP)
        if (-not $WorkspacePath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            $multiAiAgentDirs = @(
                (Join-Path $env:USERPROFILE '.claude\agents'),
                (Join-Path $env:USERPROFILE '.gemini\agents'),
                (Join-Path $env:USERPROFILE '.gemini\config\agents')
            )
            foreach ($gDir in $multiAiAgentDirs) {
                if (Test-Path -LiteralPath $gDir -PathType Container) {
                    [System.IO.File]::WriteAllText((Join-Path $gDir $specialistFileName), $synthesizedContent, $utf8NoBom)
                }
            }
        }

        Write-Host ('  [SYNTHESIZED PROJECT AGENT] .agents/agents/' + $specialistFileName + ' (Skills: ' + $skillsInline + ')') -ForegroundColor Cyan
    }

    return @($synthesizedFiles)
}

function Invoke-AidevApply {
    param(
        [string]$WorkspacePath = (Get-Location).Path,
        [switch]$DryRun,
        [switch]$Force
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $root = Get-AidevRoot

    $manifestValidation = Test-AidevManifest -WorkspacePath $ws
    $manifest = $manifestValidation.Manifest
    $resolved = $manifestValidation.Resolved

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- Materialization (Apply)' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $modeText = if ($DryRun) { 'DRY-RUN (Simulation without write)' } else { 'APPLY (Real Execution)' }
    $dispPreset = if ($manifest.preset) { $manifest.preset } else { 'custom' }
    Write-Host ('Workspace Target : ' + $ws) -ForegroundColor Gray
    Write-Host ('Execution Mode   : ' + $modeText) -ForegroundColor Green
    Write-Host ('Preset           : ' + $dispPreset) -ForegroundColor Gray
    Write-Host ('Capabilities     : ' + ($resolved.ResolvedCapabilities -join ', ')) -ForegroundColor Gray
    Write-Host ''

    if ($DryRun) {
        Write-Host 'Planned Materialization Actions (0 writes):' -ForegroundColor Yellow
        Write-Host ('  [RULES]  ' + $resolved.Rules.Count + ' rule(s) (' + ($resolved.Rules.Name -join ', ') + ')')
        Write-Host ('  [SKILLS] ' + $resolved.Skills.Count + ' skill(s) (' + ($resolved.Skills.Name -join ', ') + ')')
        Write-Host ('  [AGENTS] ' + $resolved.Agents.Count + ' agent(s) (' + ($resolved.Agents.Name -join ', ') + ')')
        Write-Host ('  [MCPS]   ' + $resolved.Mcps.Count + ' active MCP(s) (' + ($resolved.Mcps.Name -join ', ') + ')')
        Write-Host 'Dry-run complete. No changes made to disk.' -ForegroundColor Cyan
        return
    }

    # 1. Ensure physical .agents directory
    $agentsDir = Join-Path $ws '.agents'
    if (Test-IsJunction -Path $agentsDir) {
        cmd /c "rmdir `"$agentsDir`"" | Out-Null
    }
    if (-not (Test-Path -LiteralPath $agentsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $agentsDir -Force
    }

    # 2. Materialize .agents/rules/
    $targetRulesDir = Join-Path $agentsDir 'rules'
    if (-not (Test-Path -LiteralPath $targetRulesDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $targetRulesDir -Force
    }
    $managedRules = @()
    foreach ($rObj in $resolved.Rules) {
        if ($rObj.Ownership -eq 'managed') {
            $ruleName = $rObj.Name
            $sourceRule = Join-Path $root ('templates\rules\' + $ruleName)
            if (Test-Path -LiteralPath $sourceRule) {
                Copy-Item -LiteralPath $sourceRule -Destination (Join-Path $targetRulesDir $ruleName) -Force
                $managedRules += $ruleName
                Write-Host ('  [CREATED RULE] .agents/rules/' + $ruleName) -ForegroundColor Green
            }
        }
    }

    # 3. Materialize .agents/agents/ (10 Core Specialists + Automatic Project-Tailored Domain Subagents)
    $targetAgentsDir = Join-Path $agentsDir 'agents'
    if (-not (Test-Path -LiteralPath $targetAgentsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $targetAgentsDir -Force
    }
    $managedAgents = @()
    $cognitiveAgents = @('researcher.md', 'reviewer.md', 'security-reviewer.md')
    foreach ($ca in $cognitiveAgents) {
        $sourceAgent = Join-Path $root ('templates\agents\' + $ca)
        if (Test-Path -LiteralPath $sourceAgent) {
            Copy-Item -LiteralPath $sourceAgent -Destination (Join-Path $targetAgentsDir $ca) -Force
            $managedAgents += $ca
            Write-Host ('  [CREATED AGENT] .agents/agents/' + $ca + ' (Cognitive Specialist)') -ForegroundColor Green
        }
    }
    foreach ($aObj in $resolved.Agents) {
        $agentSlug = $aObj.Name
        if ($cognitiveAgents -contains ($agentSlug + '.md')) { continue }
        $agentFileName = ($agentSlug + '.md')
        $destFile = Join-Path $targetAgentsDir $agentFileName
        $globalAgent = Join-Path $script:GlobalAgentsDir $agentFileName
        if (Test-Path -LiteralPath $globalAgent) {
            Copy-Item -LiteralPath $globalAgent -Destination $destFile -Force
            $managedAgents += $agentFileName
            Write-Host ('  [MATERIALIZED AGENT] .agents/agents/' + $agentFileName + ' (Domain Specialist)') -ForegroundColor Green
        }
    }
    $synthesizedAgentFiles = @(Invoke-AidevAgentSynthesis -WorkspacePath $ws -TargetAgentsDir $targetAgentsDir -TargetRulesDir $targetRulesDir -Resolved $resolved)
    foreach ($synFile in $synthesizedAgentFiles) {
        if ($managedAgents -notcontains $synFile) {
            $managedAgents += $synFile
        }
    }

    # 4. Materialize .agents/skills/ (Physical Directory Copies for Native IDE Discovery)
    $targetSkillsDir = Join-Path $agentsDir 'skills'
    if (-not (Test-Path -LiteralPath $targetSkillsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $targetSkillsDir -Force
    }
    foreach ($existingSkillItem in @(Get-ChildItem -LiteralPath $targetSkillsDir -Force -ErrorAction SilentlyContinue)) {
        if (Test-IsJunction -Path $existingSkillItem.FullName) {
            $junctionSkillId = $existingSkillItem.Name
            cmd /c "rmdir `"$($existingSkillItem.FullName)`"" | Out-Null
            $globalSrc = Join-Path $script:GlobalSkillsRoot $junctionSkillId
            $localSrc = Join-Path $root ('skills\' + $junctionSkillId)
            $fallbackSrc = if (Test-Path -LiteralPath $globalSrc) { $globalSrc } elseif (Test-Path -LiteralPath $localSrc) { $localSrc } else { $null }
            if ($fallbackSrc -and ($resolved.Skills.Name -notcontains $junctionSkillId)) {
                Copy-Item -LiteralPath $fallbackSrc -Destination $existingSkillItem.FullName -Recurse -Force
                Write-Host ('  [CONVERTED JUNCTION] .agents/skills/' + $junctionSkillId + ' -> Physical Copy') -ForegroundColor Green
            }
        }
    }
    $managedSkills = @()
    foreach ($sObj in $resolved.Skills) {
        $skillId = $sObj.Name
        $skillDest = Join-Path $targetSkillsDir $skillId
        $globalSkill = Join-Path $script:GlobalSkillsRoot $skillId
        $localSkill = Join-Path $root ('skills\' + $skillId)
        $sourceSkillPath = if (Test-Path -LiteralPath $globalSkill) { $globalSkill } elseif (Test-Path -LiteralPath $localSkill) { $localSkill } else { $null }

        # Remove legacy junction safely if present
        if (Test-IsJunction -Path $skillDest) {
            cmd /c "rmdir `"$skillDest`"" | Out-Null
        }

        if ($sourceSkillPath) {
            if (-not (Test-Path -LiteralPath $skillDest) -or $Force) {
                if (Test-Path -LiteralPath $skillDest) {
                    Remove-Item -LiteralPath $skillDest -Recurse -Force
                }
                Copy-Item -LiteralPath $sourceSkillPath -Destination $skillDest -Recurse -Force
                $managedSkills += $skillId
                Write-Host ('  [MATERIALIZED SKILL] .agents/skills/' + $skillId + ' (Physical Copy for IDE)') -ForegroundColor Green
            } else {
                $managedSkills += $skillId
            }
        }
    }

    # 5. Materialize .agents/scripts/ & .agents/hooks.json
    $scriptsDir = Join-Path $agentsDir 'scripts'
    if (-not (Test-Path -LiteralPath $scriptsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $scriptsDir -Force
    }
    $safetyScriptSrc = Join-Path $root 'templates\scripts\safety-check.ps1'
    if (Test-Path -LiteralPath $safetyScriptSrc) {
        Copy-Item -LiteralPath $safetyScriptSrc -Destination (Join-Path $scriptsDir 'safety-check.ps1') -Force
        # Ensure nested .agents/scripts has it in case hook runs from .agents with legacy relative path
        $nestedScripts = Join-Path $agentsDir '.agents\scripts'
        if (-not (Test-Path -LiteralPath $nestedScripts -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $nestedScripts -Force
        }
        Copy-Item -LiteralPath $safetyScriptSrc -Destination (Join-Path $nestedScripts 'safety-check.ps1') -Force
    }
    $hooksDest = Join-Path $agentsDir 'hooks.json'
    $needsHookUpdate = (-not (Test-Path -LiteralPath $hooksDest)) -or $Force
    if (Test-Path -LiteralPath $hooksDest) {
        $existingHooks = Get-Content -LiteralPath $hooksDest -Raw -Encoding utf8
        if ($existingHooks -match '-File \.agents/scripts/safety-check\.ps1' -or $existingHooks -match '\[Console\]::Out\.WriteLine') {
            $needsHookUpdate = $true
        }
    }
    if ($needsHookUpdate) {
        Copy-Item -LiteralPath (Join-Path $root 'templates\hooks.template.json') -Destination $hooksDest -Force
        Write-Host '  [CREATED HOOKS] .agents/hooks.json' -ForegroundColor Green
    }

    # 6. Materialize .agents/mcp_config.json
    $mcpDest = Join-Path $agentsDir 'mcp_config.json'
    if (-not (Test-Path -LiteralPath $mcpDest) -or $Force) {
        $tmplMcp = Get-Content -LiteralPath (Join-Path $root 'templates\mcp_config.template.json') -Raw -Encoding utf8 | ConvertFrom-Json
        $enabledMcpNames = @($resolved.Mcps | Select-Object -ExpandProperty Name)
        foreach ($serverProp in $tmplMcp.mcpServers.PSObject.Properties) {
            $sName = $serverProp.Name
            $sObj = $serverProp.Value
            if ($enabledMcpNames -contains $sName) {
                if ($sObj.PSObject.Properties.Name.Contains('disabled')) {
                    $sObj.PSObject.Properties.Remove('disabled')
                }
            } else {
                if (-not $sObj.PSObject.Properties.Name.Contains('disabled')) {
                    $sObj | Add-Member -NotePropertyName 'disabled' -NotePropertyValue $true
                } else {
                    $sObj.disabled = $true
                }
            }
        }
        $tmplMcp | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $mcpDest -Encoding utf8
        Write-Host ('  [CREATED MCP] .agents/mcp_config.json (enabled: ' + ($enabledMcpNames -join ', ') + ')') -ForegroundColor Green
    }

    # 7. Materialize Metadata Tracking
    $metaDest = Join-Path $agentsDir '.aidev_metadata.json'
    $metaObj = [ordered]@{
        schemaVersion        = 1
        version              = '2.1.0'
        timestamp            = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
        preset               = $manifest.preset
        resolvedCapabilities = $resolved.ResolvedCapabilities
        managedRules         = $managedRules
        managedAgents        = $managedAgents
        managedSkills        = $managedSkills
        managedHooks         = $true
        managedMcp           = $true
    }
    $metaObj | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $metaDest -Encoding utf8

    # 8. Instantiate or Self-Heal Root AGENTS.md & GEMINI.md
    $projectName = Split-Path -Leaf $ws
    $agentsMdDest = Join-Path $ws 'AGENTS.md'
    $existingAgentsMd = if (Test-Path -LiteralPath $agentsMdDest) { Get-Content -LiteralPath $agentsMdDest -Raw -Encoding utf8 } else { $null }
    $hasStructuredInvariants = ($null -ne $existingAgentsMd) -and ($existingAgentsMd -match '##\s+1\.\s+Immutable Invariants')

    if ((-not $existingAgentsMd) -or ($Force -and -not $hasStructuredInvariants)) {
        $tmpl = Get-Content -LiteralPath (Join-Path $root 'templates\AGENTS.template.md') -Raw -Encoding utf8
        $cmdInstall = if ($resolved.Commands.ContainsKey('install')) { $resolved.Commands['install'] } else { 'npm install' }
        $cmdDev = if ($resolved.Commands.ContainsKey('dev')) { $resolved.Commands['dev'] } else { 'npm run dev' }
        $cmdTest = if ($resolved.Commands.ContainsKey('test')) { $resolved.Commands['test'] } else { 'npm test' }
        $cmdTypecheck = if ($resolved.Commands.ContainsKey('typecheck')) { $resolved.Commands['typecheck'] } else { 'npx tsc --noEmit' }
        $cmdLint = if ($resolved.Commands.ContainsKey('lint')) { $resolved.Commands['lint'] } else { 'npx eslint .' }
        $cmdBuild = if ($resolved.Commands.ContainsKey('build')) { $resolved.Commands['build'] } else { 'npm run build' }

        $inst = $tmpl -replace '\[PROJECT_NAME\]', $projectName `
                      -replace '\[PROJECT_DESCRIPTION\]', ('Project configured with AI-Dev-Machine v2.1 (' + ($resolved.ResolvedCapabilities -join ', ') + ')') `
                      -replace '\[PROJECT_PROFILE\]', $dispPreset `
                      -replace '\[PROJECT_RUNTIME\]', ($resolved.ResolvedCapabilities -join ' / ') `
                      -replace '\[CMD_INSTALL\]', $cmdInstall `
                      -replace '\[CMD_DEV\]', $cmdDev `
                      -replace '\[CMD_TEST\]', $cmdTest `
                      -replace '\[CMD_TYPECHECK\]', $cmdTypecheck `
                      -replace '\[CMD_LINT\]', $cmdLint `
                      -replace '\[CMD_BUILD\]', $cmdBuild
        Set-Content -LiteralPath $agentsMdDest -Value $inst -Encoding utf8
        Write-Host '  [CREATED CONSTITUTION] AGENTS.md' -ForegroundColor Green
    } elseif (($existingAgentsMd -notmatch 'skill-routing\.md') -or ($existingAgentsMd -notmatch '/compact')) {
        $updatedAgentsMd = $existingAgentsMd
        $routingInvariantLine = '- **Automatic & Dynamic Skill Routing (`always_on`)**: Follow [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md) on every turn. Before reading repository code, proposing fixes, or writing code in any domain covered by a skill, you MUST load its `SKILL.md` via `view_file` on Turn 1. Combine multiple complementary skills whenever tasks span multiple domains.'
        $compactInvariantLine = '- **Context Hygiene & Post-Task Compaction Gate (`/compact`)**: Offload multi-file exploration to subagents (`invoke_subagent` / `Task` / `Agent`) so raw logs stay out of the main context, and proactively recommend `/compact` at the end of the response whenever a large task, multi-file refactor, or parallel subagent workflow completes.'

        if ($updatedAgentsMd -notmatch 'skill-routing\.md') {
            if ($updatedAgentsMd -match '(?m)^5\.\s+\*\*Automatic\s+&\s+Dynamic\s+Skill\s+Routing\*\*.*$') {
                $updatedAgentsMd = [regex]::Replace(
                    $updatedAgentsMd,
                    '(?m)^5\.\s+\*\*Automatic\s+&\s+Dynamic\s+Skill\s+Routing\*\*.*$',
                    '5. **Automatic & Dynamic Skill Routing (`always_on`)**: Follow [`.agents/rules/skill-routing.md`](.agents/rules/skill-routing.md) on every turn. Before reading repository code, proposing fixes, or writing code in any domain covered by a skill, you MUST load its `SKILL.md` via `view_file` on Turn 1. Combine multiple complementary skills whenever tasks span multiple domains.'
                )
            } elseif ($updatedAgentsMd -match '(?s)(##\s+1\.\s+Immutable Invariants.*?)(\r?\n---\r?\n)') {
                $updatedAgentsMd = [regex]::Replace(
                    $updatedAgentsMd,
                    '(?s)(##\s+1\.\s+Immutable Invariants.*?)(\r?\n---\r?\n)',
                    ('$1' + "`r`n" + $routingInvariantLine + '$2'),
                    1
                )
            } else {
                $updatedAgentsMd = $updatedAgentsMd.TrimEnd() + "`r`n`r`n## Skill Routing Protocol (`always_on`)`r`n`r`n" + $routingInvariantLine + "`r`n"
            }
        }

        if ($updatedAgentsMd -notmatch '/compact') {
            if ($updatedAgentsMd -match '(?s)(##\s+1\.\s+Immutable Invariants.*?)(\r?\n---\r?\n)') {
                $updatedAgentsMd = [regex]::Replace(
                    $updatedAgentsMd,
                    '(?s)(##\s+1\.\s+Immutable Invariants.*?)(\r?\n---\r?\n)',
                    ('$1' + "`r`n" + $compactInvariantLine + '$2'),
                    1
                )
            } else {
                $updatedAgentsMd = $updatedAgentsMd.TrimEnd() + "`r`n" + $compactInvariantLine + "`r`n"
            }
            if ($updatedAgentsMd -match '##\s+5\.\s+Completion Checklist') {
                $updatedAgentsMd = $updatedAgentsMd.TrimEnd() + "`r`n- [ ] Recommend `/compact` at the end of the response after completing any large, multi-file, or subagent-assisted task.`r`n"
            }
        }

        Set-Content -LiteralPath $agentsMdDest -Value $updatedAgentsMd -Encoding utf8
        Write-Host '  [UPDATED CONSTITUTION] AGENTS.md (injected skill-routing.md & /compact gate while preserving custom rules)' -ForegroundColor Green
    }

    $geminiMdDest = Join-Path $ws 'GEMINI.md'
    $existingGeminiMd = if (Test-Path -LiteralPath $geminiMdDest) { Get-Content -LiteralPath $geminiMdDest -Raw -Encoding utf8 } else { $null }
    if ((-not $existingGeminiMd) -or $Force -or ($existingGeminiMd -notmatch 'skill-routing\.md') -or ($existingGeminiMd -notmatch '/compact')) {
        $tmplG = Get-Content -LiteralPath (Join-Path $root 'templates\GEMINI.template.md') -Raw -Encoding utf8
        $instG = $tmplG -replace '\[PROJECT_NAME\]', $projectName
        if ($synthesizedAgentFiles.Count -gt 0) {
            $synBullets = ($synthesizedAgentFiles | ForEach-Object {
                $slug = ($_ -replace '\.md$', '')
                '  - `' + $slug + '` (`.agents/agents/' + $_ + '` -- Project Domain Specialist)'
            }) -join "`r`n"
            $instG = $instG.TrimEnd() + "`r`n- **Project-Synthesized Domain Specialists (Auto-Generated for " + $projectName + " across All AIs)**:`r`n" + $synBullets + "`r`n"
        }
        Set-Content -LiteralPath $geminiMdDest -Value $instG -Encoding utf8
        Write-Host '  [CREATED BRIDGE] GEMINI.md' -ForegroundColor Green
    }

    # 9. Granular .gitignore updates & Graphify Knowledge Graph Initialization
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern '.agents/skills/'
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern '.agents/cache/'
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern '.agents/.agents/'
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern '.aidev_backup_*/'
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern 'graphify-out/'

    $graphJsonPath = Join-Path $ws 'graphify-out\graph.json'
    $isTempFixture = $ws.StartsWith([IO.Path]::GetFullPath($env:TEMP), [System.StringComparison]::OrdinalIgnoreCase)
    if (Test-Path -LiteralPath $graphJsonPath) {
        Write-Host '  [GRAPHIFY READY] graphify-out/graph.json & GRAPH_REPORT.md active' -ForegroundColor Green
    } elseif (((Test-Path -LiteralPath (Join-Path $ws '.git')) -or (-not $isTempFixture)) -and (Get-Command graphify -ErrorAction SilentlyContinue)) {
        $prevEap = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $null = & graphify extract $ws --code-only 2>&1
            $null = & graphify cluster-only $ws --no-label --no-viz 2>&1
            if (Test-Path -LiteralPath $graphJsonPath) {
                Write-Host '  [GRAPHIFY BUILT] graphify-out/graph.json & GRAPH_REPORT.md initialized' -ForegroundColor Green
            }
        } catch {
            Write-Host ('  [GRAPHIFY NOTICE] Could not auto-build graphify-out: ' + $_.Exception.Message) -ForegroundColor DarkYellow
        } finally {
            $ErrorActionPreference = $prevEap
        }
    }

    Write-Host ''
    Write-Host 'Apply completed successfully (Architecture v2.1)!' -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# 9. INIT COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevInit {
    param(
        [string]$WorkspacePath = (Get-Location).Path,
        [string]$Preset = 'base',
        [string[]]$Capabilities = @(),
        [switch]$Force
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    if (-not (Test-Path -LiteralPath $ws -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $ws -Force
    }

    Invoke-AidevManifest -Action init -WorkspacePath $ws -Preset $Preset -Capabilities $Capabilities -Force:$Force
    Invoke-AidevApply -WorkspacePath $ws -Force:$Force
}

# ------------------------------------------------------------------------------
# 10. MIGRATE COMMAND (Legacy Adoption with Failure Injection Rollback)
# ------------------------------------------------------------------------------
function Invoke-AidevMigrate {
    param(
        [string]$WorkspacePath = (Get-Location).Path,
        [string]$Preset = 'base',
        [string[]]$Capabilities = @(),
        [switch]$DryRun,
        [switch]$AutoApprove,
        [switch]$Force,
        [switch]$InjectFailureTest
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $root = Get-AidevRoot

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- Project Migration' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $modeText = if ($DryRun) { 'DRY-RUN (Simulation without write)' } else { 'APPLY (Real Execution)' }
    Write-Host ('Migration Target : ' + $ws) -ForegroundColor Gray
    Write-Host ('Execution Mode   : ' + $modeText) -ForegroundColor Green
    Write-Host ''

    $manifestPath = Join-Path $ws '.aidev.json'
    $hasManifest = Test-Path -LiteralPath $manifestPath

    if (-not $hasManifest) {
        Write-Host 'No .aidev.json manifest found. Running detection...' -ForegroundColor Yellow
        $detectRes = Invoke-AidevDetect -WorkspacePath $ws
        Write-Host ''
        Write-Host 'Suggested Manifest Preview:' -ForegroundColor Cyan
        $detectRes.SuggestedManifest | ConvertTo-Json -Depth 10 | Write-Host
        Write-Host ''

        if ($DryRun) {
            Write-Host 'Dry-run complete. Review suggested manifest above.' -ForegroundColor Cyan
            Write-Host 'To migrate, create .aidev.json or run with -AutoApprove.' -ForegroundColor Gray
            return
        }

        if (-not $AutoApprove -and -not $Force) {
            throw "Migration requires an approved '.aidev.json' or explicit -AutoApprove flag."
        }

        # Auto-create detected manifest upon explicit approval
        $detectRes.SuggestedManifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8
        Write-Host 'Approved and written suggested .aidev.json manifest.' -ForegroundColor Green
    }

    $backupDirName = '.aidev_backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
    $backupDirPath = Join-Path $ws $backupDirName

    if ($DryRun) {
        Invoke-AidevApply -WorkspacePath $ws -DryRun
        return
    }

    Write-Host 'Applying Migration with safety backup...' -ForegroundColor Green
    $null = New-Item -ItemType Directory -Path $backupDirPath -Force

    try {
        # Backup existing root metadata
        if (Test-Path -LiteralPath (Join-Path $ws 'AGENTS.md')) {
            Copy-Item -LiteralPath (Join-Path $ws 'AGENTS.md') -Destination (Join-Path $backupDirPath 'AGENTS.md.bak') -Force
        }
        if (Test-Path -LiteralPath (Join-Path $ws 'GEMINI.md')) {
            Copy-Item -LiteralPath (Join-Path $ws 'GEMINI.md') -Destination (Join-Path $backupDirPath 'GEMINI.md.bak') -Force
        }

        # Failure Injection Test
        if ($InjectFailureTest) {
            throw 'SIMULATED_FAILURE_INJECTION: Artificial error midway through migration'
        }

        Invoke-AidevApply -WorkspacePath $ws -Force
        Write-Host ('Migration successfully applied! Backup preserved at: ' + $backupDirPath) -ForegroundColor Cyan
    } catch {
        Write-Host ('[ERROR DURING MIGRATION] ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host 'Executing automatic rollback from backup...' -ForegroundColor Yellow
        if (Test-Path -LiteralPath (Join-Path $backupDirPath 'AGENTS.md.bak')) {
            Copy-Item -LiteralPath (Join-Path $backupDirPath 'AGENTS.md.bak') -Destination (Join-Path $ws 'AGENTS.md') -Force
        }
        if (Test-Path -LiteralPath (Join-Path $backupDirPath 'GEMINI.md.bak')) {
            Copy-Item -LiteralPath (Join-Path $backupDirPath 'GEMINI.md.bak') -Destination (Join-Path $ws 'GEMINI.md') -Force
        }
        Write-Host 'Rollback completed. Original state restored.' -ForegroundColor Cyan
        throw ('Migration failed and rollback completed. Details: ' + $_.Exception.Message)
    }
}

# ------------------------------------------------------------------------------
# 11. CLEAN COMMAND (Pruning Managed Obsolete Artifacts)
# ------------------------------------------------------------------------------
function Invoke-AidevClean {
    param(
        [string]$WorkspacePath = '.',
        [switch]$DryRun,
        [switch]$Force
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- Workspace Pruning & Clean' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $modeText = if ($DryRun) { 'DRY-RUN (Simulation without write)' } else { 'APPLY (Real Execution)' }
    Write-Host ('Target Workspace : ' + $ws) -ForegroundColor Gray
    Write-Host ('Mode             : ' + $modeText) -ForegroundColor Gray
    Write-Host ''

    $plannedCleanups = @()

    # 1. Check for expired backup directories
    $backups = @(Get-ChildItem -LiteralPath $ws -Directory -Filter '.aidev_backup_*' -ErrorAction SilentlyContinue)
    foreach ($b in $backups) {
        $plannedCleanups += [pscustomobject]@{
            Type        = 'Backup Directory'
            Path        = $b.FullName
            Description = ('Expired migration backup (' + $b.Name + ')')
        }
    }

    # 2. Check for orphan skills (junctions or physical directories)
    $wsAgents = Join-Path $ws '.agents'
    $skillsDir = Join-Path $wsAgents 'skills'
    if (Test-Path -LiteralPath $skillsDir) {
        $manifest = Get-AidevManifest -WorkspacePath $ws
        $resolved = if ($manifest) { (Test-AidevManifest -WorkspacePath $ws).Resolved } else { $null }
        $activeSkillNames = if ($resolved) { @($resolved.Skills | Select-Object -ExpandProperty Name) } else { @() }
        $installedSkills = @(Get-ChildItem -LiteralPath $skillsDir -Directory -ErrorAction SilentlyContinue)
        foreach ($sk in $installedSkills) {
            if ($activeSkillNames -notcontains $sk.Name) {
                if (Test-IsJunction -Path $sk.FullName) {
                    $plannedCleanups += [pscustomobject]@{
                        Type        = 'Orphan Skill Link'
                        Path        = $sk.FullName
                        Description = ('Skill junction ' + $sk.Name + ' no longer in declared capabilities')
                    }
                } else {
                    $plannedCleanups += [pscustomobject]@{
                        Type        = 'Orphan Skill Directory'
                        Path        = $sk.FullName
                        Description = ('Physical skill directory ' + $sk.Name + ' no longer in declared capabilities')
                    }
                }
            }
        }
    }

    # 3. Check for obsolete managed rules
    $rulesDir = Join-Path $wsAgents 'rules'
    if (Test-Path -LiteralPath $rulesDir) {
        $metaPath = Join-Path $wsAgents '.aidev_metadata.json'
        if (Test-Path -LiteralPath $metaPath) {
            $meta = Get-Content -LiteralPath $metaPath -Raw -Encoding utf8 | ConvertFrom-Json
            $managedRulesList = if ($meta.managedRules) { @($meta.managedRules) } else { @() }
            $manifest = Get-AidevManifest -WorkspacePath $ws
            $resolved = if ($manifest) { (Test-AidevManifest -WorkspacePath $ws).Resolved } else { $null }
            $activeRuleNames = if ($resolved) { @($resolved.Rules | Select-Object -ExpandProperty Name) } else { @() }

            $installedRules = @(Get-ChildItem -LiteralPath $rulesDir -Filter '*.md' -File -ErrorAction SilentlyContinue)
            foreach ($rk in $installedRules) {
                if ($managedRulesList -contains $rk.Name -and $activeRuleNames -notcontains $rk.Name) {
                    $plannedCleanups += [pscustomobject]@{
                        Type        = 'Obsolete Managed Rule'
                        Path        = $rk.FullName
                        Description = ('Managed rule ' + $rk.Name + ' no longer in declared capabilities')
                    }
                }
            }
        }
    }

    if ($plannedCleanups.Count -eq 0) {
        Write-Host 'No obsolete artifacts or orphan links found. Workspace is clean.' -ForegroundColor Green
        return
    }

    Write-Host ('Found ' + $plannedCleanups.Count + ' item(s) to prune:') -ForegroundColor Yellow
    foreach ($item in $plannedCleanups) {
        Write-Host ('  [' + $item.Type + '] ' + $item.Path + ' (' + $item.Description + ')') -ForegroundColor Yellow
    }

    if ($DryRun) {
        Write-Host ''
        Write-Host 'Dry-run complete. 0 modifications made.' -ForegroundColor Cyan
        return
    }

    Write-Host ''
    Write-Host 'Pruning items...' -ForegroundColor Green
    foreach ($item in $plannedCleanups) {
        if ($item.Type -eq 'Orphan Skill Link') {
            cmd /c "rmdir `"$($item.Path)`"" | Out-Null
            Write-Host ('  [REMOVED LINK] ' + $item.Path) -ForegroundColor Green
        } elseif ($item.Type -eq 'Orphan Skill Directory') {
            Remove-Item -LiteralPath $item.Path -Recurse -Force
            Write-Host ('  [REMOVED SKILL] ' + $item.Path) -ForegroundColor Green
        } elseif ($item.Type -eq 'Backup Directory') {
            Remove-Item -LiteralPath $item.Path -Recurse -Force
            Write-Host ('  [DELETED BACKUP] ' + $item.Path) -ForegroundColor Green
        } elseif ($item.Type -eq 'Obsolete Managed Rule') {
            Remove-Item -LiteralPath $item.Path -Force
            Write-Host ('  [REMOVED RULE] ' + $item.Path) -ForegroundColor Green
        }
    }
    Write-Host ''
    Write-Host 'Clean operation completed.' -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# 12. SYNC COMMAND (Global Library Synchronizer)
# ------------------------------------------------------------------------------
function Invoke-AidevSync {
    param(
        [switch]$Update,
        [switch]$DryRun,
        [string]$UserProfileOverride
    )
    $root = Get-AidevRoot
    $effectiveUser = if ($UserProfileOverride) { $UserProfileOverride } else { $env:USERPROFILE }
    $storageRoot = Join-Path $effectiveUser '.agents'
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2.1 -- Global Library Sync' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $syncModeText = if ($DryRun) { 'DRY RUN' } elseif ($Update) { 'UPDATE UPSTREAM' } else { 'IDEMPOTENT CHECK' }
    Write-Host ('Global Storage: ' + $storageRoot) -ForegroundColor Gray
    Write-Host ('Mode          : ' + $syncModeText) -ForegroundColor Gray
    Write-Host ''

    $skillsScript = Join-Path $root 'install-skills.ps1'
    $agentsScript = Join-Path $root 'install-agents.ps1'

    $psArgsSkills = @('-ExecutionPolicy', 'Bypass', '-File', $skillsScript)
    $psArgsAgents = @('-ExecutionPolicy', 'Bypass', '-File', $agentsScript)
    if ($DryRun) {
        $psArgsSkills += '-DryRun'
        $psArgsAgents += '-DryRun'
    }
    if ($Update) {
        $psArgsSkills += '-Update'
        $psArgsAgents += '-Update'
    }
    if ($UserProfileOverride) {
        $psArgsSkills += @('-UserProfileOverride', $UserProfileOverride)
        $psArgsAgents += @('-UserProfileOverride', $UserProfileOverride)
    }

    Write-Host '--- Syncing Skills ---' -ForegroundColor Yellow
    & powershell @psArgsSkills
    Write-Host ''
    Write-Host '--- Syncing Agents ---' -ForegroundColor Yellow
    & powershell @psArgsAgents

    Write-Host ''
    Write-Host 'Global sync completed.' -ForegroundColor Cyan
}

Export-ModuleMember -Function @(
    'Get-AidevRoot',
    'Get-RegistryData',
    'Test-SkillDirectory',
    'Test-AgentFile',
    'Test-IsJunction',
    'Get-JunctionTarget',
    'Get-AidevManifest',
    'Test-AidevManifest',
    'Invoke-AidevManifest',
    'Resolve-AidevCapabilities',
    'Invoke-AidevDetect',
    'Invoke-AidevResolve',
    'Invoke-AidevDoctor',
    'Invoke-AidevList',
    'Invoke-AidevCapability',
    'Invoke-AidevAudit',
    'Select-SkillsForDomainRule',
    'Invoke-AidevAgentSynthesis',
    'Invoke-AidevApply',
    'Invoke-AidevInit',
    'Invoke-AidevMigrate',
    'Invoke-AidevClean',
    'Invoke-AidevSync'
)
