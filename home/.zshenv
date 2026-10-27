# ~/.zshenv
# Read by every zsh invocation (interactive, login and script alike).
# Env vars and PATH live here rather than in .zshrc so that non-interactive
# shells (scripts, `zsh -c`, editor/agent subprocesses) get them too.
#
# macOS caveat: /etc/zprofile runs path_helper *after* this file in login
# shells, which shoves the system paths in front of ours. ~/.zprofile
# re-sources this file to put our PATH order back.

# keep PATH free of duplicates across nested shells / re-sourcing
typeset -U path PATH

# homebrew
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# env vars
export XDG_CONFIG_HOME="$HOME/.config"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export LAZYJIRA_CONFIG_DIR="$HOME/.config/lazyjira"
export VERTEX_LOCATION="global"
export GOOGLE_CLOUD_LOCATION="global"
# Claude on Vertex: same EU multi-region endpoint as storecode (CLOUD_ML_REGION=eu).
# The Vertex SDK can't derive the eu URL itself, so set it explicitly.
export CLOUD_ML_REGION="eu"
export ANTHROPIC_VERTEX_BASE_URL="https://aiplatform.eu.rep.googleapis.com/v1"
export EDITOR=nvim

# dotnet
export DOTNET_ENVIRONMENT=Development
export ASPNETCORE_ENVIRONMENT=Development

# bun
export BUN_INSTALL="$HOME/.bun"

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# PATH
export PATH="$HOME/.local/nvim-nightly/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Vite+ bin (https://viteplus.dev)
[[ -f "$HOME/.config/vite-plus/env" ]] && . "$HOME/.config/vite-plus/env"
