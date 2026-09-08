#!/usr/bin/env bash
# Declarative list of global pi packages for this machine.
#
# settings.json (~/.pi/agent/settings.json) is intentionally gitignored:
# pi rewrites it on every `/model` switch, changelog dismissal, etc., which
# made the "packages" array churn alongside noise we don't care to track.
# This script is the tracked source of truth instead. Safe to re-run;
# `pi install` is idempotent and reconciles the settings.json entry.
#
# Run after cloning dots on a new machine (via `dot init`, or standalone
# after wiping/regenerating ~/.pi/agent/settings.json).
set -euo pipefail

packages=(
  "npm:pi-zentui"
  "npm:pi-mcp-adapter"
  "npm:pi-web-access"
  "npm:@twogiants/pi-anthropic-vertex"
  "npm:@zenobius/pi-rose-pine"
  "npm:@gotgenes/pi-permission-system"
)

for pkg in "${packages[@]}"; do
  echo "==> pi install $pkg"
  pi install "$pkg"
done
