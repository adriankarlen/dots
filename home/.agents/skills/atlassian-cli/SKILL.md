---
name: atlassian-cli
description: Use the `acli` (Atlassian CLI) tool to look up, search, create, edit, comment on, transition, or link Jira work items (issues/tickets/bugs/stories/epics), sprints, boards, and projects, and to view, create, or list Confluence pages, blogs, and spaces. Trigger this skill any time the user mentions Jira, Confluence, a ticket/issue key like "PROJ-123", sprints, boards, JQL, or wants to check/update/report on work tracked in Atlassian tools — even if they don't say "acli" or "CLI" explicitly, e.g. "what's the status of PROJ-123", "assign this bug to me", "list my open tickets", "find the Confluence page about onboarding". Prefer this over guessing at a REST API call or telling the user to check the web UI themselves.
---

# Atlassian CLI (acli)

`acli` is a real, installed command-line tool that talks to the user's actual Jira and
Confluence Cloud site. When a request touches Jira or Confluence, reach for `acli` instead
of speculating about what a ticket might say or asking the user to go look it up — you can
just look it up.

Every command has its own `--help`. Flags shift between acli releases, so if something in
this skill doesn't match reality, run `acli <command> --help` and trust that output over
this document.

## Before doing anything

1. **Check auth once per session**, don't assume:
   ```
   acli jira auth status
   acli confluence auth status
   ```
   If not authenticated, tell the user and run `acli auth login` (opens an OAuth browser
   flow — this needs the user present, don't try to script around it).

2. **Only one site is usually configured.** If the user mentions a specific Atlassian site
   and the auth status shows a different one, flag the mismatch rather than silently
   querying the wrong site. Use `acli auth switch` / `acli jira auth switch` /
   `acli confluence auth switch` if they have multiple accounts configured.

3. **Don't guess IDs.** Project keys, board IDs, sprint IDs, space keys, and space/page IDs
   are all opaque numbers or short codes you can't reliably infer. Look them up first:
   `acli jira project list`, `acli jira board search`, `acli confluence space list`, etc.
   The one exception is a work item key the user already gave you (e.g. `PROJ-123`).

## General patterns that apply everywhere

- **Add `--json` when you need to parse the output yourself** (e.g. to extract a field or
  feed it into another command). Skip it when just relaying a quick answer to the user —
  the default table/text output is often more readable for that.
- **Add `--web` to open something in the browser** instead of printing it, when the user
  wants to *look at* something rather than have you summarize it.
- **Bulk/targeting flags are consistent across `jira workitem` subcommands**: most of
  `assign`, `edit`, `transition`, `clone`, and `comment` accept a target via `--key
  "KEY-1,KEY-2"`, `--jql "..."`, or `--filter <id>` — pick whichever the user's request
  naturally maps to (a JQL query for "all bugs in PROJ assigned to me", explicit keys for
  "these three tickets").
- **Mutating/bulk commands prompt for confirmation** unless you pass `--yes` (or `-y`).
  Only pass `--yes` for actions the user has clearly already approved (e.g. they explicitly
  asked you to transition/assign/delete something) — for anything destructive or
  irreversible (delete, archive), state exactly what you're about to do first if there's
  any ambiguity about scope, especially for JQL/filter-based bulk targeting where the
  affected set isn't obvious from the command alone.
- **JQL is the query language for Jira search** (`--jql` on `workitem search`, `edit`,
  `assign`, `transition`, `clone`, `sprint list-workitems`). See
  `references/jql.md` for a cheat sheet if you're unsure of the syntax.

## Jira quick reference

Full command tree and flags: `references/jira.md`. The most common operations:

| Task | Command |
|---|---|
| Find/search tickets | `acli jira workitem search --jql "..."` |
| View one ticket | `acli jira workitem view KEY-123` |
| Create a ticket | `acli jira workitem create --project KEY --type Task --summary "..."` |
| Edit fields | `acli jira workitem edit --key KEY-123 --summary "..."` |
| Change status | `acli jira workitem transition --key KEY-123 --status "Done"` |
| Comment | `acli jira workitem comment create --key KEY-123 --body "..."` |
| Assign | `acli jira workitem assign --key KEY-123 --assignee "@me"` |
| Link two items | `acli jira workitem link create --out KEY-1 --in KEY-2 --type Blocks` |
| List projects | `acli jira project list` |
| List/search boards | `acli jira board search --project KEY` |
| Sprint details / items | `acli jira sprint view --id N` / `acli jira sprint list-workitems --board N --sprint N` |

A few things worth knowing before you reach for them:
- `workitem create` supports `--from-json`/`--generate-json` for structured/bulk-ish input,
  and `create-bulk` exists separately for creating many issues at once from CSV/JSON.
- `--assignee "@me"` self-assigns; `--assignee default` resets to the project default.
- Descriptions and comment bodies accept plain text or full Atlassian Document Format
  (ADF) JSON if the user needs rich formatting.

## Confluence quick reference

Full command tree and flags: `references/confluence.md`. The most common operations:

| Task | Command |
|---|---|
| Find spaces | `acli confluence space list` |
| Create a space | `acli confluence space create --key KEY --name "..."` |
| View a page | `acli confluence page view --id 123456789` |
| List/create blog posts | `acli confluence blog list --space-id N` / `acli confluence blog create --space-id N --title "..." --body "..."` |

**Important gap:** as of the currently installed acli version, `confluence page` only
supports `view` — there is no `page create` or `page update` subcommand. If the user wants
to create or edit a Confluence *page* (not a blog post), don't fabricate a command for it.
Tell them acli doesn't support page authoring yet, run `acli confluence page --help` to
confirm whether that's still true (acli gets new subcommands regularly), and fall back to
pointing them at the Confluence web UI, or asking if a blog post (`acli confluence blog
create`) would work instead.

## Output formats

Most search/list commands support `--json` and often `--csv` in addition to the default
human-readable table. When the user wants to pipe results somewhere else, save them to a
file, or you need to extract specific fields programmatically, use `--json` and parse it
rather than scraping the table output.
