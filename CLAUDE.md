# Repo-specific notes

## Real shell per distro governs what syntax is legal

Never infer a distro's dialect from its family — Debian-based is not always
dash. The Justfile's `build` recipe assigns each distro `dash_header` or
`bash_header` to match its real `/bin/sh`; read it there rather than
guessing. A shared fragment must satisfy the most restrictive dialect among
the distros the recipe joins it into — that recipe is also where you see
which those are — so anything a dash distro joins gets no arrays, no
`${var/search/replace}` and no `[[ ]]`. The generated `prepare.sh` shebangs
exist so shellcheck detects the right dialect; the invocation ignores them.

## shellcheck gotchas

- **Never put `# shellcheck shell=` inside a fragment file.** It overrides
  the dialect for the rest of the *whole joined file* from that point on,
  not just the fragment, and falsely flags a later bash-dialect fragment's
  valid arrays.
- A variable that "appears unused" or "is referenced but not assigned" when
  it is defined in one fragment and used in another is an artifact of the
  `awk`-text-join build — fragments are concatenated, never `source`d, so
  shellcheck never sees them joined. Disable at the site; don't add a
  `source` call just to fix this.

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

- No `curl | bash` installer scripts, ever. This governs how the scripts
  install tools, not the repo's own bootstrap entry point.
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

It re-fetches and re-writes the GPG keyring on every run. Skipping that when
the keyring already exists breaks as soon as a vendor rotates its signing
key: the stale keyring fails verification and the install dies. Do not add
an `[ -f "${keyring}" ] ||` guard.

## Bare-metal distros don't get live container testing by default

A distro provisioned on real hardware rather than WSL can't be exercised
with a straightforward `docker run` the way a WSL guest can. One that isn't
a work machine is also out of scope for cross-distro package-parity
comparisons, though it still gets general maintenance and bugfixes. For a
real behavioral change to a bare-metal distro, don't settle for reasoning
about an isolated snippet — extract the actual function body, mock the
package manager and `sudo` as shell functions, and run it for real in a base
container matching that distro's package family, for both the empty- and
non-empty-result cases where relevant.
