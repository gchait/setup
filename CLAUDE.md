# Repo-specific notes

Personal provisioning scripts for: EndeavourOS (baremetal), Windows (WSL2 host),
and Debian/Fedora/Ubuntu (WSL2 distros). Machine list is in README.md.

## Build system

`*/prepare.sh` files are **generated** — never edit them directly, edit the
fragments and run `just build`:

- `Shared/common.sh` — joined into all four distros' output.
- `Shared/wsl-common.sh` — joined into Ubuntu, Debian, Fedora only (not EndeavourOS).
- `<Distro>/distro.sh` — the distro-specific fragment.

The Justfile concatenates these with `awk` (text join), not a shell `source`/`.`
statement. That matters for shellcheck (see below) — there is no runtime
`source` call anywhere, so never add one just to satisfy a linter.

## Real shell per distro — this governs what syntax is legal

Verified via `readlink -f /bin/sh` on real containers:

- **Ubuntu, Debian → `dash`** (no arrays, no `${var/search/replace}`, no `[[ ]]`).
- **Fedora, EndeavourOS → `bash`**.

`Shared/common.sh` is shared by all four (must stay dash-safe).
`Shared/wsl-common.sh` is shared by Ubuntu/Debian (dash) + Fedora (bash) (must
also stay dash-safe). Each generated `prepare.sh` gets a shebang matching its
real interpreter (`#!/usr/bin/env dash` or `bash`) so shellcheck auto-detects
the right dialect with no `-s` flag — this is cosmetic for execution (the
actual invocation is `sh <(curl ...)`, which ignores shebangs) but required
for correct static analysis.

## shellcheck strategy

Run `just build` first, then check the generated `*/prepare.sh` files — those
are the real artifacts. To check a fragment standalone, pass `-s dash` or
`-s bash` explicitly (fragments have no shebang of their own by design, so a
bare `shellcheck fragment.sh` shows `SC2148: target shell unknown` — expected,
not a bug). Fragments shared with a dash consumer (`common.sh`, `wsl-common.sh`)
must be clean under `-s dash` specifically — that's the stricter, binding
dialect, not whatever the generated file you're currently looking at happens
to use.

**Never add a `# shellcheck shell=` directive inside a fragment file.** It
overrides the dialect for the rest of the *whole generated file* from that
point forward, not just the fragment — verified this causes false
`SC3030`/`SC3054` errors on Fedora's genuinely-valid bash arrays once
`common.sh`'s portion (checked earlier in the joined file) would poison it.
An explicit `-s` flag on the command line (e.g. VS Code's
`shellcheck.customArgs`) overrides a `shell=` directive, but a directive
still overrides shebang-based auto-detection — know which one is in play.

Some codes are dialect-gated (shellcheck itself knows dash can't do the
"fix", so it doesn't suggest it under `-s dash`): `SC2001` (sed vs
`${var//x/y}`), `SC2292` (`[[ ]]` preference). Others are **not** dialect-gated
and fire identically either way: `SC2086` (quoting), `SC2312` (masked exit
status in a pipe/conditional).

`SC2034` ("appears unused") and `SC2154` ("referenced but not assigned") on
variables defined in one fragment and consumed in another (e.g. `APT_PKGS`,
`DISTRO_NAME`, `JAVA_VER`, `ARCH`) are an inherent artifact of the join-based
build — shellcheck can't trace usage across files that are concatenated, not
sourced. These get a disable at the declaration/reference site; this is not
laziness, it's the only fix available short of adding a fake `source`
statement (which would be dead code, since the build never actually sources
anything).

A `# shellcheck disable=...` comment placed immediately before a function's
`{` suppresses that code for the *entire function body*, not just the next
line — use this to consolidate disables onto one line per function
(`# shellcheck disable=SC2086,SC2154`) instead of scattering one per
statement.

Before adding any disable, check whether a same-cost rewrite removes the
finding for real (e.g. `[ ]` → `[[ ]]` is free in a bash-exclusive file; a
`uname -m | sed ...` pipe can become a plain bash substitution chain, which
also fixes a real `set -e` gap since a failing `sed`-fed pipe doesn't
propagate the upstream command's exit status). Don't restructure into
something *more* complex just to silence a linter — e.g. turning a
`curl | gpg --dearmor` pipe into a temp-file dance added 4 lines to fix an
`SC2312` info-level note that was already a non-issue (`gpg --dearmor` exits
non-zero on empty/garbage input and is the last command in the pipe, so
`set -e` already catches a `curl` failure). When no real fix exists and the
"suggested" alternative would be worse or break dash, just disable it.

## shfmt

Formatting is enforced with `shfmt -l -w -i 2 -sr .` — 2-space indent, space
after redirect operators (`2> /dev/null`, not `2>/dev/null`). Run it after
editing any `.sh` file.

## `__add_apt_repo` has no idempotency guard — intentional, do not add one

It unconditionally re-fetches and re-writes the GPG keyring on every run. A
previous version skipped re-fetching if the keyring file already existed —
that caused a real outage when HashiCorp rotated their signing key, because
the stale cached keyring failed GPG verification. Don't reintroduce an
`[ -f "${keyring}" ] ||` guard here.

## No version-chasing

Don't add a vendor repo, pin, or extra complexity purely to get a newer
version of something when the distro's native package already works.
Verify packages live against real container images (`docker run --rm -it
ubuntu:24.04`, `debian:13`, `fedora:44`) before claiming something is
available/absent by default — not from memory or docs.

## EndeavourOS is out of scope for package-parity work

It's not a work machine — don't pull it into cross-distro package-parity
comparisons (it still gets general maintenance/bugfixes).

## Conventions already in use — match them

- Functions prefixed `__` are internal helpers; declare them before the
  non-prefixed "main" functions in a file. Order helpers by first-call time
  (a function that nests-calls another helper is declared before the one it
  calls); order main functions to match the final invocation block at the
  bottom of the file.
- Package/variable lists (`APT_PKGS`, `DNF_PKGS`, `PKGS`) are ASCII-sorted and
  line-wrapped for balanced width.
- A helper moves to `Shared/wsl-common.sh` only when 2–3 of
  {Ubuntu, Debian, Fedora} actually use it; to `Shared/common.sh` only when
  all four distros do. Don't hoist something shared by just one distro.
