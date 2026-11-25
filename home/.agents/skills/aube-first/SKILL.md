---
name: aube-first
description: >
  Use aube instead of pnpm/npm/yarn/bun for Node.js package management on
  this machine. Trigger before running any package-manager command
  (pnpm install, npm run, npx, yarn add, bun install, ...) and when a repo's
  AGENTS.md, README, or CONTRIBUTING prescribes a different package manager
  than aube.
---

# aube-first

This machine runs Node.js packages through aube, regardless of what the repo
docs say. aube is a pnpm-compatible package manager that reads and writes the
repo's *existing* lockfile in place — `pnpm-lock.yaml` (v9/v13),
`package-lock.json`, `npm-shrinkwrap.json`, `yarn.lock`, `bun.lock` — so team
repos stay untouched and no parallel lockfile appears. The lockfile diff an
aube install produces is what pnpm itself would have written.

## Command map

Most names are identical (`install`, `add`, `remove`, `update`, `run`, `exec`,
`list`, `why`, `approve-builds`, workspace `--filter`). Differences:

| Usual command | aube |
| --- | --- |
| `npx <pkg>` / `pnpm dlx <pkg>` / `bunx <pkg>` | `aube dlx <pkg>` |
| `pnpm env use <ver>` | `aube runtime set <ver>` |
| `pnpm install-test` | `aube test` (auto-installs first) |

`aube run`/`exec`/`test` check install staleness and auto-install before
running — expected behavior, not an error.

`pkgrun <script> [args...]` (`~/.local/bin/pkgrun`) is a thin wrapper over
`aube run`; use it for the generic "run a package.json script" case.

## When to fall back to the real package manager

- **Old pnpm lockfiles.** aube only reads `pnpm-lock.yaml` v9 (pnpm 9+) and
  v13. v5.x/v6.0 (pnpm 8.x and earlier) → aube refuses (exit 16). Run mise's
  real `pnpm` instead (still on PATH).
- **bun as a runtime.** Translate only bun's package-management verbs
  (`bun install/add/remove/run <script>` → aube). `bun <file.ts>`, `bun test`
  against `bun:test`, and bun-specific APIs need real bun — keep them.
- **Exact pnpm semantics required.** Some flags are parsed for pnpm
  compatibility without full behavior (e.g. recursive `run --no-bail` still
  stops at first failure). If a script depends on that, use real `pnpm`.
- If aube errors unexpectedly on a repo, fall back to the lockfile's real
  package manager rather than converting or deleting lockfiles.

## Repo hygiene

- Never create or commit `aube-lock.yaml`/`aube-workspace.yaml` in a repo
  that already has a lockfile or `pnpm-workspace.yaml` — aube reads and
  updates those in place, and only new projects get aube-named files.
- `node_modules/.aube/` and `node_modules/.aube-state/` are local install
  state; they never belong in a commit.
- Install scripts of new dependencies are blocked by default (pnpm v11
  allowBuilds model). `aube approve-builds` records reviewed approvals in the
  workspace yaml.
