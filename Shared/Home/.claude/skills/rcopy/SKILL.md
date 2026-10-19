---
name: rcopy
description: Put a drafted message on the clipboard as rich text so its formatting survives a paste into a chat, ticket, wiki, or email composer. Use when handing over a message to paste, or when asked for a paste-ready or formatted copy.
argument-hint: [what to copy — omit for the message just drafted]
---

# Rich-text clipboard

`/copy` puts plain markdown on the clipboard, which a rich editor renders as
literal asterisks. Put HTML there instead: write the message as a small HTML
fragment in the scratchpad, then hand that file to the clipboard the way this
machine takes it — `wslpath` on the PATH means the WSL route below, a set
`$WAYLAND_DISPLAY` means the Wayland one.

Reproduce the shape of what you are copying — a table stays a `<table>`, a list
stays a list. Silently reshaping it hands over something the user did not write.

Inline formatting and line breaks survive everywhere (`<b>`, `<i>`, `<code>`,
`<a>`, `<p>`). A rich chat composer generally keeps `<ul>`, `<ol>` and
`<table>` too, so copy lists and tables as they are. Only for a composer that
drops list markers, flatten deliberately: one `<p>&bull; …</p>` per row,
carrying the bullet as text, and say that you did — never rows joined by `<br>`
inside one `<p>`.

A `<style>` block or class attribute is discarded everywhere, and a chat
composer drops paragraph margins, so consecutive `<p>`s render with no gap
between them. Where the message needs a blank line — between paragraphs, after
a heading, between long bullets — put an empty `<p><br></p>` there; each one
adds one blank line. Lists and tables keep their own margin, so none goes
before or after them.

## Under WSL

```shell
win=$(wslpath -w <file>) && /c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "
\$h = Get-Content -Raw -Encoding UTF8 '$win'
\$h = [regex]::Replace(\$h, '[\uD800-\uDBFF][\uDC00-\uDFFF]|[^\x00-\x7F]', { param(\$m) '&#{0};' -f [char]::ConvertToUtf32(\$m.Value, 0) })
\$h | Set-Clipboard -AsHtml"
```

`Set-Clipboard -AsHtml` writes the fragment in the system ANSI code page (such
as Windows-1252), but `HTML Format` is read as UTF-8, so any non-ASCII
character — a dash, an accent, an emoji — pastes as �. The replace turns each
one into a numeric entity first, so only ASCII reaches it; the surrogate-pair
branch keeps an emoji one entity rather than two broken halves.

`wslpath` builds the path precisely so the shell never eats its backslashes. A
`PathNotFound` here usually means the file is gone rather than the escaping
breaking — check that it exists before chasing quotes.

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
