if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# env vars
export XDG_CONFIG_HOME="$HOME/.config"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export VERTEX_LOCATION="global"
export EDITOR=nvim

# PATH
export PATH="$HOME/.local/nvim-nightly/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"

# dotnet
export DOTNET_ENVIRONMENT=Development
export ASPNETCORE_ENVIRONMENT=Development

# bun
export BUN_INSTALL="$HOME/.bun"

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

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

# zsh plugins
zinit light Aloxaf/fzf-tab
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# zsh snippets
zinit snippet OMZP::bun
zinit snippet OMZP::gh
zinit snippet OMZP::command-not-found
zinit snippet OMZP::gcloud

# load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# bindings
bindkey -e
bindkey '^y' autosuggest-accept
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

# fzf
export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,bg:#191724,hl:#ebbcba
	--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
	--color=border:#403d52,header:#31748f,gutter:#191724
	--color=spinner:#f6c177,info:#9ccfd8
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# nvim nightly
function update-nvim() {
  local dir="$HOME/.local/nvim-nightly"
  local tmp=$(mktemp -d)
  echo "Downloading nvim nightly..."
  curl -L --output-dir "$tmp" -O https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
  tar xzf "$tmp/nvim-macos-arm64.tar.gz" -C "$tmp"
  rm -rf "$dir"
  mv "$tmp/nvim-macos-arm64" "$dir"
  rm -rf "$tmp"
  xattr -cr "$dir"
  echo "nvim updated: $($dir/bin/nvim --version | head -1)"
}

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

# shell integrations
eval "$(zoxide init --cmd cd zsh)"
eval "$(fzf --zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"

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

if [[ -z "$SSH_CONNECTION" ]]; then
  secret_load NODE_AUTH_TOKEN
  secret_load NPM_PAT
  secret_load GOOGLE_CLOUD_PROJECT
fi
