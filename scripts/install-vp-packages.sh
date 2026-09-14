#!/usr/bin/env bash
# Declarative list of global npm packages for this machine, installed
# through Vite+ (`vp`) instead of Homebrew's Brewfile `npm "..."` entries
# or a bare `npm install -g`. Vite+ manages its own Node.js runtime, and a
# plain `npm install -g` bypasses that management, silently installing into
# whatever Node happens to be on PATH at the time. `vp i -g` always
# installs against the vp-managed runtime, keeping this the single source
# of truth for global npm packages on this machine.
#
# Safe to re-run: `vp i -g` reconciles already-installed packages.
#
# Run after cloning dots on a new machine (via `dot init`), or standalone
# to pick up additions to this list.
set -euo pipefail

packages=(
  "agent-browser"
  "@spp-technology/sppackel-cli"
  "storyquery"
  "svelte-language-server"
  "bash-language-server"
  "prettier"
  "@fsouza/prettierd"
  "typescript"
  "vscode-langservers-extracted"
  "@vtsls/language-server"
  "yaml-language-server"
  "@tailwindcss/language-server"
)

if ! command -v vp >/dev/null 2>&1; then
  echo "vp not installed, skipping vp package install" >&2
  exit 0
fi

echo "==> vp i -g ${packages[*]}"
vp i -g "${packages[@]}"
