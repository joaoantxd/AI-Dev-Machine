# .agents/scripts/safety-check.ps1
# Hook script for Antigravity PreToolUse safety gate

$inputRaw = [Console]::In.ReadToEnd()
if (-not $inputRaw) {
    [Console]::Out.WriteLine('{"decision":"allow"}')
    exit 0
}

try {
    $data = $inputRaw | ConvertFrom-Json
    $cmd = ''
    if ($data.toolCall -and $data.toolCall.args -and $data.toolCall.args.CommandLine) {
        $cmd = $data.toolCall.args.CommandLine
    }

    # Check for dangerous patterns
    if ($cmd -match '(?i)(git\s+push\s+.*--force|drop\s+database|truncate\s+table|format\s+[a-z]:|rmdir\s+/s\s+/q\s+c:\\|rm\s+-rf\s+/)') {
        [Console]::Out.WriteLine('{"decision":"ask","reason":"Potentially destructive command detected. User confirmation required."}')
    } else {
        [Console]::Out.WriteLine('{"decision":"allow"}')
    }
} catch {
    [Console]::Out.WriteLine('{"decision":"allow"}')
}
exit 0
