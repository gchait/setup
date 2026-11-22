---
name: atlassian
description: Gotchas the Atlassian MCP tool descriptions don't state — searchConfluence can't verify a fresh write, a file-reference placeholder in a Confluence body is saved literally, and Jira wiki markup is stored as literal text. Read before writing Confluence or Jira content, or verifying a write with getConfluenceContent.
---

# Atlassian MCP gotchas

- *Confluence:* verify a write by reading the content back with
  `getConfluenceContent`, and confirm the body came back whole rather than only
  that the page resolves. Never verify with `searchConfluence`: the CQL index
  lags writes by a minute or more, so straight after a create or edit even
  `id = <page id>` returns nothing.
- *Confluence:* `body.value` is literal content. Never pass a file-reference
  placeholder; it saves that string and wipes the real content.
- *Jira:* `contentFormat: "markdown"` means real Markdown (`##`, `1.`,
  `**bold**`), never Jira wiki markup (`h2.`, `#`, `*bold*`), which is stored as
  literal text.
