# Repo-specific notes

## Real shell per distro

Verified via `readlink -f /bin/sh` on real containers — **Ubuntu, Debian →
`dash`** (no arrays, no `${var/search/replace}`, no `[[ ]]`); **Fedora,
EndeavourOS → `bash`**. `Shared/common.sh` (all 4 distros) and
`Shared/wsl-common.sh` (Ubuntu/Debian/Fedora) must both stay dash-safe.
Generated `*/prepare.sh` shebangs match each distro's real interpreter purely
so shellcheck auto-detects the right dialect — the actual invocation is
`sh <(curl ...)`, which ignores shebangs.

## shellcheck gotchas (each took real testing to pin down)

- **Never put `# shellcheck shell=` inside a fragment** (`common.sh`,
  `wsl-common.sh`). It overrides the dialect for the rest of the *whole
  joined file* from that point on, not just the fragment — verified it
  falsely flags Fedora's valid bash arrays once poisoned by a fragment's
  directive.
- `SC2034`/`SC2154` on variables defined in one fragment and used in another
  (`APT_PKGS`, `DISTRO_NAME`, `JAVA_VER`, `ARCH`, etc.) are an artifact of
  the `awk`-text-join build (fragments are concatenated, never `source`d) —
  shellcheck can't trace usage across files it never sees joined. Disable at
  the site; don't add a `source` call just to fix this.
- Before disabling anything, check whether dash can actually do what
  shellcheck is suggesting (see the dash limitations above). If not, it's
  unfixable there — disable it. If dash can do it, do the rewrite instead.
- Don't add complexity to silence an info-level note if the existing code
  already handles the real risk — verify with a direct test first (e.g. does
  the command already fail loudly on bad input?) before "fixing" it.

## shfmt

Format with `shfmt -l -w -i 2 -sr .` (2-space indent, space after redirects)
— required style, run after editing any `.sh` file. It will rejoin a long
single-quoted string split across lines via `'...'\` + `'...'` back onto one
line — don't bother with that trick.

## `__add_apt_repo` has no idempotency guard — intentional

It always re-fetches and re-writes the GPG keyring. A prior version skipped
this when the keyring already existed, and that caused a real outage when
HashiCorp rotated their signing key (the stale cached keyring failed
verification). Do not add `[ -f "${keyring}" ] ||` back.

## EndeavourOS isn't containerized-tested

Ubuntu/Debian/Fedora changes get real `docker run` end-to-end tests;
EndeavourOS (bare-metal Arch/KDE) doesn't containerize the same way, and it's
also excluded from package-parity scans (not a work machine). For a real
behavioral change there, mock `yay`/`sudo` as shell functions and run the
actual extracted function body in a plain `archlinux` container — don't just
reason about a snippet in isolation.
