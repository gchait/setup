# Repo-specific notes

## Real shell per distro governs what syntax is legal

Never assume a distro's dialect from its family (e.g. Debian-based ≠
always dash). Verified via `readlink -f /bin/sh` on real containers —
**Ubuntu, Debian → `dash`** (no arrays, no `${var/search/replace}`, no
`[[ ]]`); **Fedora, EndeavourOS → `bash`** — matching the Justfile's
`dash_header`/`bash_header` build recipe (check there if this ever changes,
rather than guessing from distro family). `Shared/common.sh` (all 4 distros)
and `Shared/wsl-common.sh` (Ubuntu/Debian/Fedora) must both stay dash-safe —
a file shared across multiple distros must satisfy the most restrictive
dialect among its actual consumers, not whichever one happens to be open.
Generated `prepare.sh` shebangs match each distro's real interpreter purely
so shellcheck auto-detects the right dialect — the actual invocation ignores
shebangs, so this has zero effect on execution.

## shellcheck gotchas (each took real testing to pin down)

- **Never put `# shellcheck shell=` inside a fragment file.** It overrides
  the dialect for the rest of the *whole joined file* from that point on,
  not just the fragment — verified it falsely flags a bash-dialect
  fragment's valid arrays once poisoned by an earlier fragment's directive.
- A shellcheck warning that a variable "appears unused" or "is referenced
  but not assigned," when that variable is defined in one fragment and used
  in another, is an artifact of the `awk`-text-join build (fragments are
  concatenated, never `source`d) — shellcheck can't trace usage across files
  it never sees joined. Disable at the site; don't add a `source` call just
  to fix this.
- Before disabling anything else, check whether the file's real dialect can
  actually do what shellcheck is suggesting. If not, it's unfixable there —
  disable it. If it can, do the rewrite instead.
- Don't add complexity to silence an info-level note if the existing code
  already handles the real risk — verify with a direct test first (e.g. does
  the command already fail loudly on bad input?) before "fixing" it.

## shfmt

Format with `shfmt -l -w -i 2 -sr .` (2-space indent, space after redirects)
— required style, run after editing any `.sh` file. It will rejoin a long
single-quoted string split across lines via `'...'\` + `'...'` back onto one
line — don't bother with that trick.

## Package-list wrapping

`shfmt` only fixes indentation/redirect spacing — it does not rewrap the
long space-separated package lists (`APT_PKGS`, `DNF_PKGS`, `PKGS`). When
adding or removing a token, rewrap the whole block, not just the line it
landed on — one token can shift the optimal balance for every line in the
block. The rule: preserve the list's existing ASCII sort order, keep every
line under 100 chars, and — using the fewest lines that constraint allows —
pick the wrapping that minimizes the gap between the longest and shortest
line.

## Install method constraints — hard rules, not preferences

- No `curl | bash` installer scripts, ever.
- No snap, no zip/tar.gz archives (tar.gz counts as an archive too).
- No new helper mechanism in a `distro.sh` beyond what it already has — an
  existing helper can be extended with more tools, but don't add an
  equivalent mechanism to a `distro.sh` that never had one, even to match
  another distro's toolchain.
- A tool whose release asset filename is version-pinned (no stable
  "latest" URL) gets skipped entirely, not fixed with a runtime
  version-resolution step — unless the vendor has an apt/dnf repo that
  supports pinning a version in the repo path itself, which reuses the same
  repo-plus-keyring pattern already used elsewhere in `system_setup`.
- Don't add a vendor repo or extra complexity just to get a newer version
  when the distro's native package already works — freshness alone is never
  the justification.
- Before adding a package to any distro's manifest, verify it exists across
  that distro's *entire* declared supported version range (see its
  `README.md`), not just whatever release happens to be on the test
  machine — package availability can genuinely differ between releases of
  the same distro. The same caution applies to any vendor repo: verify the
  actual repo/package content for the release in question, not just that
  the URL returns 200 — a missing path can still resolve to an empty or
  wrong repo.

## `__add_apt_repo` has no idempotency guard — intentional

It always re-fetches and re-writes the GPG keyring. A prior version skipped
this when the keyring already existed, and that caused a real outage when a
vendor rotated their signing key (the stale cached keyring failed
verification). Do not add an `[ -f "${keyring}" ] ||` guard back.

## Claude Code auto-updates are off on the apt distros — intentional

`Ubuntu/Etc/claude-code/managed-settings.json` and its Debian twin set
`DISABLE_AUTOUPDATER=1`: under WSL, Claude Code misdetects a
package-manager install as a native one and self-updates over a binary apt
owns. Fedora has no such file on purpose — `claude` isn't in `DNF_PKGS`, so
the updater is its only update path.

## Bare-metal distros don't get live container testing by default

A distro provisioned on real hardware (not WSL) generally can't be exercised
with a straightforward `docker run` the way a WSL guest can. EndeavourOS
(currently the only bare-metal entry) is also out of scope for cross-distro
package-parity comparisons — it's not a work machine, though it still gets
general maintenance/bugfixes. For a real behavioral change to a bare-metal
distro, don't settle for reasoning about an isolated snippet — extract the
actual function body, mock the package manager and `sudo` as shell
functions, and run it for real in a base container matching that distro's
package family, for both the empty- and non-empty-result cases where
relevant.
