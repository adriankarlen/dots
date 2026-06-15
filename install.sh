#!/bin/zsh

# Install Homebrew
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Install Homebrew packages using Brewfile
echo "Installing Homebrew packages..."
brew bundle --file=./Brewfile

# Start Services
echo "Starting Services (grant permissions)..."
skhd --install-service
skhd --start-service
brew services start sketchybar
brew services start borders

# Macos defaults
echo "Setting MacOS defaults..."
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# Stow dotfiles
echo "Stowing dotfiles..."
stow .

# Spicetify
if [ -d "/Applications/Spotify.app" ]; then
  echo "Setting up Spicetify..."
  spicetify backup apply
fi

# Neovim nightly
echo "Installing Neovim nightly..."
mkdir -p "$HOME/.local"
_nvim_tmp=$(mktemp -d)
curl -L --output-dir "$_nvim_tmp" -O https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
tar xzf "$_nvim_tmp/nvim-macos-arm64.tar.gz" -C "$_nvim_tmp"
rm -rf "$HOME/.local/nvim-nightly"
mv "$_nvim_tmp/nvim-macos-arm64" "$HOME/.local/nvim-nightly"
rm -rf "$_nvim_tmp"
xattr -cr "$HOME/.local/nvim-nightly"

# Node LTS via fnm
echo "Installing Node LTS via fnm..."
eval "$(fnm env --shell zsh)"
fnm install --lts
fnm default lts-latest

# tmux TPM plugins
echo "Installing tmux plugins..."
TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins" \
  "$HOMEBREW_PREFIX/opt/tpm/share/tpm/bin/install_plugins"

# Yazi packages
echo "Installing Yazi packages..."
ya pack -i

# Reload shell
echo "Done! Restart your shell."
