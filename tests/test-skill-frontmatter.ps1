[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$installerPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'install-skills.ps1'
$parseTokens = $null
$parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($installerPath, [ref]$parseTokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw 'Installer has PowerShell syntax errors.' }
$descriptionsNode = $ast.Find({ param($node) $node -is [Management.Automation.Language.AssignmentStatementAst] -and $node.Left.Extent.Text -eq '$proactiveDescriptions' }, $true)
$functionNode = $ast.Find({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Optimize-SkillFrontmatter' }, $true)
Invoke-Expression $descriptionsNode.Extent.Text
Invoke-Expression $functionNode.Extent.Text
$proactiveDescriptions['escaping-fixture'] = 'Quotes "value", colon: text, apostrophe''s and C:\source\new.'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('aidev-frontmatter-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $testRoot
try {
    foreach ($name in @($proactiveDescriptions.Keys)) {
        $skillDir = Join-Path $testRoot $name
        $null = New-Item -ItemType Directory -Path $skillDir
        $skillFile = Join-Path $skillDir 'SKILL.md'
        [IO.File]::WriteAllText($skillFile, "---`nname: $name`ndescription: >-`n  Prior description.`n---`n# Fixture`n")
        Optimize-SkillFrontmatter -SkillMdPath $skillFile -SkillName $name
        $raw = [IO.File]::ReadAllText($skillFile)
        $descriptionLine = @($raw -split '\r?\n' | Where-Object { $_ -match '^description:' })
        if ($descriptionLine.Count -ne 1) { throw "Expected one description: $name" }
        # JSON double-quoted strings are valid YAML scalars; parse the exact generated scalar.
        $decoded = $descriptionLine[0].Substring('description:'.Length).Trim() | ConvertFrom-Json
        if ($decoded -cne $proactiveDescriptions[$name]) { throw "Description changed during YAML serialization: $name" }
        Optimize-SkillFrontmatter -SkillMdPath $skillFile -SkillName $name
        if ([IO.File]::ReadAllText($skillFile) -cne $raw) { throw "Non-idempotent frontmatter: $name" }
    }
    Write-Host ('PASS: ' + $proactiveDescriptions.Count + ' installer descriptions serialize as YAML-compatible JSON strings and are idempotent.')
} finally {
    if ((Split-Path -Leaf $testRoot) -notlike 'aidev-frontmatter-*') { throw 'Unexpected test cleanup path.' }
    Remove-Item -LiteralPath $testRoot -Recurse -Force
}
