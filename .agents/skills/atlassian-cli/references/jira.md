# Jira commands (`acli jira ...`)

Run `acli jira <command> --help` or `acli jira <command> <subcommand> --help` for the
authoritative, current flag list — acli is updated often and this file can drift. Treat
this as a map of what exists, not a guarantee of exact flags.

## Command tree

```
acli jira
├── auth        login | logout | status | switch
├── board       create | delete | list-projects | list-sprints | search | view
├── dashboard   search
├── field       create | delete | restore | update
├── filter      list | search | update | view | add-favourite | change-owner |
│               list-columns | reset-columns
├── project     archive | create | delete | list | restore | update | view
├── sprint      create | delete | list-workitems | update | view
└── workitem    archive | assign | attachment | clone | comment | create |
                create-bulk | delete | edit | link | list-watchers | search |
                transition | unarchive | view | watcher
```

## workitem

**search** — the main way to find tickets.
```
acli jira workitem search --jql "project = TEAM" --paginate
acli jira workitem search --jql "project = TEAM AND assignee = currentUser()" --json
acli jira workitem search --filter 10001 --web
```
Key flags: `--jql`, `--filter`, `-f/--fields` (default
`issuetype,key,assignee,priority,status,summary`), `-l/--limit`, `--paginate`, `--count`,
`--json`, `--csv`, `-w/--web`.

**view** — full details on one or more known keys.
```
acli jira workitem view KEY-123
acli jira workitem view KEY-123 --fields summary,comment
acli jira workitem view KEY-123 --web
```
`-f/--fields` accepts `*all`, `*navigable`, a comma list, or `-fieldname` to exclude.
Default fields: `key,issuetype,summary,status,assignee,description`.

**create**
```
acli jira workitem create --summary "New Task" --project TEAM --type Task
acli jira workitem create --from-file workitem.txt --project PROJ --type Bug \
  --assignee user@example.com --label "bug,cli"
acli jira workitem create --generate-json   # prints an example JSON structure
acli jira workitem create --from-json workitem.json
```
Flags: `-s/--summary`, `-p/--project`, `-t/--type`, `-d/--description` (plain text or ADF),
`--description-file`, `-a/--assignee` (`@me` / `default` / email), `-l/--label`,
`--parent`, `-e/--editor` (opens $EDITOR), `-f/--from-file`, `--from-json`,
`--generate-json`, `--json`.

**create-bulk**
```
acli jira workitem create-bulk --from-csv issues.csv
acli jira workitem create-bulk --from-json issues.json
acli jira workitem create-bulk --generate-json
```
CSV columns: `summary,projectKey,issueType,description,label,parentIssueId,assignee`.

**edit**
```
acli jira workitem edit --key "KEY-1,KEY-2" --summary "New Summary"
acli jira workitem edit --jql "project = TEAM" --assignee user@example.com
acli jira workitem edit --filter 10001 --description "Updated description" --yes
```
Target with `-k/--key`, `--jql`, or `--filter` (pick one). Editable:
`-s/--summary`, `-d/--description`/`--description-file`, `-a/--assignee`,
`--remove-assignee`, `-l/--labels`, `--remove-labels`, `-t/--type`. `--ignore-errors` to
keep going on a bulk edit if one target fails. `-y/--yes` skips the confirmation prompt.

**transition** — change workflow status.
```
acli jira workitem transition --key "KEY-1,KEY-2" --status "Done"
acli jira workitem transition --jql "project = TEAM" --status "In Progress"
```
Same targeting flags as `edit` (`--key`/`--jql`/`--filter`), plus `-s/--status`.

**assign**
```
acli jira workitem assign --key KEY-1 --assignee "@me"
acli jira workitem assign --jql "project = TEAM" --assignee user@example.com
acli jira workitem assign --filter 10001 --assignee default
```
`--remove-assignee` to unassign. `-f/--from-file` reads keys from a file.

**clone**
```
acli jira workitem clone --key "KEY-1,KEY-2" --to-project TEAM
```
`--to-site` to clone into a different site (defaults to the current authenticated one).

**comment** (subcommand group: `create`, `list`, `update`, `delete`, `visibility`)
```
acli jira workitem comment create --key KEY-1 --body "This is a comment"
acli jira workitem comment create --jql "project = TEAM" --body-file comment.txt --edit-last
acli jira workitem comment create --key KEY-1 --editor
```
`-b/--body` (plain text or ADF), `-F/--body-file`, `-e/--edit-last` edits the last comment
by the same author instead of adding a new one.

**link** (subcommand group: `create`, `delete`, `list`, `type`)
```
acli jira workitem link type                    # list available link types first
acli jira workitem link create --out KEY-123 --in KEY-456 --type Blocks
```
`type` before `create` if you're not sure what link type names are valid on this site.

**attachment** (subcommand group: `list`, `delete`) — no upload/create subcommand exists.

**watcher** (subcommand group: `remove`; `list` is deprecated, use `list-watchers` at the
top of `workitem` instead) and **archive**/**unarchive**/**delete** for lifecycle
management, targeted the same way as `edit`/`transition`.

## project

```
acli jira project list --recent            # last 20 viewed
acli jira project list --paginate          # everything
acli jira project view --key TEAM
acli jira project create --from-project TEAM --key NEWTEAM --name "New Project"
```
`create` clones from an existing company-managed project (`--from-project`); optional
`--description`, `--url`, `--lead-email`. Also supports `--from-json`/`--generate-json`.
`archive`/`delete`/`restore`/`update` exist too — check `--help` before using, these are
destructive at the project level.

## board / sprint

```
acli jira board search --project TEAM --type scrum
acli jira board view --id 123
acli jira board list-sprints --id 123
acli jira sprint view --id 456
acli jira sprint list-workitems --board 123 --sprint 456
acli jira sprint create --name "Sprint 1" --board 123 --start 2025-01-01 --end 2025-01-14
```

## filter / dashboard

```
acli jira filter search --owner user@example.com --name report
acli jira dashboard search --name report
```
Both are read-mostly with a similar `search` shape (`--name`, `--owner`, `--limit`,
`--paginate`, `--json`, `--csv`). `filter` also has favourite/owner-management commands.

## field

Custom field administration (`create`, `update`, `delete`, `restore`) — admin-level,
double check with the user before touching shared field configuration.
