#!/usr/bin/env bash
# Declarative list of Python CLI tools for this machine, installed through
# `uv tool install`. Each tool gets its own isolated virtualenv managed by
# uv, so nothing touches Homebrew's Python or the system Python. Prefer this
# over Homebrew taps that just wrap `pip install` (e.g. sqlit), since those
# lose any extras/drivers the tool installs into its venv on every upgrade.
#
# Entries use pip requirement syntax, so extras go in brackets
# (e.g. "sqlit-tui[mssql]").
#
# Safe to re-run: `uv tool install` no-ops for tools that are already
# installed with the same requirements.
#
# Run after cloning dots on a new machine (via `dot init`), or standalone
# to pick up additions to this list.
set -euo pipefail

tools=(
  "sqlit-tui[mssql]"
)

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not installed, skipping uv tool install" >&2
  exit 0
fi

for tool in "${tools[@]}"; do
  echo "==> uv tool install $tool"
  uv tool install "$tool"
done
