<!-- CORE LAYER - the universal spine of the READ_FIRST template system.
     Merge order: core + <language> + <framework> -> project docs/READ_FIRST.md.
     Grep "[ADAPT" for slots a project fills. NO language or framework rules here -
     those live in their own layers. ASCII-only except the s1.2 verdict glyphs
     inside runtime print strings. Cite sections as `s N`. -->

# READ_FIRST - core layer

The HOW of building with an LLM agent, language-agnostic. Every rule is an
imperative one-liner, loaded in full each session. Conflicts: project facts win
over this file's examples; workflow rules here win over habit.

---

## 0. ORIENT - step zero (HARD)

Repo root = git toplevel. Know the layout before touching a file; never guess a
path. [ADAPT: package layout, where patches/docs live vs source.]

**"Continue the work" is fully specified - never a question:**
1. Run the session-start reconcile [ADAPT: script name] and paste its full output.
   It commits prior work on confirm, cleans stale backups, and ASSERTS the
   project's claims against disk (s10).
2. Read the single handoff note (the BATON, s12). It is a CLAIM, not authority.
3. Open the plan-of-record doc; confirm the baton's stated frontier against it +
   the reconcile output. **The reconcile contradicts the baton -> the reconcile
   WINS; the first task is to fix the baton.**
4. Read the baton's `CONTEXT REQUIRED` line: a listed doc not in context -> ASK
   for it before building. `none` is a green light; a BLANK line is a broken
   baton - treat as "unknown, ask".
5. Read the user-inbox doc (s9). State the frontier. Proceed.

A question is allowed ONLY for a genuine UX/naming/scope decision, or a missing
required doc (step 4) - never for a fact a grep or the reconcile already prints.
CHECK, DON'T ASK: a fact a grep / read / disk-check can answer is resolved by
running the check, never by asking the human.

**Agent notebook (s9-NOTES):** the AGENT writes findings/insights as they arise,
on its own initiative; at checkout they distribute to durable homes. A note is a
CLAIM until it lands.

**Doc homes.** Private working state lives in `dev/` (READ_FIRST, the baton,
patches, the plan-of-record, the user inbox) and is git-excluded. Public
documentation lives in `docs/` (API references, user guides) and is tracked.
A folder named `docs/` that holds working state misleads a reader and risks
excluding a public doc by accident. Keep the two separate. [ADAPT: a project
with no public docs may keep only `dev/`.]

---

## 1. DELIVERY (HARD)

- **Code changes / merge-edits** = ONE self-contained patch script typed in the
  reply (a `cat > <patch-file> << 'EOF' ... EOF` heredoc). No scratch files, no
  out-of-band editors.
- **Full rewrites / NEW standalone docs** = a single-clipboard `cat > path 
  'EOF'` heredoc (single-quoted EOF). Nothing to anchor on -> nothing to
  merge-patch. Install steps ride alongside as a fenced block.
- **Bare run = APPLY. `--dry-run` validates and writes nothing. `--revert`
  restores the backup.** No "no-flag -> usage" branch.
- Path-independent root: `ROOT = Path(__file__).resolve().parent.parent` (adjust
  depth to where patches live).
- **Nothing after the closing `EOF` except the single dry-run invocation (s1.1)**
  - a stray tag silently drops the whole command. No output? Suspect this first.
- Heredoc-escape hazard: backslashes and stray quotes can close the heredoc
  early. Use real newlines / `chr()` / literal-byte matching; `cat -A` a target
  region before anchoring.
- Trivial fix (one param, a rename, layout) -> a direct inline one-liner, no
  patch file.
- Recon/probe blocks run via `bash <<'EOF' ... EOF` over stdin (single paste),
  never a written-then-run scratch script; only the patch file is written to disk.

### 1.1 Single-clipboard heredoc (HARD)
The human pastes ONCE and the dry-run auto-runs - the dry-run line goes
immediately after the closing `EOF`, inside the same fence.
**TWO-PASTE GATE: the dry-run block and the apply+smoke block are separate
pastes.** Block 1 writes the file + dry-runs; block 2 (delivered in the same
message, run only after a green verdict) bundles apply + smoke in ONE paste so a
failed apply cannot pass silently. Never combine write+apply in one paste; the
dry-run output is a human gate, not decoration.

### 1.2 Verdict symbols (HARD - EVERY mutating command, not only patches)
Final line of each mode, glyph INCLUDED in the print string:
```
print("🔍 DRY RUN OK")
print("✅ APPLIED")
print("↩️ REVERTED")
print("❌ ABORT (nothing written): <reason>")
```
Glyphs live in runtime print strings ONLY, never in doc prose or anchors. A
red/❌ verdict NEVER auto-proceeds to apply - READ it; a false-alarm red is
still a stop.

### 1.3 Confirmation prints (HARD)
**Every command that MUTATES state must echo the file, the action, and one
COUNTABLE fact** (line count, block count, file list). A silent mutation is
indistinguishable from a dropped command. The echo can LIE if it counts the
wrong thing or runs after a fatal - effect-verify with `ls`/`git status` in the
TARGET, not the echo.

---

## 2. EXECUTION (HARD)

- Run patches as `python patches/NN.py`, never `./patches/NN.py` (no exec bit).
  [ADAPT: env activation, import path.]
- **Every patch ends with a SMOKE-CHECK the human runs** - a fenced block that
  IMPORTS the changed code, INVOKES it, and asserts the invariant. A syntax
  check proves syntax only, NOT name resolution or runtime.
- **The invoke-assert must exercise the BRANCH that uses the change** - a smoke
  hitting only the unaffected/default/None branch is blind.
- **State runtime preconditions on every runnable block:** what must be running
  (app up / app closed / server up / nothing). Unstated = you forgot; ask.
- [ADAPT: test command + any plugin that must be installed or the test is a
  silently inert guard.]
- **Never pipe an interactive script through grep/head/tail** - its prompt lands
  in the pipe buffer and the run looks hung. Filter the PASTED output.

### 2.1 SEE BEFORE YOU PATCH
For any observable-behavior question, a live inspection seam beats
guess-patch-and-rerun every time. [ADAPT: the live seam - layer files define it.]
A dead diagnostic makes every fix slow; fix the instrument before writing
another blind patch.

---

## 3. HANDOFFS / TRIVIAL vs COMPLEX (HARD)

SIDE-QUESTIONS NEVER STOP THE MAIN LINE: answer briefly AND continue the
frontier work in the same reply. Never make the human look up code or confirm
state by hand - extract it with a fenced one-liner. The agent owns
technical/architectural calls; questions are UX/naming/scope only (plus a
missing required doc, s0). Trivial -> inline edit. Real logic -> full patch.

---

## 4. PRE-FLIGHT - NO TEST-GATED PATCHES (HARD)

- `--dry-run`: match every anchor its EXACT expected count, validate each target
  with the language's real checker, write nothing -> `🔍 DRY RUN OK` or
  `❌ ABORT (nothing written): <reason>`.
- **Short, ASCII-only anchors on real STATEMENTS** - never "the first
  import-like line" (code inserted into a string literal passes validation,
  matches grep, and does nothing).
- Write a per-file backup; `--revert` restores it. Stacked edits -> prefer
  git-clean recovery over chained reverts (s7).
- **Grep a symbol's DECLARATION before adding or using one** - "is X defined /
  what is it called" is a grep, not a guess. A "names unverified" prose warning
  gates NOTHING.
- **Never deliver a patch whose correctness needs a probe/test run FIRST.**
  Resolve name/signature by grep/read before writing. If a fact truly needs
  running code, ask for ONE probe and WAIT.
- No bare swallow-and-continue error handling - let it raise, log the traceback.
  A swallowed failure on a persistence path must surface where the human LOOKS.

### 4a. PROBE-FIRST (HARD)
A complex fix that fails ONCE -> the next step is a PROBE, not another fix (one
failure = wrong mental model). THREE failures on one mechanism = the model is
wrong, not the tweak placement - STOP, `git stash` this session's own patches on
that file, retest the clean baseline before any 4th attempt. Confirm WHICH LAYER
and WHICH ARTIFACT before patching; the assembled view can lie - descend to raw
state. Probes stay applied until the fix is PROVEN on disk. The human asking for
debug code overrides the agent's confidence.

---

## 5. EXPLANATION + COMMANDS (HARD)

- Keep answers SHORT - commands first, then one paragraph max, then blocks. No
  recap, no postamble; go long only for a real trade-off.
- **EVERY runnable command lives in a fenced ```bash block - no exceptions.**
  One block per copy-paste unit.
- Multiline heredoc commands, never `\`-continuation one-liners (breaks on
  single-line paste).
- Patch docstring = one line (what + gotcha). Anchor lines and marker comments
  are LOAD-BEARING - never strip them.
- After every patch: a compacted list of what changed; logic-only -> one or two
  sentences.

---

## 6. GUARDRAILS (enforced; deep rationale -> the project's design docs)

- **One source of truth = one ALGORITHM, not one call site** - build a shared
  quantity once, before the second consumer; two implementations always drift.
- **Gate-not-prompt** - consequential/irreversible edges are enforced by
  MECHANISM, never by asking the agent to behave. A gate is a guarantee, a
  prompt is a hope.
- **Extract by writing a NEW file behind a stable seam, not by splicing** a
  mixed-concern block in place.
- **The assembled/derived view can lie; the persistent store/raw state is
  truth.** Patch the store, not the in-memory copy.
- [ADAPT: project architecture invariants - one-line imperatives here, WHY in a
  design doc.]

---

## 7. COMMITS & RECOVERY (HARD)

**COMMIT PER PATCH** - each verified patch gets its OWN commit immediately after
its smoke passes; NO bulk/stacked commits. Themed grouping ONLY when patches are
one atomic unit. Never stack 3+ unpatched edits on one file - a later
probe-revert rolls past the working fixes. [ADAPT: commit/backup seam.]

Stacked-backup corruption -> `git stash` to a clean HEAD, verify the code runs,
rebuild in small committed steps. Revert order is newest-first ONLY, verifying
fix-lines survive after EACH.

---

## 8. SCOPE (HARD)

NO now-then-later patches: build the RIGHT home once - interim is allowed ONLY
when a prerequisite is genuinely missing. Recommending "(a) now, (b) as the
upgrade" is the anti-pattern. During a bug, stabilize the critical path ONLY;
LOG unrelated debt to the plan doc. Propose the deeper fix; zero band-aids.

---

## 9. USER INBOX + AGENT NOTEBOOK (HARD)

**User inbox** [ADAPT: file] - the human's todos/ideas between sessions. Read it
every session (part of s0). **The agent never edits or deletes a human item** -
it may ACT and REPORT that in the baton, but leaves the text; the human deletes.

**Agent notebook (NOTES)** [ADAPT: file] - the agent's OWN mid-session record,
written on its own initiative. At CHECKOUT the agent DISTRIBUTES each item to
its durable home, THEN archives the file. TAG every item by its DESTINATION
(`[roadmap]`, `[read_first]`, `[baton]`, `[verify this session]`), never by the
current activity - the tag makes checkout distribution mechanical.

---

## 10. CHECKOUT RITUAL (HARD)

**CHECKOUT NEEDS EXPLICIT USER CONFIRMATION - the agent ASKS and WAITS.**
**CADENCE - never checkout after a single patch or on a bare "continue"; once
2-3 patches have shipped, ASK.** **NEVER ship checkout artifacts in the same
reply as an unverified patch - patch, verify, THEN checkout.** Artifacts:
1. **Patch-log block** -> append in the locked s11 format.
2. **Plan update** -> amend the plan-of-record in place (merge-patch,
   backup-guarded, idempotent, dry-run-first).
3. **Baton** -> a NEW handoff note in the s12 format; archive the previous one
   in the same fence.
4. **Required-context decision - BEFORE writing the baton:** which docs can the
   NEXT frontier NOT be built without? `none` if none - NEVER blank.
5. **Preset** -> the <=4 files the next session opens; named in the baton.
6. **Commit line** -> hand the human a ready-to-run command.
7. **This-file self-evaluation:** a workflow rule/trap worth a line? Yes ->
   merge-patch it now. No -> say "nothing owed".

### 10.1 Plan-merge is a LIVE edit, not a rewrite
A merge-patch aborting on rerun with anchors-x0 usually means ALREADY APPLIED -
the idempotency guard working, not a failure; check the file first.

### 10.2 Reference-doc sync (same checkout)
A lagging reference doc is a lie. A doc greped during onboarding is a prime
staleness suspect: reality changed? -> amend + stamp. No? -> bump only the stamp.

### 10.3 FREEZE THEN FINGERPRINT (whole-file restructure)
Freeze the current file VERBATIM to an archive path FIRST. Then DIFF the
successor against that baseline by a stable FINGERPRINT per hard-won entry: an
entry carrying a distinct rule must conserve its fingerprint; only intended
de-dups may drop. Freeze-first alone is NOT enough - the diff catches the
silent drop.

---

## 11. PATCH-LOG FORMAT (locked, greppable)

Line-initial uppercase-colon tags so `grep "^ROOT:"` scans the whole log:
```
## <YYYY-MM-DD> - patches <N..M> (<theme>)

### <N> - <title>
ROOT:   <actual cause, one line>
FIX:    <what the patch did>
ANCHOR: <short ASCII substring(s) used>
SMOKE:  <post-apply assert the human ran>
GOTCHA: <trap - omit line if none>
LESSON: <distilled rule - omit line if none>
```
Omit empty tags; don't write "none".

---

## 12. BATON FORMAT (locked handoff)

First read of the next session, last write of this one. A CLAIM - the reconcile
overrides it.
```
## CHECKOUT <N..M> - <YYYY-MM-DD> - <frontier name>
BATON IS A CLAIM. Run the reconcile FIRST. It contradicts this -> it WINS.

STATUS:    <phase; what closed; what's now frontier>
FRONTIER:  <topmost unbuilt plan item>
DECISIONS OWED: <scope/UX/naming Qs, or "none">
START:     <the reconcile command> -> paste full output
GREPS TO PROPOSE:  <labeled grep block>
CONTEXT TO GREP:   <docs this frontier touches>
CONTEXT REQUIRED:  <docs the frontier CANNOT be built without; "none", NEVER blank>
PATCH-LOG RANGE:   <blocks N..M>
PRESET (<=4 files): <minimal open set; rest by grep>
DO-NOT:            <per-task traps>
ACTED ON USER INBOX: <items acted on, or "none">
```
A negative baton claim (a DO-NOT asserting "X does not work") is itself a CLAIM
- re-probe before trusting it.

---

## 13. PRESETS

The MINIMAL set the next session opens - 2-4 files. Everything else by grep. A
fat preset defeats the point.

---

## 14. FINDINGS - universal (language/framework findings live in their layers)

**Anchoring & patches**
- A stray tag after `EOF` drops the command silently; `cat -A` before anchoring.
- Insertion anchors are real STATEMENTS - code inserted into a string literal is
  valid, greppable, inert.
- A NEW SYMBOL in patch text has its BINDING grepped in the TARGET file before
  delivery; grep a cross-module callee's def line INCLUDING its return shape.
- Fixes-by-memory of your OWN recent patches still drift - re-grep anchors even
  for code you wrote this session.
- A DUP-SHADOWED definition makes an in-block anchor match TWICE - assert the
  count, target the LAST (live) occurrence; a single-match abort is correct.
- Retired control-flow blocks are replaced WHOLE, never partial-brace surgery.
- Never `sed` a multi-line statement - restore from git, edit line-based.
- NEVER delete code by index/range cut - remove via replace of a NAMED block
  asserted count==1.
- No `\` line-continuations in a delivered block.
- A patch that defines `main()` but never calls it dry-runs SILENTLY - no output
  = suspect a missing entry guard first.
- An insertion whose INSERTED text CONTAINS its own anchor is NOT idempotent -
  guard on a unique inserted MARKER's absence, not anchor count alone.
- An INSERT that CONSUMES its anchor must reinstate every consumed word - prefer
  append-not-consume; READ the bytes back, never trust the verdict alone.
- An ABSOLUTE hardcoded limit is a bug at a different scale - derive scaled
  limits as a FRACTION of the resolved value.
- A file APPEND without a trailing-newline check GLUES onto the last line.
- A multi-line anchor that is a prefix-SUBSTRING of a deeper-indented twin
  still matches - `cat -A` the EXACT block (every leading space) before
  anchoring nested handlers.
- An automated arg-injection must find the MATCHING paren, not the first `)` -
  a kwarg inside a NESTED call passes syntax and crashes live; per-site anchors
  beat a caller-rewrite loop.
- A hardcoded expected-count literal in a patch gate is itself a CLAIM that
  miscounts - MEASURE the count from source, assert whole-file conservation.
- A delete/rm block must ABORT on its OWN precondition, never trust the
  dry-run PROSE to gate it.
- Verdict glyphs embedded in a heredoc-carried BODY string need single
  escapes - double-escaped sequences print literally.
- Shell targets: an "=== SECTION ===" anchor in a .sh is a STRING inside an
  echo, not a statement - anchor shell insertions on real command lines; run
  `bash -n` INSIDE the dry-run for any .sh edit, and before every commit of
  the reconcile script itself.
- Multi-line shell functions written into an rc file via heredoc flatten to
  ONE broken line - write them with `printf '%s\n'`; a stale terminal keeps
  erroring after the disk is fixed - open a FRESH shell.

**Probes & smokes**
- A correct GENERAL RULE can be wrong for the SPECIFIC instance - grep the real
  call sites; the rule says be careful, the code says what is TRUE.
- ASSERT-BLIND CHECKLIST: name the BRANCH a smoke exercises before shipping it.
- A smoke assert reads the VALUE region, not the prompt/boilerplate around it.
- A smoke that INSTANTIATES a class must use its REAL constructor signature.
- A smoke indexing positionally on a prepended list asserts the stub - filter by
  role/key.
- A smoke that accepts the feature's FAILURE OUTPUT as a pass proves nothing.
- A probe through the SAME filter as the broken consumer proves nothing -
  ground-truth queries drop the consumer's WHERE clauses.
- A probe/call that SUCCEEDS does not exonerate the UI action the human reported
  - reproduce THAT exact path. A REPEATED "not working" is a SPEC MISMATCH until
  proven a code bug - instrument the handler ENTRY POINT before the 2nd fix.
- A dependency-on-a-live-service assert is flaky - assert the DECISION the
  feature owns.
- A multi-minute SILENT loop is indistinguishable from a hang - probe liveness;
  long deliverables need progress output.
- NO MANUAL "trigger the natural condition" - force the state via script.
- After ONE wrong-value round on a multi-stage chain, breadcrumb-probe EVERY
  stage in one patch.
- A probe's `--revert` restores the PRE-PROBE backup and DESTROYS a fix stacked
  after it. A probe printing a VERDICT after a failed transport is worse than no
  probe - gate verdicts on measurement success.
- A gap settled by MEASUREMENT, not theory - measure with the system's own
  instruments before theorizing.
- DIAGNOSE ON REAL ARTIFACTS
- Before designing a push/update mechanism, grep the patch log for prior
  art - the mechanism may exist already.
- Perceived settle time != measured handler time - deferred callbacks land
  AFTER the probe returns; stamp the whole chain or count origins.
- A probe joining two views by an ATTRIBUTE is blind when the attr-set is
  swallowed on some classes - count None-attr items FIRST, or join on a
  store-side key.
- A string-match assert targets the ACTUAL disk literal region, not a guessed
  slice - a bad follow-up assert crying wolf on a green apply is re-probed
  against ground truth, not trusted over the apply echo. (`ls -laS`, the actual bytes), never guess.

**Store & derived state**
- The persistent store is rarely the bug - compare the derived/render count to
  the store count FIRST; a read over accreting history must dedupe/filter.
- A hand-built payload/dict is a FIELD FILTER - a new field must be added at
  EVERY hand-copy site. Grep the reassembly sites.
- EXISTENCE-CHECK vs CONTENT-CHECK - a guard skipping on "target EXISTS" is
  WRONG when the target may be an empty stub; gate on rowcount/size.
- A generated artifact embedding absolute PATHS gets a content-check at LOAD,
  not an exists-check.
- Config/option KEY NAMES are facts - grep the WRITER of a key before probing.
- A rename sweep's scope is SPELLINGS, not one token - census every spelling;
  the scope includes the TEST tree. Worklists without DONE stamps resurrect.
- A data scrub scoped by OBSERVED INSTANCES misses generations - census-first by
  PATTERN over the whole table, then eligibility-check per hit.
- A directory MOVE must ALSO rewrite internal self-imports and self-paths.
- A user-facing verb shipped without a harness scenario is the lurk-space - new
  verb -> a scenario in the same phase exercising verb->continue->verb.

**Git & environment**
- pwd BEFORE any destructive git (filter-repo/reset/force).
- A fresh/moved tree needs `safe.directory` + user identity before any git
  command; `git add -A` AFTER `git rm --cached` re-adds the file.
- `git rm --cached` must be COMMITTED to take effect; verify with `ls-files`.
- A gitignored file reaches git ONLY via `git add -f`; confirm TRACKED with
  `ls-files` - "committed" can be a lie.
- `git add -A` sweeps in untracked artifacts - name the files; `git add <file>`
  does NOT unstage what's already staged; staged files RIDE THE NEXT COMMIT
  regardless of what the add names - commit the first set, THEN stage the second.
- A multi-file `git add A B C` ABORTS THE WHOLE ADD on the first bad pathspec,
  silently leaving the rest unstaged - verify `git status --short` before commit.
- An unpushed bad commit is undoable: `git reset --soft HEAD~1`; confirm
  unpushed FIRST.
- Never mix git homes in one add line - each repo's content rides its own add.
- Shell FUNCTIONS from an rc file do not exist in a non-interactive subshell.
- A wrong-directory heredoc echoes success - effect-verify in the TARGET dir.
- Never ship a block that is not safe to paste-run verbatim - no placeholders.
  EXCEPTION: a human-only value gets an EDIT_ME sentinel + an explicit edit
  instruction, and the verify asserts the sentinel is GONE.
- git's default pager makes a scripted verify LOOK hung - set pager to `cat`.
- A `||` inside `$(...)` guards only the NEXT command - wrap the whole fallback;
  a syntax check never proves command-substitution behavior, RUN the script.
- Never reason about a folder's contents without listing it first.
- A pty child that grabs the tty (a pager, a full-screen program) RE-ENABLES
  echo on exit - a termios echo-off set once at spawn is not durable. Re-assert
  it before every command send, or echoed input doubles a done-sentinel and the
  read never seals. Set PAGER/GIT_PAGER=cat in the pty env, not only TERM=dumb.
- MULTIPLE repos can share one workflow - verify pwd/git-toplevel before any
  patch or probe; patch numbers are per-repo (`ls patches/ | sort -V | tail -1`).

**Checkout & docs**
- NEVER ship checkout artifacts in the same reply as an unverified patch.
- Chained `--revert` over STACKED patches restores a pre-stack snapshot,
  silently destroying later fixes. Revert newest-first, verify after EACH.
- A "VERIFIED"/"APPLIED" print is a CLAIM - re-grep after stacked edits.
- A silent mutation looks identical to a dropped one - echo file + action +
  countable fact.
- An effect-verify pattern must match ONLY the new state.
- A residual-check grep that matches ITS OWN patch/note text cries wolf.
- A verify grep matching a COMMENT lies like an assembled view - grep the
  CALL/symbol, not the bare word.
- A no-ref sweep grep filtered by MATCHED-FILE path can't tell two same-named
  files apart - filter by the RESOLVED import target.
- STACKED UNBANKED edits can corrupt past backup recovery - git-revert to the
  last COMMIT, rebuild in ONE clean patch.
- Track promised-but-undelivered items EXPLICITLY
- Revert-vs-continue on a struggling feature is the HUMAN's call - state the
  recommendation + cost of each path, then ask; never unilaterally withdraw
  shipped work.
- A bus/decision event NOBODY renders is an invisible diagnostic - every new
  one ships WITH a log or UI leg in the same patch. - a "planned" feature can
  silently never ship.
- A claim is a CLAIM until seen on disk - which is why every session opens with
  the reconcile.

---

## 15. ADDENDUM - OUTPUT DISCIPLINE

After every patch, show a compacted list of what changed so the human can check
the outcome. Logic-only -> one or two sentences.

---

## 16. PROJECT FACTS (pure reference - the merge fills this from the project)

[ADAPT: layout, run/test, commit/backup seam, reconcile script, tools, live
seam, environment gotchas.]
