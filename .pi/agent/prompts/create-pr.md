---
description: Branch, commit in logical chunks, and open a PR
argument-hint: "[base-branch]"
---
Create a pull request for the current work. Base branch: ${1:-the repo's default branch}.

Steps:

1. **Branch**: If currently on the default branch, create a new branch with a short descriptive name (e.g. `feat/...`, `fix/...`). If already on a feature branch, use it.

2. **Commit**: Group the changes into reasonable chunks by implemented sub-feature or concern. Make one commit per chunk with a clear, conventional-style message. Do not make one giant commit, and do not split trivially related changes apart.

3. **PR**: Push the branch and create the PR with `gh pr create`.

PR title and body rules:

- Keep it short-worded. No novel about the change.
- Include only:
  - The key feature or fix (what changed, in a sentence or short bullet list).
  - Any discrepancies or notable deviations found while implementing.
- Do NOT explain why the change was made or how it works. The code is sufficient to see the changes.

Writing style:

- After drafting the PR title and body, review the text using the humanizer skill (read `~/.claude/skills/humanizer/SKILL.md` and apply its guidance) to remove AI-sounding phrasing.
- Trim anything the humanizer flags; keep the final text plain and minimal.
