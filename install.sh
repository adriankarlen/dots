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

# Reload shell
echo "Done! Restart your shell."
