---
name: atlassian
description: Gotchas for editing Confluence pages and Jira issues through the MCP Atlassian tools — whole-body replacement, silent truncation on bad HTML nesting, stale CQL reads, site hostname vs cloud UUID, token limits on large bodies, and ADF markup. Read before calling updateConfluencePage or editJiraIssue.
---

# Editing Confluence pages and Jira issues

`updateConfluencePage` replaces the WHOLE page body — no diff/patch mode.

- `body` is literal content only — never pass a file-reference placeholder; it
  saves that literal string, silently wiping the real content.
- *Confluence only:* malformed/crossed HTML tag nesting
  (`<strong>...<span>...</strong></span>`) silently truncates the save past the
  bad tag, with no error and a clean version bump — verify nesting first.
- Verify large edits with `mcp__atlassian__fetch` (ARI-based) or
  `getConfluencePage`, not `searchConfluenceUsingCql` — CQL can return stale
  results for edits made moments earlier.
- `updateConfluencePage`/`getConfluencePage` take the site hostname; the ARI
  `fetch` tool needs the cloud UUID instead (from
  `getAccessibleAtlassianResources`).
- Large bodies (~58-61K+ chars) make `getConfluencePage` throw a token-limit
  error — stage in a scratchpad file and make targeted, verified string edits
  instead of resubmitting the whole body.
- *Jira only:* `editJiraIssue` also replaces the whole `description`, no patch
  mode. `contentFormat: "markdown"` means real Markdown (`##`, `1.`, `**bold**`),
  never Jira wiki markup (`h2.`, `#`, `*bold*`) — Cloud descriptions are ADF, so
  wiki markup is stored as literal text instead of rendering. The response echoes
  the stored `description`, so check it there.
