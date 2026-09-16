[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Update,
    [string]$WorkspacePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Fonte canonica fisica dos Agentes Especialistas: %USERPROFILE%\.agents\agents
$AgentsRoot = Join-Path $env:USERPROFILE '.agents\agents'

# Repositorio oficial upstream do Agency Agents
$UpstreamRepo = 'msitarzewski/agency-agents'

# Catalogo dos 7 Especialistas Essenciais Gerenciados (Agency Agents)
# Selecionados rigorosamente por valor agregado unico e ausencia de redundancia com as 30 Skills:
$ManagedAgents = @(
    [pscustomobject]@{ Slug = 'software-architect';       Subpath = 'engineering/engineering-software-architect.md';      ExpectedName = 'Software Architect' }
    [pscustomobject]@{ Slug = 'backend-architect';        Subpath = 'engineering/engineering-backend-architect.md';       ExpectedName = 'Backend Architect' }
    [pscustomobject]@{ Slug = 'frontend-developer';       Subpath = 'engineering/engineering-frontend-developer.md';      ExpectedName = 'Frontend Developer' }
    [pscustomobject]@{ Slug = 'database-optimizer';       Subpath = 'engineering/engineering-database-optimizer.md';      ExpectedName = 'Database Optimizer' }
    [pscustomobject]@{ Slug = 'security-architect';       Subpath = 'security/security-architect.md';                     ExpectedName = 'Security Architect' }
    [pscustomobject]@{ Slug = 'test-automation-engineer'; Subpath = 'testing/testing-test-automation-engineer.md';       ExpectedName = 'Test Automation Engineer' }
    [pscustomobject]@{ Slug = 'devops-automator';         Subpath = 'engineering/engineering-devops-automator.md';        ExpectedName = 'DevOps Automator' }
)

# Integracoes Multi-IA com suporte NATIVO comprovado a diretorio de subagentes/personas:
# - Claude Code: ~/.claude/agents (suporte nativo a arquivos Markdown de subagentes com frontmatter YAML)
# - Gemini CLI:  ~/.gemini/agents (suporte nativo a subagentes em ~/.gemini/agents/*.md)
# NOTA: OpenAI Codex e Google Antigravity utilizam roteamento declarativo via AGENTS.md
# e nao possuem descoberta estatica de ~/.codex/agents ou ~/.gemini/antigravity/agents.
$NativeIntegrationTargets = @(
    [pscustomobject]@{ Tool = 'Claude Code'; Path = Join-Path $env:USERPROFILE '.claude\agents'; Parent = Join-Path $env:USERPROFILE '.claude' }
    [pscustomobject]@{ Tool = 'Gemini CLI';  Path = Join-Path $env:USERPROFILE '.gemini\agents';  Parent = Join-Path $env:USERPROFILE '.gemini' }
)

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

function Test-IsCorrectJunction {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedTarget
    )
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    if ($item.LinkType -ne 'Junction') { return $false }
    if (-not $item.Target) { return $false }
    $targetPath = if ($item.Target -is [array]) { $item.Target[0] } else { $item.Target }
    try {
        $normActual = [IO.Path]::GetFullPath($targetPath).TrimEnd('\', '/')
        $normExpected = [IO.Path]::GetFullPath($ExpectedTarget).TrimEnd('\', '/')
        return ($normActual -ieq $normExpected)
    } catch {
        return $false
    }
}

Write-Host 'MANAGED AGENTS (Agency Agents — Core Specialists)'

# 1. Prerequisito Git
$git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $git) {
    Write-Host '[PREREQUISITE] Git e obrigatorio. Execute SETUP-AI-ENVIRONMENT.md primeiro.'
    exit 2
}
try {
    $gitVersion = @(& $git.Source --version 2>&1)
    if ($LASTEXITCODE -ne 0) { throw (($gitVersion | ForEach-Object ToString) -join "`n") }
} catch {
    Write-Host '[PREREQUISITE] Git e obrigatorio. Execute SETUP-AI-ENVIRONMENT.md primeiro.'
    Write-Host "[ERROR] git --version: $($_.Exception.Message)"
    exit 2
}

# 2. Inicializacao do diretorio canonico %USERPROFILE%\.agents\agents
if ($DryRun -and -not (Test-Path -LiteralPath $AgentsRoot -PathType Container)) {
    Write-Host "[CHECK] Diretorio canonico ausente: $AgentsRoot (nao sera criado em DryRun)"
} elseif (-not (Test-Path -LiteralPath $AgentsRoot -PathType Container)) {
    $null = New-Item -ItemType Directory -Path $AgentsRoot -Force
}

$tempRepoWorkspace = $null
$failures = @()

# 3. Verificacao e Instalacao/Atualizacao dos 7 Agentes
foreach ($agent in $ManagedAgents) {
    $agentFileName = "$($agent.Slug).md"
    $agentFilePath = Join-Path $AgentsRoot $agentFileName
    $exists = Test-Path -LiteralPath $agentFilePath -PathType Leaf
    $present = if ($exists) { Test-AgentFile -Path $agentFilePath -ExpectedName $agent.ExpectedName } else { $false }
    $isCorrupted = $exists -and (-not $present)

    if ($DryRun) {
        if ($Update) {
            if ($exists) { Write-Host "[WOULD UPDATE] $($agent.Slug) from $UpstreamRepo" }
            else { Write-Host "[WOULD INSTALL] $($agent.Slug) from $UpstreamRepo" }
        } else {
            if ($present) { Write-Host "[SKIP / PRESENT] $($agent.Slug)" }
            elseif ($isCorrupted) { Write-Host "[WOULD REPAIR] $($agent.Slug)" }
            else { Write-Host "[WOULD INSTALL] $($agent.Slug) from $UpstreamRepo" }
        }
        continue
    }

    # Se nao for Update e o agente ja estiver integro, pular sem tocar rede
    if (-not $Update -and $present) {
        Write-Host "[SKIP / PRESENT] $($agent.Slug)"
        continue
    }

    $actionLabel = if ($Update) {
        if ($exists) { 'UPDATE' } else { 'INSTALL' }
    } else {
        if ($isCorrupted) { 'REPAIR' } else { 'INSTALL' }
    }

    try {
        # Clone do repositorio upstream sob demanda com cache de sessao
        if (-not $tempRepoWorkspace) {
            $tempRepoWorkspace = Join-Path ([IO.Path]::GetTempPath()) ("aidev-agency-repo-{0}" -f [guid]::NewGuid().ToString('N'))
            $null = New-Item -ItemType Directory -Path $tempRepoWorkspace -Force
            Invoke-GitClone -Repo $UpstreamRepo -Destination $tempRepoWorkspace
        }

        $sourceFileCandidate = Join-Path $tempRepoWorkspace ($agent.Subpath -replace '/', '\')
        if (-not (Test-AgentFile -Path $sourceFileCandidate -ExpectedName $agent.ExpectedName)) {
            throw "Arquivo upstream ausente ou invalido: $($agent.Subpath)"
        }

        Write-Host "[$actionLabel] $($agent.Slug)"
        Set-ManagedAgentFile -Agent $agent -SourceFilePath $sourceFileCandidate
        Write-Host "[OK] $($agent.Slug)"
    } catch {
        $failureMessage = $_.Exception.Message
        $failureLabel = if ($failureMessage -match 'unable to access|Could not connect|Failed to connect|port 443|network|DNS') { 'BLOCKED_BY_ENVIRONMENT' } else { 'ERROR' }
        $failures += "[$failureLabel] $($agent.Slug): $failureMessage"
        Write-Host "[$failureLabel] $($agent.Slug): $failureMessage"
    }
}

# 4. Preservacao estrita de agentes externos/customizados
if (Test-Path -LiteralPath $AgentsRoot -PathType Container) {
    $managedSlugs = @($ManagedAgents.Slug | ForEach-Object { "$_.md" })
    foreach ($external in @(Get-ChildItem -LiteralPath $AgentsRoot -Filter '*.md' -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $managedSlugs })) {
        Write-Host "[PRESERVE EXTERNAL] $($external.Name)"
    }
}

# Limpeza do clone temporario
if ($tempRepoWorkspace -and (Test-Path -LiteralPath $tempRepoWorkspace)) {
    Remove-Item -LiteralPath $tempRepoWorkspace -Recurse -Force -ErrorAction SilentlyContinue
}

# 5. Integracao Multi-IA comprovada (Directory Junctions seguras)
Write-Host 'MULTI-AI AGENTS INTEGRATION (Claude Code, Gemini CLI)'
$integrationConflicts = @()

foreach ($target in $NativeIntegrationTargets) {
    $targetPath = $target.Path
    $toolName = $target.Tool

    # So criar junction se a pasta raiz da ferramenta (~/.claude ou ~/.gemini) existir
    if (-not (Test-Path -LiteralPath $target.Parent -PathType Container)) {
        continue
    }

    if (Test-Path -LiteralPath $targetPath) {
        if (Test-IsCorrectJunction -Path $targetPath -ExpectedTarget $AgentsRoot) {
            Write-Host "[INTEGRATION / PRESENT] $toolName ($targetPath)"
        } else {
            $integrationConflicts += "[INTEGRATION / CONFLICT / PRESERVED] $($toolName): $targetPath ja existe como diretorio independente"
            Write-Host "[INTEGRATION / CONFLICT / PRESERVED] $toolName"
        }
    } elseif ($DryRun) {
        Write-Host "[INTEGRATION / WOULD LINK] $toolName ($targetPath -> $AgentsRoot)"
    } else {
        try {
            $linkOutput = cmd /c "mklink /J `"$targetPath`" `"$AgentsRoot`"" 2>&1
            if ($LASTEXITCODE -eq 0 -and (Test-IsCorrectJunction -Path $targetPath -ExpectedTarget $AgentsRoot)) {
                Write-Host "[INTEGRATION / LINK] $toolName ($targetPath -> $AgentsRoot)"
            } else {
                $integrationConflicts += "[INTEGRATION / ERROR] $($toolName): Falha ao criar junction ($linkOutput)"
                Write-Host "[INTEGRATION / ERROR] $toolName"
            }
        } catch {
            $integrationConflicts += "[INTEGRATION / ERROR] $($toolName): $($_.Exception.Message)"
            Write-Host "[INTEGRATION / ERROR] $toolName"
        }
    }
}

# 6. Integracao de Workspace protegida (-WorkspacePath)
# Regra estrita: NUNCA substituir ou destruir a pasta .agents existente.
# Vincular exclusivamente .agents\agents.
$targetWorkspace = if ($WorkspacePath) { (Resolve-Path $WorkspacePath).Path } else { $null }
if ($targetWorkspace) {
    Write-Host "WORKSPACE AGENTS INTEGRATION: $targetWorkspace"
    $workspaceAgentsDir = Join-Path $targetWorkspace '.agents'
    $canonicalAgentsRoot = Join-Path $env:USERPROFILE '.agents'

    # Se a pasta .agents do workspace for um junction para %USERPROFILE%\.agents, .agents\agents ja esta visivel!
    if ((Test-Path -LiteralPath $workspaceAgentsDir) -and (Test-IsCorrectJunction -Path $workspaceAgentsDir -ExpectedTarget $canonicalAgentsRoot)) {
        Write-Host '[WORKSPACE / PRESENT] .agents/agents (visivel atraves do junction .agents)'
    } else {
        # Se .agents for diretorio fisico independente, gerenciar especificamente .agents\agents
        if (-not (Test-Path -LiteralPath $workspaceAgentsDir -PathType Container)) {
            if (-not $DryRun) {
                $null = New-Item -ItemType Directory -Path $workspaceAgentsDir -Force
            }
        }

        $workspaceTargetAgents = Join-Path $workspaceAgentsDir 'agents'
        if (Test-Path -LiteralPath $workspaceTargetAgents) {
            if (Test-IsCorrectJunction -Path $workspaceTargetAgents -ExpectedTarget $AgentsRoot) {
                Write-Host '[WORKSPACE / PRESENT] .agents/agents junction'
            } else {
                Write-Host '[WORKSPACE / CONFLICT / PRESERVED] .agents/agents ja existe como pasta independente'
            }
        } elseif ($DryRun) {
            Write-Host "[WORKSPACE / WOULD LINK] .agents/agents -> $AgentsRoot"
        } else {
            $null = cmd /c "mklink /J `"$workspaceTargetAgents`" `"$AgentsRoot`"" 2>&1
            if (Test-IsCorrectJunction -Path $workspaceTargetAgents -ExpectedTarget $AgentsRoot) {
                Write-Host "[WORKSPACE / LINKED] .agents/agents -> $AgentsRoot"
            } else {
                Write-Host '[WORKSPACE / ERROR] Falha ao criar junction .agents/agents no workspace'
            }
        }
    }
}

Write-Host 'RESULT:'
if ($DryRun) {
    Write-Host 'DRY RUN'
    exit 0
}
if ($failures.Count -eq 0 -and $integrationConflicts.Count -eq 0) {
    Write-Host 'SUCCESS'
    exit 0
}
Write-Host 'INCOMPLETE'
$failures | ForEach-Object { Write-Host $_ }
$integrationConflicts | ForEach-Object { Write-Host $_ }
exit 1
