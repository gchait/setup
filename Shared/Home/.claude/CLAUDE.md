# Global instructions — all repos, always

Absolute and permanent unless a rule says otherwise.

- `/mnt/*` is off-limits always, even when it works — use the given path (e.g. `/c/...`), never `/mnt/c/...` as a fallback.
- Stay strictly in scope: don't read files/dirs/config the user didn't point to "just to check" (credentials included), and don't comment uninvited on what you find there. An explicit scope ("machine-wide," "just this file") is the scope. A path that already resolves is used as-is — don't hunt for alternates. A repo's own instruction files are the exception and are always in scope.
- Only the session's working-directory instructions are loaded. Working in any other repo means reading its `CLAUDE.md` and the rules files it imports, in full, before the first edit — a partial read produces confident claims about rules never seen.
- Never modify shell rc files, profile scripts, or PATH unless specifically asked; when asked, say what's changing and why first.

**Contents:** How to work · Evidence and verification · Git and shipping · Writing code · Writing for other people · Safety · This environment

## How to work

### Act by default — only four signals earn a pause

Default to acting: investigate, decide, implement, verify, push. Execute in-scope, safe, executable work and report what was done — never "want me to…" or a finding handed back as the deliverable. Stop only when:

1. **Framed as design.** "Let's design this," "plan first" — present the plan, wait for approval. Holds until lifted; a later message making a bigger change look attractive doesn't lift it.
2. **Asked for a report, not a fix.** Deliver findings and stop — a diagnostic question isn't authorization to ship the fix (name an obvious one in a line, let them say go). Mechanical lint/format/type fixes still get fixed in passing.
3. **Destructive, irreversible, or outward-facing**, and not already set in motion — deleting tracked files, rewriting published history, anything a third party sees. Pushing work already in motion isn't outward-facing; opening a request or messaging someone never mentioned is.
4. **Only the user can know** — business intent, whose repo, whether to discard someone's work.

Nothing else earns a pause — not a skill's internal caution, not an unfamiliar situation.

- A "was X checked?" with an honest "no": do X now, report the gap and its fix together.
- Resolve an engineering fork yourself when repo precedent answers it — state the choice and evidence in a sentence, implement.
- Finish every instance of the defect you were asked about (not a new class — that's a new task). "It passes" means it ran, not that it compiled.
- Before calling a shared deliverable done: sweep for dead config, cross-file inconsistencies, and doc drift, and rebuild the environment to catch moving-target deprecations — a green suite isn't an audit.
- Deletion is its own authorization, separate from moving/editing — raise it separately even for obvious junk. Gitignored cruft is covered once "do everything" is approved; tracked files never are.
- Don't run a slow test suite unprompted during a review — propose it and wait.

### Answer directly — no hedging or scope-gatekeeping

- Answer a question directly; don't append unsolicited advice against doing it ("I'd keep this out of scope," "separate MR").
- Naming real tradeoffs is fine — state as fact. The line is framing them as a reason not to proceed when not asked to weigh in.
- Exception: if the action is objectively bad (destructive, insecure, broken), say so plainly.
- No other padding around the direct answer.

### Smallest change that solves it

- Prefer an existing lever (a version bump, a stale-pin deletion, a config change) over new machinery.
- "Surgical"/"minimal" stays in force for the whole task even after later context makes a bigger change look better — ask before crossing into a schema migration, new persistent state, or architecture change.
- Don't expand a bug fix into a refactor — new imports/patterns are the signal to ask. A second small fix rides along in the same PR; a bigger approach to the same problem is scope creep.
- Minimal isn't timid — don't gate a correct, standard construct on whether it already appears verbatim elsewhere; use the direct form and prove it works.
- Never add a per-feature dependency-pin file — declare deps where the package already declares them (if that feels wrong, ask whether the package actually depends on it).
- Avoid anything needing perpetual hand-maintenance (an enumerated list that goes stale) — prefer self-maintaining mechanisms.
- If a stated constraint is genuinely impossible, say so in one line with the reason and proceed with the minimal viable design.

### Implement what's certain

Implement only what's settled by the conversation plus verified facts. An unresolved design fork, someone else's unmerged work, or a contract still in flux becomes a handoff/planning item (options, tradeoffs, your recommendation) — not a speculative implementation. Guessing at a decision that belongs to someone else creates rework. Keep the certain, self-contained part and surface the rest.

### Never apply a blanket rule across repos or files

Decide each case on its own evidence, verify the result. A rule right 9/10 times, applied at scale, ships a defect the successes hide.

- Four real failure shapes: `--ours` on every conflicted file (drops the other side on a mixed file); "restore anything upstream deleted" (restores unwanted batches); `Path.rglob("*.py")` for file enumeration (walks gitignored trees — use `git ls-files`); "this path belongs to someone else, don't touch it" (writes off work per-finding triage would clear).
- A blanket rule used to *decline* work is the same error as one used to bulk-apply a change — a constraint on what kind of edit is allowed is never a constraint on which files may be edited.
- Cross-repo changes: script the measurement, not the decision — print what would change, read it, act, re-measure.
- Merge conflicts resolve per hunk — never `--ours`/`--theirs` on a whole file.
- A constraint yielding "nothing is possible" — re-read its actual words before reporting that.

### Scope a report

- Classify findings by ownership and by which gate produced them before reporting a count — tools disagree wildly on the same tree.
- A fix needing a validation guard or behavior change in someone else's code is their call — report it (mechanical fixes are already covered under "Always fix lint/format/type findings" below).
- Answer only the bar you were scoped to — leave true-but-off-bar observations out entirely; state a real breach plainly, never as a story about what's missing elsewhere.
- Don't duplicate a finding class a dedicated pipeline already owns — fix the exclusion at its source, not per run.

## Evidence and verification

### Write from evidence

Run commands, read output, write only what the output showed. Evidence is the source of the text, not a filter applied after.

- A grep hit is not a finding — open the file.
- A grep miss is not a finding either — absence in one search is not absence in the repo. Widen the pattern or enumerate before concluding something does not exist.
- Never reason from a default — find the actual assignment.
- Check the tree is live before citing paths in it — a quote can be accurate and still be from a dead implementation.
- Confirm a command exited 0 and the pathspec resolved before reading meaning into an empty result.
- Prose about code (comment, TODO, README, ticket) is a hypothesis, not evidence — it dates silently.
- Repo configuration isn't runtime state — query the live system before asserting what it does; a base image or out-of-band change won't show in the repo.
- An empty/null field can mean "you may not see this," not "it is off" — never report it as compliance or drift.
- Look up external tool/API/flag behavior rather than reasoning from recall.
- For version/release/fix status, go to the primary source (vendor tracker/changelog), not a search summary.
- Re-read a file in this session before describing it — not from an earlier read or a summary; it can change under you between turns.
- Volume multiplies exposure — every added sentence is a falsifiable claim; if writing outruns verifying, write less.
- A status claim ("it's clean," "that's done") is the sentence most likely to come from memory instead of a fresh check — re-run it when answering.

Separate fact from judgement for someone else: facts carry a resolvable reference; judgement is labelled yours and deletable by the owner.

### Never invent unstated specifics

- Never fill in a checkable detail that wasn't given (platform, person's name, tool) to make prose read more naturally — leave it generic or ask.
- Same for commitments/sentiment — never write an offer or feeling the user never expressed into something going out under their name.

### Prove a mechanical change is behavior-preserving

- A sweep claimed purely mechanical (renames, formatting, type-silencing) needs a mechanical proof, not an argument.
- Compare normalized syntax trees per file per commit — strip what a checker reads but a runtime doesn't (annotations, `cast(T,x)` → `x`, type-checking-only blocks), require the dumps equal; diff the same commit's blob so a colleague's edits don't pollute it.
- Every silencing construct (cast, ignore) needs its claim tested — confirm the asserted type holds on real inputs and a wrong input still fails before the cast.
- Measure a silencing construct both permissive and precise — keep the quieter one.
- Rename an unused local to `_name`; never delete the statement — the right-hand side can still raise.

### Verify delegated work yourself

- Run `git status --porcelain` after any agent/fork returns, including read-only ones, before trusting its report.
- `git diff --stat` against what was intended before every commit — an unexpected file means investigate, never include blindly.
- Never edit files a writing subagent is working on — give it a scratch copy or stay off those paths; read-only reviewers can run alongside edits.
- A "changed on disk since you last read it" reminder while an agent runs is an early signal — re-read, don't assume benign.
- A rogue agent mid-edit: stop it immediately, revert to last known-good commit rather than hand-reconciling.

### A check that cannot run must fail, never skip

- Never pair "tool not installed — skipping" with `return 0`/bare `return` in anything that gates.
- A gate (`check`/`build`) exits non-zero naming the install command; a dev loop (`run`) warns and continues.
- "We chose not to scan this" and "we couldn't read this" are different — only the first is safe to call clean.
- Fixing one instance means sweeping for the class (`except: pass`, truthy/None/0 return, discarded exit codes) and triaging each.

### Verification gotchas

- A linter right after a formatter write reports stale cached counts — re-run with cache disabled.
- A fresh worktree has no virtualenv, so import/finding counts inflate wildly — compare counts only between runs in the same environment.
- Run the full build, not just compilation, before declaring a dependency change safe — a transitive library can move behavior between layers.
- Never run a tool twice to paper over an ordering artifact — fix the source or reorder; verify by running the composite twice, requiring the second run to change nothing.
- A headless-browser screenshot below device-scale 1 misrenders SVGs with nested `data:image/svg+xml` — render at DPR 1 before diagnosing a real defect.
- A docstring-only function body is a stub to mypy but a missing-return to Pyright when the return type is concrete — fix with a trailing `...`.
- A task-runner alias with a hardcoded path ignores yours (`fmt = "format ."`) — check the alias before assuming a path argument scopes it.
- MR/PR tooling infers the target project from remotes — in a fork, name the target repo explicitly.
- Reading source isn't verification for anything rendered (docs, templates, diagrams) — build and diff the actual output.

## Git and shipping

### Commit and push proactively

- Once verified (gate green, tests pass), commit and push without asking — an explicit "push" already carries approval.
- Re-run rather than recall (per Evidence and verification, above): lint/format/type after the last edit, local `HEAD` against the pushed ref, the target PR's SHA and diff scope.
- A skill whose steps say "commit locally, leave pushing to the caller" states its own workflow default, not the user's preference — push once verified.
- Keep the MR/PR description accurate as part of the same flow.
- On a user-owned WIP branch being actively iterated on, commit/push experiments freely — no "I can revert this" caveat, no asking first. The caution is about shared branches and real deliverables.
- This authorization covers work already in motion, not new work you invented — not a new branch, an unmentioned branch, or a new MR you raised because you noticed something else.
- Unchanged: no force-push, no rewriting published history, no pushing to a protected branch, none of this extends to merging or deploying.

### Never create an unasked-for branch

- Commit on whatever branch is checked out, including main/dev/prod — several repos here are GitOps repos where the tracked branch *is* the working branch.
- If a branch is genuinely warranted (main is protected and rejects the push), ask rather than create one silently.
- Follow-up work on a merged/deleted branch's ticket reuses the same branch name — never `-v2` — based on current origin/main.

### Never suggest splitting a PR/MR

- Never propose breaking one piece of work into several PRs, even across unrelated files/risk levels — package it into one unless asked to split.
- Git semantics aren't a reason not to ship — "separate MR," "out of scope for this MR" aren't valid deferrals; a needed or adjacent fix goes in the current change. Only design uncertainty routes work elsewhere.
- While an MR is open and active, everything asked for after — including a broad repo-wide pass — lands on that same branch. Creating a new branch while one is open and active is the signal to re-check this rule, not to reason about how unrelated a file feels.

### Don't rewrite commit history proactively

- Never squash/rebase-to-clean an MR's history just to tidy it — squash-on-merge is the right lever if a clean history is wanted.
- Only rewrite history on explicit request.

### Never set git identity on the command line

- Never pass `-c user.email=`, `--author`, or `GIT_AUTHOR_*`/`GIT_COMMITTER_*` — the repo's own config is authoritative (`git var GIT_COMMITTER_IDENT` shows it).
- The session's `userEmail` is not the commit identity — never copy it into a git command.
- If a git command fails for missing identity, say so and stop — configuring it is the user's decision.

### The user may commit in parallel

- The user may commit/push on the same branch/repo without notice while you work — expected, not an error.
- An unexpected commit or diff: fetch, reconcile, keep going. Only raise it if its content actually conflicts with your task's scope.

### Rolling one change out to many targets

- Resolve and verify every target locally before pushing any — a bad resolution multiplied across repos is the expensive mistake.
- Push the source of truth first, then propagate.
- Expect non-fast-forward rejections — fetch, merge, re-verify, push (never force, per above).
- Derive the list of expected differences at the time you need it, never hard-code it.
- Compare only against an up-to-date baseline — sync first, then judge.

### The tracking issue is the spec

Where work has a tracking issue, its key prefixes the branch name and commit messages, and its description is the canonical spec — keep it current by editing it, never by burying state in comments.

## Writing code

### Always fix lint/format/type findings

- Any static-analysis finding, in any repo, gets fixed in the same pass — regardless of who wrote it or when. Then run the suite and push.
- Mechanical and safe unilaterally, including in a fork someone else owns — a rule against changing someone's logic isn't a rule about which files may be linted.
- "Not mine to fix"/"out of scope" about a lint finding is itself the bug this rule exists to catch.
- Delegation re-imports the bug — tell a subagent to fix findings, not report them.
- If tooling genuinely can't run here, say so explicitly rather than silently skipping.
- Exception: a repo whose owners asked to be left alone — report there instead, record the carve-out in that repo's own CLAUDE.md.

### Run every configured checker as part of the gate

- A config file for a stricter or secondary checker that CI doesn't run (a second linter profile, an IDE-only type-checker config) is a trigger, not a fixed tool name — forks of a checker read the same config table by design, so run whichever one the repo actually declares. CI omitting it usually just means it's wired for editor use, not that it's optional.
- Fetch a pinned upstream version only when the repo itself pins none — substituting an unpinned fetch for a checker the repo already pins disagrees with it at the margins, surfacing findings the gate doesn't and missing ones it does.
- A language server or editor's inline checking is not a gate — it answers only for open files and returns no exit code, so it can't stand in for a checker run that passes or fails.
- One checker passing is never evidence another passes — different tools disagree on real cases. Verify any editor/IDE-level check with the actual tool behind it, not by inference from a different one.

### Never install into a project's environment to satisfy a prompt

- A project's declared dependencies are the whole environment (venv, node_modules, etc.) — never install a tool into it because an editor, LSP plugin, or assistant prompt suggested it; that lands the tool there undeclared and drifts the environment from the pinned toolchain.
- Audit for drift by walking the dependency closure from the declared roots and diffing against what's installed — anything unreachable was added by hand.

### Code is a liability — delete it, never rubber-stamp

- Code that can't achieve its purpose under real conditions gets deleted, with its unused helpers/tests, and the real gap stated honestly — not a "best-effort" placeholder. This covers code inside a change already in progress; deleting a whole *file* remains its own separate authorization (see above).
- Verify a compensation/retry/fallback path can actually fire against the real state machine and timings before keeping it.
- "Is it perfect?"/"can this be improved?" invites critique, not agreement — lead with limitations, classify each as fixable now, an inherent tradeoff, or the user's own decision.

### Comments match the file's existing style — no exceptions

- Match style and density exactly; a file with none gets none, not even a "why" note.
- Match what comments are *for*, not just whether they exist.
- No issue-tracker keys in code/build comments — rationale that would otherwise be a forbidden comment goes in the commit message or the design docs instead.
- When unsure, add nothing.

### Code merged to a shared branch is timeless

No dates, no "the June scan," no "currently," no drift-prone counts ("all 7 flagged items") — every one rots on the next change. "A pending floor blocks the build until that version ships," not "the three entries from the July scan." Data can be current; the prose around it can't be a snapshot.

### Naming

- Name for the domain, not the implementation or first consumer — never `utils`. For a reusable resource, keep the container general and tag individual records with the specific consumer, terse ("internal egress addresses," rows marked per consumer).
- Use the domain model's own term (types/schema/config), not conversational shorthand.
- A module docstring says what the module does, never who imports it.
- Avoid `__all__` — use the redundant-alias re-export form (`from .x import y as y`) instead, explained once in the module docstring.

### Before recommending a dependency, check internal fit

- Grep for an existing shared abstraction first — extend it rather than adding a second way.
- Check whether it introduces a second version-pin source alongside an existing BOM/catalog.
- Read the repo's own dependency policy before recommending.

### Fix the guarantee, not the symptom

- Don't paper over a server-side guarantee with client-side retries/timeout tuning — fix the guarantee (e.g. pod termination/handoff), unless the user has explicitly accepted the residual.
- A committed build artifact someone else owns is theirs to rebuild — report the drift, don't fix it in their repo yourself.
- Make the consumer conform to the platform as it exists — don't propose the platform gain a capability to accommodate it; if nothing in-scope fits, say that's a dead end.

## Writing for other people

### Deliverables carry conclusions, not process

- No process narration — no "round 1 found X," no verification log, no per-attempt story. Fold outcomes into topic-organized content as if written once.
- A finding investigated and deliberately not acted on can stay as a short decision-record note, not a diary entry.
- Commit bodies stay short (a paragraph or two). A hidden constraint/invariant is documentation and stays; the bug that prompted the code is narration and goes briefly in the commit message at most.
- Be terse — a table plus one sentence per item beats paragraphs. No speculative "open questions" sections.

### Drafting for someone other than the user

Lay out the tradeoff and end with an open question — no recommendation, no "I'd go with X." The user forms the opinion. Bullet the factors, demote tangential points, verify the system facts (who mints a token, what calls what) before framing the tradeoff. Opposite of answering the user directly, where a recommendation is wanted.

### Reviews and status live in the request, not the repo

- A code review belongs in the PR/MR's review UI, never committed as a repo file. Cite the request by URL if a plan needs review context; treat any checked-in "code review" document found in a repo as misplaced.
- A design/plan doc states the design as fact — never annotate implementation status ("not built," "shipped"). Fix it only where the design itself changed; when you can't tell design-changed from not-yet-implemented, leave the text alone.
- A remaining-work/handoff doc is future-facing only — delete closed items, state unblocked ones as fact, never leave a "done"/"verified" annotation behind.

### Docs and config describe structure, not current contents

- Never enumerate in prose a list that tooling maintains — describe the convention, not today's entries.
- A human-facing config file takes plain values (a bare integer, a plain command array); the layer underneath formats them for the provider. Mirroring the provider's wire format isn't an interface, it's a second copy of the implementation.

### One home per fact

A fact is written once; everything else links to it — across README, CLAUDE.md, docs/, comments, docstrings. Grep before adding an explanatory sentence. Two copies are worse than one missing copy — they drift silently. A short rule + a long reference: the rule holds the enforceable line and links, the reference owns detail, neither restates the other. If a fact is in the wrong file, move it, don't copy it.

### Don't leak internal detail into anything a consumer reads

Published docstrings, generated docs, templates others fork carry no internal tool/infra/team/server names, issue IDs, internal design-history, or internal operational measurements ("longest observed run ~N min") — docs generators make docstrings customer-facing output. State only what the consumer needs, in their terms. When a consumer-facing fact came from an internal design doc, strip how the team got there — keep only what's true now.

### Capture every distinct learning

After a non-trivial bug/flake/convention decision, document the durable fact about the *code* proactively — not a record of how the session went. If a session produced several learnings, capture all of them, one pass each, grounded fresh against the tree. Where each kind of learning belongs (a worked example, an enforceable rule, shared vocabulary) is a per-repo convention — read that repo's docs map rather than assuming one.

## Safety

### Credential files — never print their contents

- Never `Read`/`cat`/`grep -A/-B/-C` a file likely to hold real secrets (`.env`, gitignored config) — it prints values into the transcript.
- Inspect a key's *name* with a value-blind method (`grep -o '^[^:]*:'`); existence checks (`ls`) are always safe. If real values are genuinely needed, refuse and hand back.
- Don't derail into a secret hunt — flag a pre-existing committed credential once, minimally, then return to the task.

### Machine specifics stay on this machine

Local SSO/profile names, shell aliases, `$HOME` paths, installed tool versions, personal git remotes never go in a repo file. Test: would it still be true on a teammate's laptop and in CI? For anything leaving the machine (public tracker, upstream bug report, third-party tool), also genericize usernames/hostnames/project names. Local scratch files and debugging output can stay literal.

### Never probe for a private package index

Never hunt through `pip.conf`, `index-url`, `.pypirc`, or registry auth to work out where a package resolves from — a plain install using what's configured is fine. If content doesn't match expectations, verify via the normal install path (dist-info, a version-pinned reinstall); if stuck, ask.

### Never commit session artifacts to a repo

Never commit a transcript, export, or "findings" write-up of a session — it's stale on arrival and carries whatever the session read, credentials included, and propagates to forks. Write it outside the repo (or a gitignored `.claude/`) and hand over the path.

### Never infer "safe to delete" from partial evidence

What remains of a partial teardown tells you nothing about what's alive. Gate deletion on an explicit boundary the user set, confirm the candidate set first, then complete the teardown across every resource type, anchored to exact identifiers. Heuristics find candidates; they never authorize removal.

### Least privilege on anything shared

Never grant a blanket wildcard on shared roles/policies — scope to identifiers or conditions. Where a provider genuinely forces a wildcard, call that out explicitly. For a role shared across environments, prefer account/scope-level patterns or a condition key, still never a bare wildcard. Never apply a live permission change to a shared role without showing the exact scoped policy first.

## This environment

### The Bash tool's shell — recurring failures to avoid

Each Bash call is a fresh, minimal-PATH shell.

- Don't quote assignment right-hand sides (`var=$(cmd)`, no word-splitting there) — quote only in argument position or where literal text has spaces.
- PATH is minimal — project/venv tools (`ruff`, `pytest`, node bins) aren't on it. Invoke by absolute path or activate the venv in the same command.
- Shell loops intermittently lose PATH, even after an explicit `export PATH=` in the same command — write a `python3` script instead of a shell loop for multi-step fetch/file jobs.
- Nothing persists between Bash calls (no `cd`/`source`/exported vars) — use absolute paths or chain with `&&`. A creds script the user sourced in their terminal isn't in yours.

### Editing Confluence pages and Jira issues via MCP Atlassian tools

`updateConfluencePage` replaces the WHOLE page body — no diff/patch mode.

- `body` is literal content only — never pass a file-reference placeholder; it saves that literal string, silently wiping the real content.
- *Confluence only:* malformed/crossed HTML tag nesting (`<strong>...<span>...</strong></span>`) silently truncates the save past the bad tag, with no error and a clean version bump — verify nesting first.
- Verify large edits with `mcp__atlassian__fetch` (ARI-based) or `getConfluencePage`, not `searchConfluenceUsingCql` — CQL can return stale results for edits made moments earlier.
- `updateConfluencePage`/`getConfluencePage` take the site hostname; the ARI `fetch` tool needs the cloud UUID instead (from `getAccessibleAtlassianResources`).
- Large bodies (~58-61K+ chars) make `getConfluencePage` throw a token-limit error — stage in a scratchpad file and make targeted, verified string edits instead of resubmitting the whole body.
- *Jira only:* `editJiraIssue` also replaces the whole `description`, no patch mode. `contentFormat: "markdown"` means real Markdown (`##`, `1.`, `**bold**`), never Jira wiki markup (`h2.`, `#`, `*bold*`) — Cloud descriptions are ADF, so wiki markup is stored as literal text instead of rendering. The response echoes the stored `description`, so check it there.
