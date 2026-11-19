---
description: Create a PR (via the create-pr skill) and move the linked Jira/Linear ticket to code review
argument-hint: "[base-branch]"
---
Create a pull request for the current work. Follow the create-pr skill for branching, commits, and the PR title and body.

Base branch: ${1:-the repo's default branch}.

After the PR is open, update the linked ticket:

1. Find the ticket reference. Look for a Jira or Linear key (e.g. `PROJ-123`) or a GitHub issue (e.g. `#123`) in the branch name, the commit messages, or this conversation. If there is none, skip the rest of these steps.
2. Link the PR. Add the PR URL to the ticket as a comment or link, unless the tracker already links it automatically.
3. Move the ticket. Set its status to the closest match for "in code review" (e.g. "In Code Review", "In Review", "Code Review"). If no such status exists, leave the status as it is and tell me.
4. Report. Tell me the ticket key, the old status, and the new status.
