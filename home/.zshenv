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

# dotnet (SDKs + global tools installed by mise into one shared root;
# tool apphosts like roslyn-language-server need DOTNET_ROOT to find it)
export DOTNET_ROOT="$HOME/.local/share/mise/dotnet-root"
export DOTNET_ENVIRONMENT=Development
export ASPNETCORE_ENVIRONMENT=Development

# bun
export BUN_INSTALL="$HOME/.bun"

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# PATH, highest priority first. Entries above $path override homebrew/system;
# entries below are fallbacks (third-party tool dirs that shouldn't shadow
# system commands).
path=(
  $HOME/.local/bin
  $HOME/.local/nvim-nightly/bin
  $HOME/.local/share/mise/shims # mise tools (node, pnpm, dotnet, go, ...); see ~/.config/mise/config.toml
  $BUN_INSTALL/bin
  $path # homebrew + system
  $HOME/go/bin
  $HOME/.spicetify
)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
