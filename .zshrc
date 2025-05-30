if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# zinit setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# oh-my-posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/theme.toml)"
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

# load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# bindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# history
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons -a --group-directories-first --git --color=always $realpath' 
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons -a --group-directories-first --git --color=always $realpath'

# env vars
export XDG_CONFIG_HOME="$HOME/.config"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export EDITOR=nvim

# opts
setopt auto_cd

#fzf
export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,bg:-1,hl:#ebbcba
	--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
	--color=border:#403d52,header:#31748f,gutter:#191724
	--color=spinner:#f6c177,info:#9ccfd8
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# aliases
alias v="nvim"
alias vim="nvim"
alias lkjh="nvim"
alias c="clear"
alias l="eza -lh --icons=auto --color=always" # long list
alias ls="eza --icons=auto --color=always" # short list
alias ll="eza -lha --icons=auto --sort=name --group-directories-first --color=always" # long list all
alias ld="eza -lhD --icons=auto --color=always" # long list dirs
alias lt="eza --icons=auto --tree --color=always" # list folder as tree
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."
alias gr="/"
alias gd="cd ~/dots"
alias gdev="cd ~/repos"
alias lg="lazygit"
alias x="exit"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [ -z "$WEZTERM_EXECUTABLE" ]; then
  exec tmux
fi

# shell integrations
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

nerdfetch

