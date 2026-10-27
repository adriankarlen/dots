# ~/.zprofile
# Login shells only. Runs after /etc/zprofile, whose path_helper call moves
# /usr/bin & co. in front of the PATH entries set in ~/.zshenv. Re-source it
# so homebrew, ~/.local/bin, etc. win again (`typeset -U` drops duplicates).
source "${ZDOTDIR:-$HOME}/.zshenv"
