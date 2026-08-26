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
├── Brewfile            # Homebrew formulae/casks (not stowed)
├── home/               # stow package — symlinked into $HOME
│   ├── .stow-local-ignore
│   ├── .zshrc
│   ├── .agents/
│   ├── .config/
│   ├── .local/
│   └── .pi/
└── readme.md
```

## `dot`

```sh
./dot init      # bootstrap a fresh machine (Homebrew, packages, stow, ...)
./dot stow      # (re)create symlinks from home/ into $HOME — default command
./dot unstow    # remove all stow-managed symlinks
./dot doctor    # verify Homebrew/stow install + symlink health
./dot link      # put `dot` on PATH at ~/.local/bin/dot
./dot edit      # open the repo in $EDITOR
./dot help      # full command list
```

`dot init` is safe to re-run — every step checks existing state before doing
work. Useful flags: `--skip-services` (skip macOS defaults + skhd/sketchybar/
borders) and `--skip-spicetify`.

On a fresh machine:

```sh
git clone <this repo> ~/dots
cd ~/dots
./dot init
```
