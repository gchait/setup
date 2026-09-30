---
name: rcopy
description: Put a drafted message on the clipboard as rich text so it keeps its formatting when pasted into Slack, Jira, Confluence, or an email client. Use when handing over a message to paste, or when asked for a paste-ready or formatted copy.
argument-hint: [what to copy — omit for the message just drafted]
---

# Rich-text clipboard

`/copy` puts plain markdown on the clipboard, which a rich editor renders as
literal asterisks. Put HTML there instead: write the message as a small HTML
fragment in the scratchpad, then hand that file to the clipboard the way the
session's display server wants it.

Keep the fragment minimal — `<b>`, `<i>`, `<a>`, `<ul>`, `<p>`, `<code>`. A
pasted `<style>` block or class attribute is discarded by most editors.

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
that background process *is* the clipboard, so leave it running and never sweep
it up in a broad `pkill`. It offers `text/plain` alongside `text/html` from the
same bytes, so a plain-text paste yields the raw tags rather than nothing.
Confirm with `wl-paste --list-types`.
