#!/bin/zsh

# Install command line tools
echo "Installing command line tools..."
xcode-select --install

# Install Homebrew
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Install Homebrew packages using Brewfile
echo "Installing Homebrew packages..."
brew bundle --file=./Brewfile

# Start Services
echo "Starting Services (grant permissions)..."
brew services start skhd

# Macos defaults
echo "Setting MacOS defaults..."
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

