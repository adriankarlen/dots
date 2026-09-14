# Vite+ environment setup (https://viteplus.dev)
$env.PATH = ($env.PATH | where { $in != "~/.local/share/vite-plus/bin" } | prepend "~/.local/share/vite-plus/bin")

# Shell function wrapper: intercepts `vp env use` to parse its stdout,
# which sets/unsets VP_NODE_VERSION in the current shell session.
def --env --wrapped vp [...args: string@"nu-complete vp"] {
    let command_args = if ($args | length) >= 2 and $args.0 == "-C" {
        $args | skip 2
    } else if ($args | length) >= 1 and ($args.0 | str starts-with "-C") and $args.0 != "-C" {
        $args | skip 1
    } else {
        $args
    }
    if ($command_args | length) >= 2 and $command_args.0 == "env" and $command_args.1 == "use" {
        if ("-h" in $args) or ("--help" in $args) {
            ^vp ...$args
            return
        }
        let out = (with-env { VP_ENV_USE_EVAL_ENABLE: "1", VP_SHELL: "nu" } {
            ^vp ...$args
        })
        let lines = ($out | lines)
        let exports = ($lines | where { $in =~ '^\$env\.' } | parse '$env.{key} = "{value}"')
        let export_keys = ($exports | get key? | default [])
        # Exclude keys that also appear in exports: when vp emits `hide-env X` then
        # `$env.X = "v"` (e.g. `vp env use` with no args resolving from .node-version),
        # the set should win.
        let unsets = ($lines | where { $in =~ '^hide-env ' } | parse 'hide-env {key}' | get key? | default [] | where { $in not-in $export_keys })
        if ($exports | is-not-empty) {
            load-env ($exports | reduce -f {} {|it, acc| $acc | insert $it.key $it.value})
        }
        for key in $unsets {
            if ($key in $env) { hide-env $key }
        }
    } else {
        ^vp ...$args
    }
}

# Shell completion for nushell (delegates to fish completions dynamically)
def "nu-complete vp" [context: string] {
    let fish_cmd = $"VP_COMPLETE=fish command vp | source; complete '--do-complete=($context)'"
    fish --command $fish_cmd | from tsv --flexible --noheaders --no-infer | rename value description | update value {|row|
        let value = $row.value
        let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
        if ($need_quote and ($value | path exists)) {
            let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
            $'"($expanded_path | str replace --all "\"" "\\\"")"'
        } else {$value}
    }
}
# Completion logic for vpr (translates context to 'vp run ...')
def "nu-complete vpr" [context: string] {
    let modified_context = if ($context =~ '^vpr(?<cwd>\s+-C\s+(?:"[^"]*"|\x27[^\x27]*\x27|\S+))\s') {
        $context | str replace -r '^vpr(?<cwd>\s+-C\s+(?:"[^"]*"|\x27[^\x27]*\x27|\S+))\s' 'vp$cwd run '
    } else if ($context =~ '^vpr(?<cwd>\s+-C=?(?:"[^"]*"|\x27[^\x27]*\x27|\S+))\s') {
        $context | str replace -r '^vpr(?<cwd>\s+-C=?(?:"[^"]*"|\x27[^\x27]*\x27|\S+))\s' 'vp$cwd run '
    } else if ($context =~ '^vpr\s+-C') {
        $context | str replace -r '^vpr' 'vp'
    } else {
        $context | str replace -r '^vpr' 'vp run'
    }
    let fish_cmd = $"VP_COMPLETE=fish command vp | source; complete '--do-complete=($modified_context)'"
    fish --command $fish_cmd | from tsv --flexible --noheaders --no-infer | rename value description | update value {|row|
        let value = $row.value
        let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
        if ($need_quote and ($value | path exists)) {
            let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
            $'"($expanded_path | str replace --all "\"" "\\\"")"'
        } else {$value}
    }
}
export extern "vpr" [...args: string@"nu-complete vpr"]
