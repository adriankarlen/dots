# Confluence commands (`acli confluence ...`)

Run `acli confluence <command> --help` for the current, authoritative flag list.

## Command tree

```
acli confluence
├── auth      login | logout | status | switch
├── blog      create | list | view
├── page      view                      (that's it — no create/update yet)
└── space     archive | create | list | restore | update | view
```

## page

Currently **read-only** from the CLI:
```
acli confluence page view --id 123456789
acli confluence page view --id 123456789 --json
acli confluence page view --id 123456789 --body-format storage
```
Useful flags: `--body-format` (`storage`, `atlas_doc_format`, `view`), `--include-labels`,
`--include-versions`/`--version <n>`, `--include-direct-children`,
`--include-collaborators`, `--status` (filter by `current,draft,archived`).

If asked to **create or edit a page**, there is no subcommand for it in the currently
installed acli version. Re-check with `acli confluence page --help` in case a newer
release added it, and if not, say so plainly rather than inventing flags — offer the
Confluence web UI or a blog post (below) as the alternative.

## blog

Full CRUD-ish support for blog posts (which live in a space like pages do, just via a
different content type):
```
acli confluence blog list --space-id 12345
acli confluence blog view --id 123456789
acli confluence blog create --space-id 12345 --title "Release Notes" \
  --body "<p>Content here</p>"
acli confluence blog create --space-id 12345 --title "Work in progress" \
  --status draft --body "<p>Draft content</p>"
acli confluence blog create --space-id 12345 --title "Private announcement" \
  --private --body "<p>Private content</p>"
acli confluence blog create --from-file ./blog_content.html --space-id 12345 --title "..."
acli confluence blog create --from-json ./blog_payload.json
acli confluence blog create --generate-json
```
Body content is **Confluence storage format** (XHTML-ish), not Markdown — if the user
gives you plain prose, wrap it in basic `<p>` tags rather than passing raw text. `--status
draft` for an unpublished draft, `--private` to restrict visibility, `--created-at` for a
backdated timestamp.

## space

```
acli confluence space list
acli confluence space list --type personal
acli confluence space list --expand description,homepage,permissions
acli confluence space create --key SPACEKEY --name "Space Name" --description "..."
acli confluence space view --key SPACEKEY
```
`create` also takes `--alias`, `--private`, `--template-key`. `archive`/`restore`/`update`
exist for lifecycle management — confirm scope with the user before archiving a space.

## Content format note

Confluence content bodies (blog `--body`, and presumably any future `page create`) use
**storage format**, Confluence's XHTML-based markup — e.g. `<p>text</p>`,
`<ac:structured-macro>` for macros — not Markdown and not plain ADF (ADF is a Jira-side
concept for descriptions/comments). When building non-trivial content, keep it to simple
HTML tags unless you know the specific macro syntax needed.
