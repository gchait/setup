---
name: rcopy
description: Put a drafted message on the clipboard as rich text so its formatting survives a paste into a chat, ticket, wiki, or email composer. Use when handing over a message to paste, or when asked for a paste-ready or formatted copy.
argument-hint: [what to copy — omit for the message just drafted]
---

# Rich-text clipboard

`/copy` puts plain markdown on the clipboard, which a rich editor renders as
literal asterisks. Put HTML there instead: write the message as a small HTML
fragment in the scratchpad, then hand that file to the clipboard the way the
session's display server wants it.

Reproduce the shape of what you are copying — a table stays a `<table>`, a list
stays a list. Silently reshaping it hands over something the user did not write.

Inline formatting and line breaks survive everywhere (`<b>`, `<i>`, `<code>`,
`<a>`, `<p>`); block structure survives only in a document editor. A chat
composer flattens it — an observed `<ul>` arrived as bare lines with no markers.
So when the destination is a chat, flatten it deliberately: one `<p>&bull; …</p>`
per row, carrying the bullet as text, and say that you did. A `<style>` block or
class attribute is discarded everywhere.

## Under WSL

```shell
/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command \
  "Get-Content -Raw -Encoding UTF8 '<wslpath -w of the file>' | Set-Clipboard -AsHtml"
```

Windows PowerShell 5.1 at that path has `Set-Clipboard -AsHtml`. The clipboard
then holds `HTML Format` and nothing else — pasting into a terminal or a
plain-text editor yields nothing, so say that when handing it over. Confirm the
set with `[Windows.Forms.Clipboard]::GetDataObject().GetFormats()` after
`Add-Type -AssemblyName System.Windows.Forms`.

## Under Wayland

```shell
wl-copy --type text/html < <file>
```

`wl-copy` forks and keeps serving the selection until something else claims it —
that background process *is* the clipboard, so leave it running. It offers
`text/plain` alongside `text/html` from the same bytes, so a plain-text paste
yields the raw tags rather than nothing. Confirm with `wl-paste --list-types`.
