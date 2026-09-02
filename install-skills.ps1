[CmdletBinding()]
param([switch]$DryRun)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SkillsRoot = Join-Path $env:USERPROFILE '.agents\skills'
$Managed = @(
    [pscustomobject]@{ Name = 'context-engineering'; Repo = 'addyosmani/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'context-engineering' }
    [pscustomobject]@{ Name = 'prompt-master'; Repo = 'nidhinjs/prompt-master'; SourceType = 'repo-root'; Subpath = '.'; ExpectedName = 'prompt-master' }
    [pscustomobject]@{ Name = 'systematic-debugging'; Repo = 'obra/superpowers'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'systematic-debugging' }
    [pscustomobject]@{ Name = 'verification-before-completion'; Repo = 'obra/superpowers'; SourceType = 'subpath'; Subpath = 'skills/verification-before-completion'; ExpectedName = 'verification-before-completion' }
    [pscustomobject]@{ Name = 'vercel-react-best-practices'; Repo = 'vercel-labs/agent-skills'; SourceType = 'subpath'; Subpath = 'skills/react-best-practices'; ExpectedName = 'vercel-react-best-practices' }
    [pscustomobject]@{ Name = 'ui-ux-pro-max'; Repo = 'nextlevelbuilder/ui-ux-pro-max-skill'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'ui-ux-pro-max' }
    [pscustomobject]@{ Name = 'frontend-design'; Repo = 'anthropics/claude-code'; SourceType = 'subpath'; Subpath = 'plugins/frontend-design/skills/frontend-design'; ExpectedName = 'frontend-design' }
    [pscustomobject]@{ Name = 'web-design-guidelines'; Repo = 'vercel-labs/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'web-design-guidelines' }
    [pscustomobject]@{ Name = 'supabase'; Repo = 'supabase/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'supabase' }
    [pscustomobject]@{ Name = 'supabase-postgres-best-practices'; Repo = 'supabase/agent-skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'supabase-postgres-best-practices' }
    [pscustomobject]@{ Name = 'security-best-practices'; Repo = 'openai/skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'security-best-practices' }
    [pscustomobject]@{ Name = 'security-threat-model'; Repo = 'openai/skills'; SourceType = 'discover-by-skill-name'; Adapter = 'discover-by-skill-name'; ExpectedName = 'security-threat-model' }
    [pscustomobject]@{ Name = 'finding-google-skills'; Repo = 'google/skills'; SourceType = 'subpath'; Subpath = 'skills/developers/finding-google-skills'; ExpectedName = 'finding-google-skills' }
    [pscustomobject]@{ Name = 'graphify'; Repo = 'Graphify-Labs/graphify'; Branch = 'v8'; SourceType = 'graphify-adapter'; Adapter = 'graphify-agents'; ExpectedName = 'graphify' }
    [pscustomobject]@{ Name = 'playwright'; Repo = 'openai/skills'; SourceType = 'subpath'; Subpath = 'skills/.curated/playwright'; ExpectedName = 'playwright' }
    [pscustomobject]@{ Name = 'caveman'; Repo = 'JuliusBrussee/caveman'; SourceType = 'subpath'; Subpath = 'skills/caveman'; ExpectedName = 'caveman' }
)

function Test-SkillDirectory {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$ExpectedName)
    $skillFile = Join-Path $Path 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) { return $false }
    if ((Get-Item -LiteralPath $skillFile).Length -le 0) { return $false }
    $lines = @(Get-Content -LiteralPath $skillFile -ErrorAction Stop)
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

function Resolve-SkillPath {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$RepositoryPath)
    $subpath = if ($Skill.PSObject.Properties.Name -contains 'Subpath') { $Skill.Subpath } else { $null }
    $expectedName = if ($Skill.PSObject.Properties.Name -contains 'ExpectedName') { $Skill.ExpectedName } else { $Skill.Name }
    if ($subpath) {
        $candidate = Join-Path $RepositoryPath ($subpath -replace '/', '\')
        if (-not (Test-SkillDirectory -Path $candidate -ExpectedName $expectedName)) { throw "Upstream structure changed: $($Skill.Name) — subpath esperado: $subpath" }
        return $candidate
    }
    $skillMatches = @(Get-ChildItem -LiteralPath $RepositoryPath -Directory -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ieq $Skill.Name -and (Test-SkillDirectory -Path $_.FullName -ExpectedName $expectedName) } |
        Select-Object -ExpandProperty FullName)
    if ($skillMatches.Count -ne 1) { throw "subpath não pôde ser resolvido de forma única (encontrados: $($skillMatches.Count))" }
    return $skillMatches[0]
}

function New-GraphifyStaging {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$RepositoryPath, [Parameter(Mandatory)][string]$StagingPath)
    $source = Join-Path $RepositoryPath 'graphify\skill-agents.md'
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw 'Upstream structure changed: graphify — subpath esperado: graphify/skill-agents.md' }
    $null = New-Item -ItemType Directory -Path $StagingPath -Force
    Copy-Item -LiteralPath $source -Destination (Join-Path $StagingPath 'SKILL.md') -Force
    $references = Join-Path $RepositoryPath 'graphify\skills\agents\references'
    if (Test-Path -LiteralPath $references -PathType Container) {
        Copy-Item -LiteralPath $references -Destination (Join-Path $StagingPath 'references') -Recurse -Force
    }
    if (-not (Test-SkillDirectory -Path $StagingPath -ExpectedName $Skill.Name)) { throw 'Graphify: validação da Skill em staging falhou' }
    return $StagingPath
}

function Invoke-GitClone {
    param([string]$Repo, [string]$Destination, [string]$Branch)
    $cloneArgs = @('clone', '--depth', '1', '--quiet')
    if ($Branch) { $cloneArgs += @('--branch', $Branch) }
    $cloneArgs += @("https://github.com/$Repo.git", $Destination)
    $output = @(& git @cloneArgs 2>&1)
    if ($LASTEXITCODE -ne 0) { throw (($output | ForEach-Object ToString) -join "`n") }
}

function Set-ManagedSkill {
    param([Parameter(Mandatory)]$Skill, [Parameter(Mandatory)][string]$SourcePath)
    $destination = Join-Path $SkillsRoot $Skill.Name
    $backup = Join-Path ([IO.Path]::GetTempPath()) ("aidev-skill-backup-{0}" -f [guid]::NewGuid().ToString('N'))
    $hadExisting = Test-Path -LiteralPath $destination -PathType Container
    try {
        if ($hadExisting) { Copy-Item -LiteralPath $destination -Destination $backup -Recurse -Force; Remove-Item -LiteralPath $destination -Recurse -Force }
        $null = New-Item -ItemType Directory -Path $destination -Force
        Copy-Item -Path (Join-Path $SourcePath '*') -Destination $destination -Recurse -Force
        if (-not (Test-SkillDirectory -Path $destination -ExpectedName $Skill.Name)) { throw 'validação pós-cópia falhou' }
    } catch {
        if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force -ErrorAction SilentlyContinue }
        if ($hadExisting -and (Test-Path -LiteralPath $backup)) { Move-Item -LiteralPath $backup -Destination $destination -Force }
        throw
    } finally { if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force -ErrorAction SilentlyContinue } }
}

Write-Host 'MANAGED SKILLS'
$git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $git) {
    Write-Host '[PREREQUISITE] Git is required. Run SETUP-AI-ENVIRONMENT.md first.'
    exit 2
}
try {
    $gitVersion = @(& $git.Source --version 2>&1)
    if ($LASTEXITCODE -ne 0) { throw (($gitVersion | ForEach-Object ToString) -join "`n") }
} catch {
    Write-Host '[PREREQUISITE] Git is required. Run SETUP-AI-ENVIRONMENT.md first.'
    Write-Host "[ERROR] git --version: $($_.Exception.Message)"
    exit 2
}
if ($DryRun -and -not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) { Write-Host "[CHECK] diretório ausente: $SkillsRoot (não será criado em dry-run)" }
elseif (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) { $null = New-Item -ItemType Directory -Path $SkillsRoot -Force }

$repoCache = @{}
$failures = @()
foreach ($skill in $Managed) {
    $destination = Join-Path $SkillsRoot $skill.Name
    $present = Test-SkillDirectory -Path $destination -ExpectedName $skill.Name
    if ($DryRun) {
        if ($present) { Write-Host "[PRESENT / MANAGED] $($skill.Name)" }
        else { Write-Host "[WOULD INSTALL] $($skill.Name) from $($skill.Repo)" }
        continue
    }
    try {
        if (-not $repoCache.ContainsKey($skill.Repo)) {
            $repoWorkspace = Join-Path ([IO.Path]::GetTempPath()) ("aidev-repo-{0}" -f [guid]::NewGuid().ToString('N'))
            $null = New-Item -ItemType Directory -Path $repoWorkspace -Force
            $branch = if ($skill.PSObject.Properties.Name -contains 'Branch') { $skill.Branch } else { $null }
            Invoke-GitClone -Repo $skill.Repo -Destination $repoWorkspace -Branch $branch
            $repoCache[$skill.Repo] = $repoWorkspace
        }
        $repoPath = $repoCache[$skill.Repo]
        $adapter = if ($skill.PSObject.Properties.Name -contains 'Adapter') { $skill.Adapter } else { $null }
        $sourcePath = if ($adapter -eq 'graphify-agents') {
            $staging = Join-Path $repoPath '.aidev-graphify-staging'
            New-GraphifyStaging -Skill $skill -RepositoryPath $repoPath -StagingPath $staging
        } else { Resolve-SkillPath -Skill $skill -RepositoryPath $repoPath }
        Write-Host "[$(if ($present) { 'UPDATE' } else { 'INSTALL' })] $($skill.Name)"
        Set-ManagedSkill -Skill $skill -SourcePath $sourcePath
        Write-Host "[OK] $($skill.Name)"
    } catch {
        $failureMessage = $_.Exception.Message
        $failureLabel = if ($failureMessage -match 'unable to access|Could not connect|Failed to connect|port 443|network|DNS') { 'BLOCKED_BY_ENVIRONMENT' } else { 'ERROR' }
        $failures += "[$failureLabel] $($skill.Name): $failureMessage"
        Write-Host "[$failureLabel] $($skill.Name): $failureMessage"
    }
}

foreach ($external in @(Get-ChildItem -LiteralPath $SkillsRoot -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @($Managed.Name) })) { Write-Host "[PRESERVE EXTERNAL] $($external.Name)" }
foreach ($workspace in @($repoCache.Values)) { if (Test-Path -LiteralPath $workspace) { Remove-Item -LiteralPath $workspace -Recurse -Force -ErrorAction SilentlyContinue } }

Write-Host 'RESULT:'
if ($DryRun) { Write-Host 'DRY RUN' ; exit 0 }
if ($failures.Count -eq 0) { Write-Host 'SUCCESS'; exit 0 }
Write-Host 'INCOMPLETE'
$failures | ForEach-Object { Write-Host $_ }
exit 1
