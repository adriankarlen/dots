# Vite+ environment setup (https://viteplus.dev)
$__vp_bin = '/Users/adriankarlen/.local/share/vite-plus/bin'
if ($env:Path -split ';' -notcontains $__vp_bin) {
    $env:Path = "$__vp_bin;$env:Path"
}

# Shell function wrapper: intercepts `vp env use` to eval its stdout,
# which sets/unsets VP_NODE_VERSION in the current shell session.
function vp {
    $__vp_command_index = 0
    if ($args.Count -ge 1) {
        if ($args[0] -eq "-C") {
            $__vp_command_index = 2
        } elseif ("$($args[0])" -like "-C?*") {
            $__vp_command_index = 1
        }
    }
    if ($args.Count -ge ($__vp_command_index + 2) -and $args[$__vp_command_index] -eq "env" -and $args[$__vp_command_index + 1] -eq "use") {
        if ($args -contains "-h" -or $args -contains "--help") {
            & (Join-Path $__vp_bin "vp") @args; return
        }
        $env:VP_ENV_USE_EVAL_ENABLE = "1"
        $env:VP_SHELL = "pwsh"
        $output = & (Join-Path $__vp_bin "vp") @args 2>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                Write-Host $_.Exception.Message
            } else {
                $_
            }
        }
        Remove-Item Env:VP_ENV_USE_EVAL_ENABLE -ErrorAction SilentlyContinue
        Remove-Item Env:VP_SHELL -ErrorAction SilentlyContinue
        if ($LASTEXITCODE -eq 0 -and $output) {
            Invoke-Expression ($output -join "`n")
        }
    } else {
        & (Join-Path $__vp_bin "vp") @args
    }
}

# Dynamic shell completion for PowerShell
$env:VP_COMPLETE = "powershell"
& (Join-Path $__vp_bin "vp") | Out-String | Invoke-Expression
Remove-Item Env:\VP_COMPLETE -ErrorAction SilentlyContinue

$__vpr_comp = {
    param($wordToComplete, $commandAst, $cursorPosition)
    $prev = $env:VP_COMPLETE
    $env:VP_COMPLETE = "powershell"
    $commandLine = $commandAst.Extent.Text
    $args = $commandLine.Substring(0, [math]::Min($cursorPosition, $commandLine.Length))
    if ($args -match '^(vpr\.exe|vpr)\b(\s+-C\s+(?:"[^"]*"|''[^'']*''|\S+))\s') {
        $args = $args -replace '^(vpr\.exe|vpr)\b(\s+-C\s+(?:"[^"]*"|''[^'']*''|\S+))\s', 'vp$2 run '
    } elseif ($args -match '^(vpr\.exe|vpr)\b(\s+-C=?(?:"[^"]*"|''[^'']*''|\S+))\s') {
        $args = $args -replace '^(vpr\.exe|vpr)\b(\s+-C=?(?:"[^"]*"|''[^'']*''|\S+))\s', 'vp$2 run '
    } elseif ($args -match '^(vpr\.exe|vpr)\b\s+-C') {
        $args = $args -replace '^(vpr\.exe|vpr)\b', 'vp'
    } else {
        $args = $args -replace '^(vpr\.exe|vpr)\b', 'vp run'
    }
    if ($wordToComplete -eq "") { $args += " ''" }
    $results = Invoke-Expression @"
& (Join-Path $__vp_bin 'vp') -- $args
"@;
    if ($prev) { $env:VP_COMPLETE = $prev } else { Remove-Item Env:\VP_COMPLETE }
    $results | ForEach-Object {
        $split = $_.Split("`t")
        $cmd = $split[0];
        if ($split.Length -eq 2) { $help = $split[1] } else { $help = $split[0] }
        [System.Management.Automation.CompletionResult]::new($cmd, $cmd, 'ParameterValue', $help)
    }
}
Register-ArgumentCompleter -Native -CommandName vpr -ScriptBlock $__vpr_comp
