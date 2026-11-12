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
│   ├── install-pi-packages.sh  # tracked source of truth for `pi install` packages
│   └── install-uv-tools.sh     # Python CLI tools, installed via `uv tool install`
├── home/               # stow package — symlinked into $HOME
│   ├── .stow-local-ignore
│   ├── .zshenv         # env vars + PATH (every zsh, incl. scripts)
│   ├── .zprofile       # re-applies PATH after macOS path_helper
│   ├── .zshrc          # interactive-only setup
│   ├── .agents/
│   ├── .config/
│   │   ├── mise/       # config.toml: runtimes, global npm/.NET/go tools
│   │   └── nvim/       # git submodule → adriankarlen/nvim
│   ├── .local/
│   ├── .pi/
│   └── .plannotator/   # config.json tracked, runtime state ignored
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
listed there via `pi install`, `mise install` for everything in
`home/.config/mise/config.toml`, and `scripts/install-uv-tools.sh`, which
installs Python CLI tools (e.g. sqlit) into isolated uv environments.

`dot update` refreshes everything `init` set up, without repeating the
one-time bootstrap steps: `brew update` + `brew upgrade` + `brew bundle` (so
every formula, cask, and VS Code extension entry in the Brewfile
is brought up to date), pi itself and its installed packages, mise tools
(`mise install` + `mise upgrade`), uv tools (`uv tool upgrade --all`), Yazi
packages, Neovim nightly, and the Spicetify backup. Same `--skip-spicetify`
flag as `init`.

`~/.pi/agent/settings.json` is intentionally gitignored: pi rewrites its
`packages` array on model switches, changelog dismissals, etc., which is
noise we don't want to track. `scripts/install-pi-packages.sh` is the
tracked source of truth instead — edit it when you add/remove a global pi
package, then re-run it (or `./dot init`) to reconcile.

## Tool versions (mise)

[mise](https://mise.jdx.dev) manages runtimes and dev tools: Node, pnpm,
aube, .NET SDKs 8 + 10 (plus `pwsh` and other .NET global tools), go, deno,
uv, terraform/terragrunt, global npm CLIs (LSPs, biome, oxlint, ...) and go
packages. Everything is declared in `home/.config/mise/config.toml`.

- **No `mise.toml` in team repos.** mise reads the version files repos
  already have: `.node-version` and `packageManager` in `package.json`
  (`idiomatic_version_file_enable_tools`). `.nvmrc` is ignored because
  `.node-version` is what CI uses. .NET is deliberately not read from
  `global.json`; .NET's own roll-forward picks among the installed SDKs.
- **Personal per-repo overrides** go in `mise.local.toml`, which
  `home/.config/git/ignore` ignores in every repo.
- **Repos that do commit a `mise.toml`** (infra repos) work as-is; run
  `mise trust` once per repo.
- Shims are on `PATH` from `.zshenv` (scripts, editors, agents); `.zshrc` runs
  `mise activate zsh` for interactive shells.
- `npm:` tools install through mise's embedded aube, which enforces
  supply-chain checks (download count, trust policy). Exceptions go on the
  tool entry (`allow_low_downloads`, `trust_policy_excludes`) after review.

**aube rule:** `aubr <script>` is fine for running scripts in pnpm repos (it
installs first when deps are stale). pnpm stays the only tool that *writes*
`pnpm-lock.yaml` (`add`, `remove`, `update`), since aube does not guarantee
identical version selection.

On a fresh machine:

```sh
git clone <this repo> ~/dots
cd ~/dots
./dot init
```

## Rex

[Rex](https://www.superlogical.com/rex) is configured in Lua under
`home/.config/rex/`. Reload with `rex config reload`; `rex keymap` lists every
binding.

```
rex/
├── init.lua            # only requires the files below
├── config/
│   ├── actions.lua     # custom actions: lazygit, pkgrun tab
│   ├── sessions.lua    # dactyl workspaces, rules and blacklist
│   └── keys.lua        # all key bindings
└── plugins/
    └── dactyl.lua      # session and agent picker
```

Keys follow tmux/herdr: <kbd>Ctrl</kbd>+<kbd>A</kbd> enters a one-shot
`prefix` mode, so `ctrl+a c` opens a tab, `ctrl+a g` opens lazygit and
`ctrl+a t` opens dactyl. Unbound keys do nothing there and Escape cancels.
`ctrl+a r` enters a resize mode that stays on until Escape or Enter.
<kbd>Ctrl</kbd>+<kbd>H/J/K/L</kbd> move between panes, but go to Neovim when it
is focused.

**dactyl** is a session picker in the style of sesh and yeet. It opens a
floating `gum filter` with your open sessions, configured workspaces and
zoxide directories. Picking one switches to it, or creates the session in
that directory first. `ctrl+a shift+b` (or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>K</kbd>)
switches back to the last session.

`ctrl+a a` (or <kbd>Cmd</kbd>+<kbd>J</kbd>) opens dactyl's agent picker. It
lists the coding agents running in every session, with the status they
report through the [Program Status Protocol](https://www.superlogical.com/rex/docs/build/program-status)
(blocked, error, done, working, idle). Agents that need you come first.
Picking one switches to its session and focuses its pane. Agents that don't
report a status are found by process name (`agents.processes` in
`sessions.lua`) and shown as `unknown`.

Rex.app must have **Remote Control** turned on (Settings → Rex Server), or
dactyl can't switch sessions.
