# ~/.zshrc
# Env vars and PATH live in ~/.zshenv so non-interactive shells inherit
# them too. This file is interactive-only setup.

# zinit setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# oh-my-posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/theme.toml")"
fi

# zsh snippets that must be in place before compinit / for `zsh -ilc env`
# callers (gcloud puts its bin dir on PATH).
zinit light zsh-users/zsh-completions
zinit snippet OMZP::bun
zinit snippet OMZP::gh
zinit snippet OMZP::gcloud

# completions: full compinit (security audit + new-file check, then rewrite
# the dump) at most once a day; otherwise load the cached dump with -C.
# After installing new completions mid-day: `rm ~/.zcompdump*` or `compinit`.
# Runs at startup, not deferred: mise's hook runs its own full `compinit` at
# the first prompt if compdef doesn't exist yet.
() {
  setopt localoptions extendedglob
  local dump=${ZDOTDIR:-$HOME}/.zcompdump
  autoload -Uz compinit
  if [[ -n $dump(#qN.mh+24) || ! -s $dump ]]; then
    compinit -d $dump
  else
    compinit -C -d $dump
  fi
  # byte-compile the dump in the background so the next shell loads it faster
  { [[ -s $dump && ( ! -s $dump.zwc || $dump -nt $dump.zwc ) ]] && zcompile $dump } &!
}
zinit cdreplay -q

# fzf keybindings/completion. Must run after fzf-tab so `**<tab>` falls back
# to fzf-tab instead of plain completion.
_zshrc_fzf() {
  eval "$(fzf --zsh)"
}

# plugins, loaded in "turbo" mode: right after the first prompt is drawn
# instead of before it. Order matters and is preserved:
# fzf-tab (after compinit) -> widget wrappers -> fzf.
# Turbo never runs in `zsh -i -c ...` (no prompt), so anything that sets env
# vars tools read via `zsh -ilc env` must stay out of here.
zinit wait lucid for \
  OMZP::command-not-found \
  Aloxaf/fzf-tab \
  zdharma-continuum/fast-syntax-highlighting \
  atload'_zsh_autosuggest_start; bindkey "^y" autosuggest-accept; _zshrc_fzf' \
    zsh-users/zsh-autosuggestions

# bindings
bindkey -e
# ^y -> autosuggest-accept is bound in the autosuggestions atload above: binding
# it before the widget exists makes fast-syntax-highlighting warn at load.
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# history
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 50 8
zstyle ':fzf-tab:*' fzf-flags --height=12
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons -a --group-directories-first --git --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons -a --group-directories-first --git --color=always $realpath'

# opts
setopt auto_cd

# gum
source gum-rose-pine

# fzf
export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,bg:#191724,hl:#ebbcba
	--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
	--color=border:#403d52,header:#31748f,gutter:#191724
	--color=spinner:#f6c177,info:#9ccfd8
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# aliases
alias v="nvim"
alias vim="nvim"
alias c="clear"
alias l="eza -lh --icons=auto --color=always"                                         # long list
alias la="eza -lha --icons=auto --color=always"                                       # long list all
alias ls="eza --icons=auto --color=always"                                            # short list
alias ll="eza -lha --icons=auto --sort=name --group-directories-first --color=always" # long list all
alias ld="eza -lhD --icons=auto --color=always"                                       # long list dirs
alias lt="eza --icons=auto --tree --color=always"                                     # list folder as tree
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."
alias x="exit"

# sqlit: the bundled MS ODBC driver (mssql-python) dlopens libssl/libcrypto from
# /opt/homebrew/opt/openssl/lib, which is now OpenSSL 4 (unsupported). Point it
# at openssl@3 instead; DYLD_LIBRARY_PATH wins over the hardcoded path.
alias sqlit="DYLD_LIBRARY_PATH=/opt/homebrew/opt/openssl@3/lib sqlit"

# shell integrations
eval "$(zoxide init --cmd cd zsh)"
# fzf is loaded with the plugins above (_zshrc_fzf)
# secrets (skip on SSH sessions)
secret_set() {
  security add-generic-password -a "$USER" -s "shell:$1" -w "$2" -U
}
secret_get() {
  security find-generic-password -a "$USER" -s "shell:$1" -w 2>/dev/null
}
secret_load() {
  local val
  val=$(secret_get "$1") || {
    echo "secret '$1' not found in Keychain" >&2
    return 1
  }
  export "${2:-$1}"="$val"
}

# Loaded at startup (not deferred) so `zsh -ilc env` callers such as editors
# still see them. The Keychain reads run in parallel: ~1x instead of ~3x the
# cost of one `security` call.
if [[ -z "$SSH_CONNECTION" ]]; then
  () {
    local name fd val
    local -A fds
    for name in "$@"; do
      exec {fd}< <(secret_get "$name")
      fds[$name]=$fd
    done
    for name in "$@"; do
      fd=$fds[$name]
      val=
      IFS= read -r -u $fd val
      if [[ -n $val ]]; then
        export "$name=$val"
      else
        echo "secret '$name' not found in Keychain" >&2
      fi
      exec {fd}<&-
    done
  } NODE_AUTH_TOKEN NPM_PAT GOOGLE_CLOUD_PROJECT
fi

# mise: shims are on PATH via ~/.zshenv (non-interactive shells, editors);
# activate here so interactive shells switch versions per directory on cd.
eval "$(mise activate zsh)"
