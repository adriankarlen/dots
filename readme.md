# ☕ dots

Personal macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/)
and a small `dot` CLI. Structure mirrors [dots-fedora](https://github.com/adriankarlen/dots-fedora):
all stowed configuration lives under `home/`, so the repo root itself never
looks like a project that happens to contain `.agents`/`.pi`/`.config` —
those are global, not project-local.

<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/440b8567-9f7a-43c3-8d6c-1b220e3e2e56" />

## Layout

```
dots/
├── dot                 # CLI: stow management + machine bootstrap
├── packages/
│   └── Brewfile        # Homebrew formulae/casks (not stowed)
├── scripts/
│   └── install-pi-packages.sh  # tracked source of truth for `pi install` packages
├── home/               # stow package — symlinked into $HOME
│   ├── .stow-local-ignore
│   ├── .zshrc
│   ├── .agents/
│   ├── .config/
│   │   └── nvim/       # git submodule → adriankarlen/nvim
│   ├── .local/
│   └── .pi/
└── readme.md
```

`home/.config/nvim` is a git submodule pointing at
[adriankarlen/nvim](https://github.com/adriankarlen/nvim), so it can be
reused standalone outside of `dots` too. `dot stow` (and therefore `dot
init`, which calls it) always runs `git submodule update --init --recursive`
first, so plain `git clone` (without `--recurse-submodules`) is fine — the
submodule gets synced the first time you run `dot stow`.

## `dot`

```sh
./dot init      # bootstrap a fresh machine (Homebrew, packages, stow, ...)
./dot update    # update everything already installed on this machine
./dot stow      # (re)create symlinks from home/ into $HOME — default command
./dot unstow    # remove all stow-managed symlinks
./dot doctor    # verify Homebrew/stow install + symlink health
./dot link      # put `dot` on PATH at ~/.local/bin/dot
./dot edit      # open the repo in $EDITOR
./dot help      # full command list
```

`dot init` is safe to re-run — every step checks existing state before doing
work. Useful flags: `--skip-services` (skip macOS defaults + skhd/sketchybar/
borders) and `--skip-spicetify`. As one of its steps, it also runs
`scripts/install-pi-packages.sh`, which installs the global `pi` packages
listed there via `pi install`.

`dot update` refreshes everything `init` set up, without repeating the
one-time bootstrap steps: `brew update` + `brew upgrade` + `brew bundle` (so
every formula, cask, go, npm, and VS Code extension entry in the Brewfile
is brought up to date), pi itself and its installed packages, tmux plugins
(TPM), Yazi packages, Neovim nightly, Node LTS (via fnm), and the Spicetify
backup. Same `--skip-spicetify` flag as `init`.

`~/.pi/agent/settings.json` is intentionally gitignored: pi rewrites its
`packages` array on model switches, changelog dismissals, etc., which is
noise we don't want to track. `scripts/install-pi-packages.sh` is the
tracked source of truth instead — edit it when you add/remove a global pi
package, then re-run it (or `./dot init`) to reconcile.

On a fresh machine:

```sh
git clone <this repo> ~/dots
cd ~/dots
./dot init
```
