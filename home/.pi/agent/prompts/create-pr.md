---
description: Branch, commit in logical chunks, and open a PR
argument-hint: "[base-branch]"
---
Create a pull request for the current work. Base branch: ${1:-the repo's default branch}.

Steps:

1. **Branch**: If currently on the default branch, create a new branch with a short descriptive name (e.g. `feat/...`, `fix/...`). If already on a feature branch, use it.

2. **Commit**: Group the changes into reasonable chunks by implemented sub-feature or concern. Make one commit per chunk using conventional commits. Do not make one giant commit, and do not split trivially related changes apart.

   Commit message rules:
   - Subject: `<type>(<scope>): <imperative summary>` — scope optional, imperative mood ("add" not "added"), ≤50 chars where possible, no trailing period.
   - Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`.
   - Body only when needed: non-obvious *why*, breaking changes, migration notes, or linked issues. Wrap at 72 chars, use `-` bullets.
   - Always add a body for breaking changes, security fixes, data migrations, or reverts.
   - Never write "this commit does X", first-person narration, or AI attribution. State intent, not the diff.

3. **PR**: Push the branch and create the PR with `gh pr create`.

PR title and body rules:

- Keep it short-worded. No novel about the change.
- Include only:
  - The key feature or fix (what changed, in a sentence or short bullet list).
  - Any discrepancies or notable deviations found while implementing.
- Do NOT explain why the change was made or how it works. The code is sufficient to see the changes.

Writing style:

- Write commit messages and the PR title/body in plain language per ISO-24495-1:2023: short sentences, common words, active voice, one idea per sentence.
- Keep the final text plain and minimal.
