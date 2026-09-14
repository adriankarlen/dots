# Vite+ environment setup (https://viteplus.dev)
while set -l __vp_idx (contains -i -- "$HOME/.local/share/vite-plus/bin" $PATH)
    set -e PATH[$__vp_idx]
end
set -gx PATH "$HOME/.local/share/vite-plus/bin" $PATH

# Shell function wrapper: intercepts `vp env use` to eval its stdout,
# which sets/unsets VP_NODE_VERSION in the current shell session.
function vp
    set -l __vp_command_index 1
    if test (count $argv) -ge 1
        if test "$argv[1]" = "-C"
            set __vp_command_index 3
        else if string match -qr '^-C.+' -- "$argv[1]"
            set __vp_command_index 2
        end
    end
    set -l __vp_next_index (math $__vp_command_index + 1)

    if test (count $argv) -ge $__vp_next_index; and test "$argv[$__vp_command_index]" = "env"; and test "$argv[$__vp_next_index]" = "use"
        if contains -- -h $argv; or contains -- --help $argv
            command vp $argv; return
        end
        set -lx VP_ENV_USE_EVAL_ENABLE 1
        set -lx VP_SHELL fish
        set -l __vp_out (command vp $argv); or return $status
        for __vp_command in $__vp_out
            eval $__vp_command; or return $status
        end
        return 0
    else
        command vp $argv
    end
end

# Dynamic shell completion for fish
VP_COMPLETE=fish command vp | source

function __vpr_complete
    set -l tokens (commandline --current-process --tokenize --cut-at-cursor)
    set -l current (commandline --current-token)
    set -l args $tokens[2..]
    set -l translated vp
    if test (count $args) -eq 0; and string match -qr '^-C' -- "$current"
        # Keep completing the global -C option until its value is finished.
    else if test (count $args) -ge 1; and test "$args[1]" = "-C"
        set -a translated -C
        if test (count $args) -ge 2
            set -a translated "$args[2]" run $args[3..]
        end
    else if test (count $args) -ge 1; and string match -qr '^-C.+' -- "$args[1]"
        set -a translated "$args[1]" run $args[2..]
    else
        set -a translated run $args
    end
    VP_COMPLETE=fish command vp -- $translated $current
end
complete -c vpr --keep-order --exclusive --arguments "(__vpr_complete)"
