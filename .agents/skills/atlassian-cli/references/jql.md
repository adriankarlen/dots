# JQL cheat sheet

JQL (Jira Query Language) powers `--jql` on `workitem search`, `edit`, `assign`,
`transition`, `clone`, and `sprint list-workitems`. Full reference:
https://support.atlassian.com/jira-service-management-cloud/docs/use-advanced-search-with-jira-query-language-jql/

## Common fields and operators

| Intent | JQL |
|---|---|
| Everything in a project | `project = TEAM` |
| Assigned to the authenticated user | `assignee = currentUser()` |
| Assigned to a specific person | `assignee = "user@example.com"` |
| Unassigned | `assignee is EMPTY` |
| By status | `status = "In Progress"` |
| Not done | `status != Done` |
| By type | `issuetype = Bug` |
| By label | `labels = "urgent"` |
| Created recently | `created >= -7d` |
| Updated recently | `updated >= -1d` |
| Due soon | `due <= 3d AND due >= now()` |
| Text search | `text ~ "checkout flow"` |
| In a sprint | `sprint = 123` |
| In the current active sprint | `sprint in openSprints()` |
| Reported by someone | `reporter = "user@example.com"` |

## Combining

```
project = TEAM AND assignee = currentUser() AND status != Done
project = TEAM AND issuetype = Bug ORDER BY priority DESC
project in (TEAM, PLAT) AND created >= -30d
```

Quote values containing spaces (`status = "In Progress"`, not `status = In Progress`).
When unsure what values are valid on the user's site (custom statuses, custom fields),
it's fine to just run a broad search first (e.g. `project = TEAM`) and look at the
`status`/`priority` values that come back rather than guessing.
