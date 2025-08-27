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
brew services start skhd

# Macos defaults
echo "Setting MacOS defaults..."
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# Stow dotfiles
echo "Stowing dotfiles..."
stow .

# Fonts
echo "Installing sketchybar-app-font..."
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.32/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

echo "Installing sketchybar-app-font-bg..."
# Define variables
ZIP_URL="https://github.com/SoichiroYamane/sketchybar-app-font-bg/archive/refs/tags/v0.0.11.zip"
ZIP_FILE="$HOME/Downloads/sketchybar-app-font-bg.zip"
EXTRACT_DIR="$HOME/Downloads/sketchybar-app-font-bg-0.0.11"

# Download, unzip, install, and clean up
curl -L $ZIP_URL -o $ZIP_FILE && \
unzip $ZIP_FILE -d $HOME/Downloads && \
cd $EXTRACT_DIR && \
pnpm install && \
pnpm run build:install && \
rm -rf $ZIP_FILE $EXTRACT_DIR

# Reload shell
echo "Reloading shell..."
source ~/.zshrc
