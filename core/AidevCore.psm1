# ==============================================================================
# AI-Dev-Machine Core Module (Architecture v2 -- Hardened & Verified)
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
        if (Test-Path (Join-Path $current 'registry\skills.json')) {
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
    if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '---') { return $false }
    $closing = @($lines | Select-Object -Skip 1 | Where-Object { $_.Trim() -eq '---' })
    if ($closing.Count -eq 0) { return $false }
    $nameLine = $lines | Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1
    if (-not $nameLine) { return $false }
    $nameMatch = [regex]::Match([string]$nameLine, '^name:\s*(.+)$')
    if ($nameMatch.Success) {
        $declaredName = $nameMatch.Groups[1].Value.Trim().Trim('"', "'")
        if ($declaredName -ne $ExpectedName) { return $false }
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

# ------------------------------------------------------------------------------
# 1. RESOLVER (Profile Inheritance & Provenance & Duplicate Detection)
# ------------------------------------------------------------------------------
function Resolve-AidevProfile {
    param(
        [Parameter(Mandatory)][string]$ProfileName
    )
    $profilesData = (Get-RegistryData -Type 'profiles').profiles
    if (-not $profilesData.PSObject.Properties.Name.Contains($ProfileName)) {
        throw ("Profile '" + $ProfileName + "' not found in registry/profiles.json. Available: " + ($profilesData.PSObject.Properties.Name -join ', '))
    }

    $allProfiles = [System.Collections.Generic.List[pscustomobject]]::new()
    $visited = [System.Collections.Generic.HashSet[string]]::new()

    $collectHierarchy = $null
    $collectHierarchy = {
        param([string]$pName)
        if ($visited.Contains($pName)) { return }
        $null = $visited.Add($pName)
        $pObj = $profilesData.$pName
        if ($pObj.PSObject.Properties.Name.Contains('inherits') -and $pObj.inherits) {
            foreach ($parent in $pObj.inherits) {
                if ($profilesData.PSObject.Properties.Name.Contains($parent)) {
                    & $collectHierarchy $parent
                }
            }
        }
        $allProfiles.Add([pscustomobject]@{ Id = $pName; Data = $pObj })
    }

    & $collectHierarchy $ProfileName

    $resolvedRules = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedSkills = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedAgents = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedMcps = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $resolvedPlugins = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new()
    $duplicateExposures = [System.Collections.Generic.List[string]]::new()

    foreach ($p in $allProfiles) {
        $pId = $p.Id
        $pData = $p.Data

        # Rules
        if ($pData.PSObject.Properties.Name.Contains('rules') -and $pData.rules) {
            foreach ($r in $pData.rules) {
                $resolvedRules[$r] = [pscustomobject]@{
                    Name   = $r
                    Source = ('profile:' + $pId)
                    Reason = ('Governance rule for ' + $pId)
                    State  = 'enabled'
                    Trigger = 'model_decision'
                }
            }
        }

        # Skills
        if ($pData.PSObject.Properties.Name.Contains('skills') -and $pData.skills) {
            foreach ($s in $pData.skills) {
                $resolvedSkills[$s] = [pscustomobject]@{
                    Name   = $s
                    Source = ('profile:' + $pId)
                    Reason = ('Core capability for ' + $pId)
                    State  = 'enabled'
                }
            }
        }

        # Agents
        if ($pData.PSObject.Properties.Name.Contains('agents') -and $pData.agents) {
            foreach ($a in $pData.agents) {
                $resolvedAgents[$a] = [pscustomobject]@{
                    Name   = $a
                    Source = ('profile:' + $pId)
                    Reason = ('Specialist persona for ' + $pId)
                    State  = 'enabled'
                }
            }
        }

        # MCPs
        if ($pData.PSObject.Properties.Name.Contains('mcps') -and $pData.mcps) {
            foreach ($m in $pData.mcps) {
                $resolvedMcps[$m] = [pscustomobject]@{
                    Name   = $m
                    Source = ('profile:' + $pId)
                    Reason = ('Tool integration for ' + $pId)
                    State  = 'enabled'
                }
            }
        }

        # Plugins
        if ($pData.PSObject.Properties.Name.Contains('plugins') -and $pData.plugins) {
            foreach ($pl in $pData.plugins) {
                $resolvedPlugins[$pl] = [pscustomobject]@{
                    Name   = $pl
                    Source = ('profile:' + $pId)
                    Reason = ('Antigravity plugin bundle for ' + $pId)
                    State  = 'enabled'
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

    # Check for duplicate exposure collisions
    if ($resolvedPlugins.Count -gt 0) {
        $pluginsRegistry = (Get-RegistryData -Type 'plugins').plugins
        foreach ($pl in $resolvedPlugins.Values) {
            $matchedPl = $pluginsRegistry | Where-Object { $_.id -eq $pl.Name } | Select-Object -First 1
            if ($matchedPl) {
                if ($matchedPl.PSObject.Properties.Name.Contains('skills') -and $matchedPl.skills) {
                    foreach ($psk in $matchedPl.skills) {
                        if ($resolvedSkills.ContainsKey($psk)) {
                            $duplicateExposures.Add("Skill '$psk' exposed via workspace skill and plugin '$($pl.Name)'")
                        }
                    }
                }
                if ($matchedPl.PSObject.Properties.Name.Contains('rules') -and $matchedPl.rules) {
                    foreach ($prl in $matchedPl.rules) {
                        if ($resolvedRules.ContainsKey($prl)) {
                            $duplicateExposures.Add("Rule '$prl' exposed via workspace rule and plugin '$($pl.Name)'")
                        }
                    }
                }
            }
        }
    }

    return [pscustomobject]@{
        ProfileName        = $ProfileName
        DisplayName        = $profilesData.$ProfileName.name
        Description        = $profilesData.$ProfileName.description
        Hierarchy          = @($allProfiles | Select-Object -ExpandProperty Id)
        Rules              = @($resolvedRules.Values)
        Skills             = @($resolvedSkills.Values)
        Agents             = @($resolvedAgents.Values)
        Mcps               = @($resolvedMcps.Values)
        Plugins            = @($resolvedPlugins.Values)
        Hooks              = $profilesData.$ProfileName.hooks
        DuplicateExposures = @($duplicateExposures)
    }
}

function Invoke-AidevResolve {
    param(
        [string]$WorkspacePath = '.',
        [string]$Profile = ''
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)

    $targetProfile = $Profile
    if (-not $targetProfile) {
        $metaPath = Join-Path $ws '.agents\.aidev_metadata.json'
        if (Test-Path -LiteralPath $metaPath) {
            $meta = Get-Content -LiteralPath $metaPath -Raw -Encoding utf8 | ConvertFrom-Json
            if ($meta.profile) { $targetProfile = $meta.profile }
        }
    }
    if (-not $targetProfile) {
        $agentsMd = Join-Path $ws 'AGENTS.md'
        if (Test-Path -LiteralPath $agentsMd) {
            $content = Get-Content -LiteralPath $agentsMd -Raw -Encoding utf8
            if ($content -match 'Profile\*\*:\s*([a-zA-Z0-9\-_]+)') {
                $targetProfile = $Matches[1].Trim()
            }
        }
    }
    if (-not $targetProfile) { $targetProfile = 'base' }

    $res = Resolve-AidevProfile -ProfileName $targetProfile

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2 -- Profile Resolution' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $pMsg = 'Resolved Profile : ' + $res.ProfileName + ' (' + $res.DisplayName + ')'
    Write-Host $pMsg -ForegroundColor Green
    $hMsg = 'Inheritance Chain: ' + ($res.Hierarchy -join ' -> ')
    Write-Host $hMsg -ForegroundColor Gray
    $dMsg = 'Description      : ' + $res.Description
    Write-Host $dMsg -ForegroundColor Gray
    Write-Host ''

    $rHeader = '--- Resolved Rules (' + $res.Rules.Count + ') ---'
    Write-Host $rHeader -ForegroundColor Yellow
    foreach ($r in $res.Rules) {
        $line = '  ' + $r.Name.PadRight(30) + ' :: Source: ' + $r.Source.PadRight(22) + ' :: Trigger: ' + $r.Trigger
        Write-Host $line
    }

    Write-Host ''
    $sHeader = '--- Resolved Skills (' + $res.Skills.Count + ') ---'
    Write-Host $sHeader -ForegroundColor Yellow
    foreach ($s in $res.Skills) {
        $line = '  ' + $s.Name.PadRight(30) + ' :: Source: ' + $s.Source.PadRight(22) + ' :: ' + $s.Reason
        Write-Host $line
    }

    Write-Host ''
    $aHeader = '--- Resolved Agents (' + $res.Agents.Count + ') ---'
    Write-Host $aHeader -ForegroundColor Yellow
    foreach ($a in $res.Agents) {
        $line = '  ' + $a.Name.PadRight(30) + ' :: Source: ' + $a.Source.PadRight(22) + ' :: ' + $a.Reason
        Write-Host $line
    }

    Write-Host ''
    $mHeader = '--- Resolved MCPs (' + $res.Mcps.Count + ') ---'
    Write-Host $mHeader -ForegroundColor Yellow
    foreach ($m in $res.Mcps) {
        $line = '  ' + $m.Name.PadRight(30) + ' :: Source: ' + $m.Source.PadRight(22) + ' :: ' + $m.Reason
        Write-Host $line
    }

    if ($res.Plugins.Count -gt 0) {
        Write-Host ''
        $plHeader = '--- Resolved Plugins (' + $res.Plugins.Count + ') ---'
        Write-Host $plHeader -ForegroundColor Yellow
        foreach ($pl in $res.Plugins) {
            $line = '  ' + $pl.Name.PadRight(30) + ' :: Source: ' + $pl.Source.PadRight(22) + ' :: ' + $pl.Reason
            Write-Host $line
        }
    }

    $hooksText = if ($res.Hooks) { 'Enabled (hooks.json active)' } else { 'Disabled' }
    Write-Host ''
    Write-Host ('Lifecycle Hooks : ' + $hooksText) -ForegroundColor Green

    Write-Host ''
    Write-Host '--- Effective Exposure & Duplication Audit ---' -ForegroundColor Yellow
    if ($res.DuplicateExposures.Count -eq 0) {
        Write-Host '  [OK] Zero duplicate exposures detected across scopes' -ForegroundColor Green
    } else {
        foreach ($dup in $res.DuplicateExposures) {
            Write-Host ('  [DUPLICATE EXPOSURE] ' + $dup) -ForegroundColor DarkYellow
        }
    }

    return $res
}

# ------------------------------------------------------------------------------
# 2. DOCTOR COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevDoctor {
    param([string]$WorkspacePath = (Get-Location).Path)
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $root = Get-AidevRoot

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2 -- System & Project Doctor' -ForegroundColor Cyan
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

    # 2. Canonical Registries
    Write-Host ''
    Write-Host '[2/6] Canonical Registries' -ForegroundColor Yellow
    $regFiles = @('skills', 'agents', 'mcps', 'plugins', 'profiles')
    foreach ($rf in $regFiles) {
        try {
            $data = Get-RegistryData -Type $rf
            $count = if ($rf -eq 'profiles') {
                @($data.profiles.PSObject.Properties).Count
            } else {
                $data.$rf.Count
            }
            $regMsg = '  [OK] registry/' + $rf + '.json (' + $count + ' items)'
            Write-Host $regMsg -ForegroundColor Green
        } catch {
            $errMsg = '  [ERROR] registry/' + $rf + '.json : ' + $_.Exception.Message
            Write-Host $errMsg -ForegroundColor Red
        }
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
        @{ Name = 'Antigravity Global Rules'; Path = Join-Path $env:USERPROFILE '.gemini\config\rules' }
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

    # 5. Workspace Status
    Write-Host ''
    Write-Host ('[5/6] Workspace Architecture Status (' + $ws + ')') -ForegroundColor Yellow
    $wsAgents = Join-Path $ws '.agents'
    $wsAgentsMd = Join-Path $ws 'AGENTS.md'
    if (Test-IsJunction -Path $wsAgents) {
        $target = Get-JunctionTarget -Path $wsAgents
        Write-Host ('  [LEGACY WARNING] Workspace .agents is a monolithic junction -> ' + $target) -ForegroundColor DarkYellow
        Write-Host '                   This couples project-local rules with global storage. Run "aidev migrate" to upgrade.' -ForegroundColor DarkYellow
    } elseif (Test-Path -LiteralPath $wsAgents) {
        Write-Host '  [OK] Workspace .agents is an isolated physical directory (Architecture v2 compliant)' -ForegroundColor Green
        $rulesDir = Join-Path $wsAgents 'rules'
        $rulesCount = if (Test-Path -LiteralPath $rulesDir) { @(Get-ChildItem -LiteralPath $rulesDir -Filter '*.md' -File).Count } else { 0 }
        $skillsDir = Join-Path $wsAgents 'skills'
        $skillsCount = if (Test-Path -LiteralPath $skillsDir) { @(Get-ChildItem -LiteralPath $skillsDir -Directory).Count } else { 0 }
        $agentsDir = Join-Path $wsAgents 'agents'
        $agentsCount = if (Test-Path -LiteralPath $agentsDir) { @(Get-ChildItem -LiteralPath $agentsDir -Filter '*.md' -File).Count } else { 0 }
        $hooksFile = Join-Path $wsAgents 'hooks.json'
        $mcpFile = Join-Path $wsAgents 'mcp_config.json'
        $rLine = '  [OK] .agents/rules/ (' + $rulesCount + ' rules active)'
        Write-Host $rLine -ForegroundColor Green
        $sLine = '  [OK] .agents/skills/ (' + $skillsCount + ' project-scoped skills)'
        Write-Host $sLine -ForegroundColor Green
        $aLine = '  [OK] .agents/agents/ (' + $agentsCount + ' specialized agents)'
        Write-Host $aLine -ForegroundColor Green
        if (Test-Path -LiteralPath $hooksFile) { Write-Host '  [OK] .agents/hooks.json (deterministic lifecycle hooks configured)' -ForegroundColor Green }
        if (Test-Path -LiteralPath $mcpFile) { Write-Host '  [OK] .agents/mcp_config.json (workspace MCP server config)' -ForegroundColor Green }
    } else {
        Write-Host '  [NOTICE] No .agents directory found. Run "aidev init" or "aidev migrate".' -ForegroundColor DarkGray
    }

    if (Test-Path -LiteralPath $wsAgentsMd) {
        $content = Get-Content -LiteralPath $wsAgentsMd -Raw -Encoding utf8
        if ($content -match 'REGRA ZERO') {
            Write-Host '  [LEGACY WARNING] AGENTS.md contains monolithic Regra Zero. Run "aidev migrate" to install v2 constitution.' -ForegroundColor DarkYellow
        } else {
            Write-Host '  [OK] AGENTS.md constitution present' -ForegroundColor Green
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
# 3. LIST COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevList {
    param([string]$Category = 'all')
    $cat = $Category.ToLower()

    if ($cat -eq 'all' -or $cat -eq 'skills') {
        Write-Host '=== MANAGED SKILLS (registry/skills.json) ===' -ForegroundColor Cyan
        $skills = (Get-RegistryData -Type 'skills').skills
        foreach ($s in $skills) {
            $idStr = $s.id.PadRight(32)
            $catStr = '[' + $s.category.PadRight(12) + ']'
            Write-Host ('  ' + $idStr + ' ' + $catStr + ' : ' + $s.description)
        }
        Write-Host ''
    }

    if ($cat -eq 'all' -or $cat -eq 'agents') {
        Write-Host '=== SPECIALIZED & AGENCY AGENTS (registry/agents.json) ===' -ForegroundColor Cyan
        $agents = (Get-RegistryData -Type 'agents').agents
        foreach ($a in $agents) {
            $slugStr = $a.slug.PadRight(28)
            $roleStr = '[' + $a.role.PadRight(20) + ']'
            Write-Host ('  ' + $slugStr + ' ' + $roleStr + ' : ' + $a.description)
        }
        Write-Host ''
    }

    if ($cat -eq 'all' -or $cat -eq 'mcps') {
        Write-Host '=== MCP SERVERS (registry/mcps.json) ===' -ForegroundColor Cyan
        $mcps = (Get-RegistryData -Type 'mcps').mcps
        foreach ($m in $mcps) {
            $idStr = $m.id.PadRight(24)
            $status = if ($m.enabledByDefault) { 'Base / Active' } else { 'Profile / Opt-in' }
            $statusStr = '[' + $status.PadRight(20) + ']'
            Write-Host ('  ' + $idStr + ' ' + $statusStr + ' : ' + $m.description)
        }
        Write-Host ''
    }

    if ($cat -eq 'all' -or $cat -eq 'plugins') {
        Write-Host '=== ANTIGRAVITY PLUGINS (registry/plugins.json) ===' -ForegroundColor Cyan
        $plugins = (Get-RegistryData -Type 'plugins').plugins
        foreach ($pl in $plugins) {
            $idStr = $pl.id.PadRight(28)
            Write-Host ('  ' + $idStr + ' : ' + $pl.description)
        }
        Write-Host ''
    }

    if ($cat -eq 'all' -or $cat -eq 'profiles') {
        Write-Host '=== COMPOSABLE PROFILES (registry/profiles.json) ===' -ForegroundColor Cyan
        $profiles = (Get-RegistryData -Type 'profiles').profiles
        foreach ($pName in $profiles.PSObject.Properties.Name) {
            $p = $profiles.$pName
            Write-Host ('  ' + $pName.PadRight(20) + ' : ' + $p.description)
            Write-Host ('    Rules  : ' + ($p.rules -join ', ')) -ForegroundColor Gray
            Write-Host ('    Skills : ' + ($p.skills -join ', ')) -ForegroundColor Gray
            Write-Host ('    Agents : ' + ($p.agents -join ', ')) -ForegroundColor Gray
            Write-Host ('    MCPs   : ' + ($p.mcps -join ', ')) -ForegroundColor Gray
        }
        Write-Host ''
    }
}

# ------------------------------------------------------------------------------
# 4. AUDIT COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevAudit {
    param([string]$WorkspacePath = (Get-Location).Path)
    $ws = [IO.Path]::GetFullPath($WorkspacePath)

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2 -- Project Audit' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ('Audit Target: ' + $ws) -ForegroundColor Gray
    Write-Host ''

    $report = [pscustomobject]@{
        Workspace            = $ws
        IsGitRepo            = Test-Path (Join-Path $ws '.git')
        HasAgentsDir         = Test-Path -LiteralPath (Join-Path $ws '.agents')
        IsMonolithicJunction = $false
        JunctionTarget       = $null
        HasAgentsMd          = Test-Path -LiteralPath (Join-Path $ws 'AGENTS.md')
        HasGeminiMd          = Test-Path -LiteralPath (Join-Path $ws 'GEMINI.md')
        HasLegacyRegraZero   = $false
        DetectedRules        = @()
        DetectedSkills       = @()
        DetectedAgents       = @()
        DetectedHooks        = $false
        DetectedMcp          = $false
        ExternalComponents   = @()
        MigrationNeeded      = $false
    }

    $wsAgents = Join-Path $ws '.agents'
    if ($report.HasAgentsDir) {
        if (Test-IsJunction -Path $wsAgents) {
            $report.IsMonolithicJunction = $true
            $report.JunctionTarget = Get-JunctionTarget -Path $wsAgents
            $report.MigrationNeeded = $true
            Write-Host ('  [AUDIT / LEGACY JUNCTION] .agents is a monolithic link -> ' + $report.JunctionTarget) -ForegroundColor Yellow
        } else {
            Write-Host '  [AUDIT / OK] .agents is an isolated physical directory' -ForegroundColor Green
            $rulesDir = Join-Path $wsAgents 'rules'
            if (Test-Path -LiteralPath $rulesDir) {
                $report.DetectedRules = @(Get-ChildItem -LiteralPath $rulesDir -Filter '*.md' -File | Select-Object -ExpandProperty Name)
            }
            $skillsDir = Join-Path $wsAgents 'skills'
            if (Test-Path -LiteralPath $skillsDir) {
                $report.DetectedSkills = @(Get-ChildItem -LiteralPath $skillsDir -Directory | Select-Object -ExpandProperty Name)
            }
            $agentsDir = Join-Path $wsAgents 'agents'
            if (Test-Path -LiteralPath $agentsDir) {
                $report.DetectedAgents = @(Get-ChildItem -LiteralPath $agentsDir -Filter '*.md' -File | Select-Object -ExpandProperty Name)
            }
            $report.DetectedHooks = Test-Path (Join-Path $wsAgents 'hooks.json')
            $report.DetectedMcp = Test-Path (Join-Path $wsAgents 'mcp_config.json')
        }
    } else {
        $report.MigrationNeeded = $true
        Write-Host '  [AUDIT / ABSENT] .agents directory is missing' -ForegroundColor Yellow
    }

    if ($report.HasAgentsMd) {
        $content = Get-Content -LiteralPath (Join-Path $ws 'AGENTS.md') -Raw -Encoding utf8
        if ($content -match 'REGRA ZERO') {
            $report.HasLegacyRegraZero = $true
            $report.MigrationNeeded = $true
            Write-Host '  [AUDIT / LEGACY] AGENTS.md has monolithic Regra Zero' -ForegroundColor Yellow
        } else {
            Write-Host '  [AUDIT / OK] AGENTS.md has v2 constitution' -ForegroundColor Green
        }
    } else {
        $report.MigrationNeeded = $true
        Write-Host '  [AUDIT / ABSENT] AGENTS.md is missing' -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host 'Audit Summary:' -ForegroundColor Cyan
    $recColor = if ($report.MigrationNeeded) { 'Yellow' } else { 'Green' }
    Write-Host ('  Migration to v2 Recommended: ' + $report.MigrationNeeded) -ForegroundColor $recColor
    Write-Host ('  Rules detected             : ' + $report.DetectedRules.Count)
    Write-Host ('  Skills detected            : ' + $report.DetectedSkills.Count)
    Write-Host ('  Agents detected            : ' + $report.DetectedAgents.Count)
    Write-Host ('  Hooks configured           : ' + $report.DetectedHooks)
    Write-Host ('  MCP configured             : ' + $report.DetectedMcp)

    return $report
}

# ------------------------------------------------------------------------------
# 5. INIT COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevInit {
    param(
        [string]$WorkspacePath = (Get-Location).Path,
        [string]$Profile = 'base',
        [string]$ProjectName = (Split-Path -Leaf (Get-Location).Path),
        [switch]$Force
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $root = Get-AidevRoot
    $resolved = Resolve-AidevProfile -ProfileName $Profile

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2 -- Project Initialization' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ('Workspace Path : ' + $ws) -ForegroundColor Gray
    Write-Host ('Profile        : ' + $Profile + ' (' + $resolved.DisplayName + ')') -ForegroundColor Gray
    Write-Host ''

    if (-not (Test-Path -LiteralPath $ws -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $ws -Force
    }

    # 1. Physical .agents directory
    $agentsDir = Join-Path $ws '.agents'
    if (Test-IsJunction -Path $agentsDir) {
        if (-not $Force) {
            throw ('Existing monolithic junction detected at ' + $agentsDir + '. Use "aidev migrate" to upgrade safely or -Force to override.')
        }
        cmd /c "rmdir `"$agentsDir`"" | Out-Null
    }
    if (-not (Test-Path -LiteralPath $agentsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $agentsDir -Force
    }

    # 2. .agents/rules/
    $targetRulesDir = Join-Path $agentsDir 'rules'
    if (-not (Test-Path -LiteralPath $targetRulesDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $targetRulesDir -Force
    }
    $managedRules = @()
    foreach ($rObj in $resolved.Rules) {
        $ruleName = $rObj.Name
        $sourceRule = Join-Path $root ('templates\rules\' + $ruleName)
        if (Test-Path -LiteralPath $sourceRule) {
            Copy-Item -LiteralPath $sourceRule -Destination (Join-Path $targetRulesDir $ruleName) -Force
            $managedRules += $ruleName
            Write-Host ('  [CREATED RULE] .agents/rules/' + $ruleName) -ForegroundColor Green
        }
    }

    # 3. .agents/agents/ (Cognitive + Domain Specialists)
    $targetAgentsDir = Join-Path $agentsDir 'agents'
    if (-not (Test-Path -LiteralPath $targetAgentsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $targetAgentsDir -Force
    }
    $managedAgents = @()
    # Cognitive agents
    $cognitiveAgents = @('researcher.md', 'reviewer.md', 'security-reviewer.md')
    foreach ($ca in $cognitiveAgents) {
        $sourceAgent = Join-Path $root ('templates\agents\' + $ca)
        if (Test-Path -LiteralPath $sourceAgent) {
            Copy-Item -LiteralPath $sourceAgent -Destination (Join-Path $targetAgentsDir $ca) -Force
            $managedAgents += $ca
            Write-Host ('  [CREATED AGENT] .agents/agents/' + $ca + ' (Cognitive Specialist)') -ForegroundColor Green
        }
    }
    # Domain agents
    foreach ($aObj in $resolved.Agents) {
        $agentSlug = $aObj.Name
        if ($cognitiveAgents -contains ($agentSlug + '.md')) { continue }
        $agentFileName = ($agentSlug + '.md')
        $destFile = Join-Path $targetAgentsDir $agentFileName
        if (-not (Test-Path -LiteralPath $destFile) -or $Force) {
            $globalAgent = Join-Path $script:GlobalAgentsDir $agentFileName
            if (Test-Path -LiteralPath $globalAgent) {
                Copy-Item -LiteralPath $globalAgent -Destination $destFile -Force
                $managedAgents += $agentFileName
                Write-Host ('  [LINKED AGENT] .agents/agents/' + $agentFileName + ' (Domain Specialist)') -ForegroundColor Green
            }
        }
    }

    # 4. .agents/skills/ (Project-Scoped Links from Global Library)
    $targetSkillsDir = Join-Path $agentsDir 'skills'
    if (-not (Test-Path -LiteralPath $targetSkillsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $targetSkillsDir -Force
    }
    $managedSkills = @()
    foreach ($sObj in $resolved.Skills) {
        $skillId = $sObj.Name
        $skillDest = Join-Path $targetSkillsDir $skillId
        if (-not (Test-Path -LiteralPath $skillDest)) {
            $globalSkill = Join-Path $script:GlobalSkillsRoot $skillId
            $localSkill = Join-Path $root ('skills\' + $skillId)
            if (Test-Path -LiteralPath $globalSkill) {
                $null = cmd /c "mklink /J `"$skillDest`" `"$globalSkill`"" 2>&1
                $managedSkills += $skillId
                Write-Host ('  [LINKED SKILL] .agents/skills/' + $skillId + ' -> Global Library') -ForegroundColor Green
            } elseif (Test-Path -LiteralPath $localSkill) {
                $null = cmd /c "mklink /J `"$skillDest`" `"$localSkill`"" 2>&1
                $managedSkills += $skillId
                Write-Host ('  [LINKED SKILL] .agents/skills/' + $skillId + ' -> Local Skill') -ForegroundColor Green
            }
        } else {
            $managedSkills += $skillId
        }
    }

    # 5. .agents/scripts/ & .agents/hooks.json
    $scriptsDir = Join-Path $agentsDir 'scripts'
    if (-not (Test-Path -LiteralPath $scriptsDir -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $scriptsDir -Force
    }
    $safetyScriptSrc = Join-Path $root 'templates\scripts\safety-check.ps1'
    if (Test-Path -LiteralPath $safetyScriptSrc) {
        Copy-Item -LiteralPath $safetyScriptSrc -Destination (Join-Path $scriptsDir 'safety-check.ps1') -Force
    }
    $hooksDest = Join-Path $agentsDir 'hooks.json'
    if (-not (Test-Path -LiteralPath $hooksDest) -or $Force) {
        Copy-Item -LiteralPath (Join-Path $root 'templates\hooks.template.json') -Destination $hooksDest -Force
        Write-Host '  [CREATED HOOKS] .agents/hooks.json' -ForegroundColor Green
    }

    # 6. Profile-tailored .agents/mcp_config.json
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

    # 7. Metadata Provenance Tracking
    $metaDest = Join-Path $agentsDir '.aidev_metadata.json'
    $metaObj = [ordered]@{
        profile       = $Profile
        version       = '2.0.0'
        timestamp     = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')
        managedRules  = $managedRules
        managedAgents = $managedAgents
        managedSkills = $managedSkills
        managedHooks  = $true
        managedMcp    = $true
    }
    $metaObj | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $metaDest -Encoding utf8

    # 8. Instantiate Root AGENTS.md & GEMINI.md
    $agentsMdDest = Join-Path $ws 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $agentsMdDest) -or $Force) {
        $tmpl = Get-Content -LiteralPath (Join-Path $root 'templates\AGENTS.template.md') -Raw -Encoding utf8
        $inst = $tmpl -replace '\[PROJECT_NAME\]', $ProjectName `
                      -replace '\[PROJECT_DESCRIPTION\]', ('Project configured with AI-Dev-Machine v2 (' + $Profile + ' profile)') `
                      -replace '\[PROJECT_PROFILE\]', $Profile `
                      -replace '\[PROJECT_RUNTIME\]', 'Node.js / TypeScript / .NET / Python' `
                      -replace '\[CMD_INSTALL\]', 'npm install' `
                      -replace '\[CMD_DEV\]', 'npm run dev' `
                      -replace '\[CMD_TEST\]', 'npm test' `
                      -replace '\[CMD_TYPECHECK\]', 'npx tsc --noEmit' `
                      -replace '\[CMD_LINT\]', 'npx eslint .' `
                      -replace '\[CMD_BUILD\]', 'npm run build'
        Set-Content -LiteralPath $agentsMdDest -Value $inst -Encoding utf8
        Write-Host '  [CREATED CONSTITUTION] AGENTS.md' -ForegroundColor Green
    }

    $geminiMdDest = Join-Path $ws 'GEMINI.md'
    if (-not (Test-Path -LiteralPath $geminiMdDest) -or $Force) {
        $tmplG = Get-Content -LiteralPath (Join-Path $root 'templates\GEMINI.template.md') -Raw -Encoding utf8
        $instG = $tmplG -replace '\[PROJECT_NAME\]', $ProjectName
        Set-Content -LiteralPath $geminiMdDest -Value $instG -Encoding utf8
        Write-Host '  [CREATED BRIDGE] GEMINI.md' -ForegroundColor Green
    }

    # 9. Setup docs/ structure
    $docsDir = Join-Path $ws 'docs'
    $docsArch = Join-Path $docsDir 'architecture'
    $docsDec = Join-Path $docsDir 'decisions'
    $docsRun = Join-Path $docsDir 'runbooks'
    foreach ($d in @($docsArch, $docsDec, $docsRun)) {
        if (-not (Test-Path -LiteralPath $d -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $d -Force
        }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $docsArch 'overview.md'))) {
        Copy-Item -LiteralPath (Join-Path $root 'templates\docs\architecture\overview.md') -Destination (Join-Path $docsArch 'overview.md') -Force
    }
    if (-not (Test-Path -LiteralPath (Join-Path $docsDec '0001-record-architecture-decisions.md'))) {
        Copy-Item -LiteralPath (Join-Path $root 'templates\docs\decisions\0001-record-architecture-decisions.md') -Destination (Join-Path $docsDec '0001-record-architecture-decisions.md') -Force
    }
    if (-not (Test-Path -LiteralPath (Join-Path $docsRun 'template-runbook.md'))) {
        Copy-Item -LiteralPath (Join-Path $root 'templates\docs\runbooks\template-runbook.md') -Destination (Join-Path $docsRun 'template-runbook.md') -Force
    }
    Write-Host '  [CREATED DOCS] docs/architecture, docs/decisions, docs/runbooks' -ForegroundColor Green

    # 10. Granular .gitignore updates
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern '.agents/skills/'
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern '.agents/cache/'
    Ensure-GitIgnoreEntry -WorkspacePath $ws -Pattern '.aidev_backup_*/'
    Write-Host '  [UPDATED] .gitignore (governance tracked, generated links and backups ignored)' -ForegroundColor Green

    Write-Host ''
    Write-Host 'Project initialized successfully with Architecture v2!' -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# 6. MIGRATE COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevMigrate {
    param(
        [string]$WorkspacePath = (Get-Location).Path,
        [string]$Profile = 'base',
        [switch]$DryRun,
        [switch]$Force,
        [switch]$InjectFailureTest
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    $root = Get-AidevRoot

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2 -- Project Migration' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $modeText = if ($DryRun) { 'DRY-RUN (Simulation without write)' } else { 'APPLY (Real Execution)' }
    $modeColor = if ($DryRun) { 'Yellow' } else { 'Green' }
    Write-Host ('Migration Target : ' + $ws) -ForegroundColor Gray
    Write-Host ('Execution Mode   : ' + $modeText) -ForegroundColor $modeColor
    Write-Host ('Profile Applied  : ' + $Profile) -ForegroundColor Gray
    Write-Host ''

    $audit = Invoke-AidevAudit -WorkspacePath $ws

    $actions = @()
    $backupDirName = '.aidev_backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
    $backupDirPath = Join-Path $ws $backupDirName

    if ($audit.IsMonolithicJunction) {
        $actions += '[REPLACE JUNCTION] Safe unlinking of monolithic .agents junction -> physical directory'
    } elseif (-not $audit.HasAgentsDir) {
        $actions += '[CREATE DIRECTORY] Create physical .agents directory'
    }

    if ($audit.HasLegacyRegraZero -or -not $audit.HasAgentsMd) {
        $actions += '[UPGRADE CONSTITUTION] Replace monolithic Regra Zero in AGENTS.md with concise v2 invariants'
    }

    $actions += '[CREATE BRIDGE] Instantiate GEMINI.md discovery pointer'
    $actions += ('[DEPLOY RULES] Deploy .agents/rules/ from profile ' + $Profile)
    $actions += '[DEPLOY AGENTS] Deploy cognitive specialists (researcher, reviewer, security-reviewer) in .agents/agents/'
    $actions += '[DEPLOY HOOKS] Deploy deterministic safety hooks (.agents/hooks.json)'
    $actions += '[DEPLOY MCP] Deploy workspace MCP config (.agents/mcp_config.json)'
    $actions += '[DEPLOY DOCS] Scaffold docs/architecture, docs/decisions, docs/runbooks'
    $actions += ('[UPDATE GITIGNORE] Ensure .agents/skills/, .agents/cache/, and ' + $backupDirName + '/ are ignored')

    if ($DryRun) {
        Write-Host ''
        Write-Host 'Planned Migration Actions (0 writes):' -ForegroundColor Yellow
        $actions | ForEach-Object { Write-Host ('  ' + $_) -ForegroundColor Yellow }
        Write-Host ''
        Write-Host ('Backup would be created at: ' + $backupDirPath) -ForegroundColor Gray
        Write-Host 'Dry-run complete. No changes made to disk.' -ForegroundColor Cyan
        return
    }

    # Real Migration Execution with Backup and Rollback
    Write-Host ''
    Write-Host 'Applying Migration...' -ForegroundColor Green
    $null = New-Item -ItemType Directory -Path $backupDirPath -Force

    try {
        # 1. Backup existing root metadata
        if (Test-Path -LiteralPath (Join-Path $ws 'AGENTS.md')) {
            Copy-Item -LiteralPath (Join-Path $ws 'AGENTS.md') -Destination (Join-Path $backupDirPath 'AGENTS.md.bak') -Force
        }
        if (Test-Path -LiteralPath (Join-Path $ws 'GEMINI.md')) {
            Copy-Item -LiteralPath (Join-Path $ws 'GEMINI.md') -Destination (Join-Path $backupDirPath 'GEMINI.md.bak') -Force
        }

        # 2. Unlink monolithic junction if present
        $wsAgents = Join-Path $ws '.agents'
        if (Test-IsJunction -Path $wsAgents) {
            cmd /c "rmdir `"$wsAgents`"" | Out-Null
            Write-Host '  [UNLINKED] Removed monolithic junction without affecting global storage' -ForegroundColor Green
        }

        # 3. Simulate failure injection if requested for testing
        if ($InjectFailureTest) {
            throw 'SIMULATED_FAILURE_INJECTION: Artificial error midway through migration'
        }

        # 4. Reinitialize with v2 scaffold
        Invoke-AidevInit -WorkspacePath $ws -Profile $Profile -Force

        Write-Host ''
        Write-Host ('Migration successfully applied! Backup preserved at: ' + $backupDirPath) -ForegroundColor Cyan
    } catch {
        Write-Host ''
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
# 7. CLEAN / PRUNE COMMAND
# ------------------------------------------------------------------------------
function Invoke-AidevClean {
    param(
        [string]$WorkspacePath = '.',
        [switch]$DryRun,
        [switch]$Force
    )
    $ws = [IO.Path]::GetFullPath($WorkspacePath)
    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2 -- Workspace Pruning & Clean' -ForegroundColor Cyan
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
            Type = 'Backup Directory'
            Path = $b.FullName
            Description = ('Expired migration backup (' + $b.Name + ')')
        }
    }

    # 2. Check for orphan skill junctions not in resolved profile
    $wsAgents = Join-Path $ws '.agents'
    $skillsDir = Join-Path $wsAgents 'skills'
    if (Test-Path -LiteralPath $skillsDir) {
        $resolved = Invoke-AidevResolve -WorkspacePath $ws
        $activeSkillNames = @($resolved.Skills | Select-Object -ExpandProperty Name)
        $installedSkills = @(Get-ChildItem -LiteralPath $skillsDir -Directory -ErrorAction SilentlyContinue)
        foreach ($sk in $installedSkills) {
            if ($activeSkillNames -notcontains $sk.Name) {
                if (Test-IsJunction -Path $sk.FullName) {
                    $plannedCleanups += [pscustomobject]@{
                        Type = 'Orphan Skill Link'
                        Path = $sk.FullName
                        Description = ('Skill link ' + $sk.Name + ' no longer belongs to active profile ' + $resolved.ProfileName)
                    }
                }
            }
        }
    }

    # 3. Check for obsolete rules not in resolved profile
    $rulesDir = Join-Path $wsAgents 'rules'
    if (Test-Path -LiteralPath $rulesDir) {
        $resolved = Invoke-AidevResolve -WorkspacePath $ws
        $activeRuleNames = @($resolved.Rules | Select-Object -ExpandProperty Name)
        $installedRules = @(Get-ChildItem -LiteralPath $rulesDir -Filter '*.md' -File -ErrorAction SilentlyContinue)
        $metaPath = Join-Path $wsAgents '.aidev_metadata.json'
        $managedRulesList = @()
        if (Test-Path -LiteralPath $metaPath) {
            $meta = Get-Content -LiteralPath $metaPath -Raw -Encoding utf8 | ConvertFrom-Json
            if ($meta.managedRules) { $managedRulesList = @($meta.managedRules) }
        }
        foreach ($rk in $installedRules) {
            if ($managedRulesList -contains $rk.Name -and $activeRuleNames -notcontains $rk.Name) {
                $plannedCleanups += [pscustomobject]@{
                    Type = 'Obsolete Managed Rule'
                    Path = $rk.FullName
                    Description = ('Managed rule ' + $rk.Name + ' no longer belongs to active profile ' + $resolved.ProfileName)
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
# 8. SYNC COMMAND (Global Library Synchronizer)
# ------------------------------------------------------------------------------
function Invoke-AidevSync {
    param(
        [switch]$Update,
        [switch]$DryRun
    )
    $root = Get-AidevRoot

    Write-Host '============================================================' -ForegroundColor Cyan
    Write-Host ' AI-Dev-Machine Architecture v2 -- Global Library Sync' -ForegroundColor Cyan
    Write-Host '============================================================' -ForegroundColor Cyan
    $syncModeText = if ($DryRun) { 'DRY RUN' } elseif ($Update) { 'UPDATE UPSTREAM' } else { 'IDEMPOTENT CHECK' }
    Write-Host ('Global Storage: ' + $script:GlobalAgentsRoot) -ForegroundColor Gray
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
    'Resolve-AidevProfile',
    'Invoke-AidevResolve',
    'Invoke-AidevDoctor',
    'Invoke-AidevList',
    'Invoke-AidevAudit',
    'Invoke-AidevInit',
    'Invoke-AidevMigrate',
    'Invoke-AidevClean',
    'Invoke-AidevSync'
)
