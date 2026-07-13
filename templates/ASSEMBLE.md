# ASSEMBLE - how the layers merge into a project READ_FIRST

## The merge
An agent MERGES the layers into `<project>/docs/READ_FIRST.md`, ONCE, at
project start. The combined file is committed and read each session. Re-merge
only when a template materially changes. The merge is a build-time step
producing a real file - NOT a runtime overlay.

Merge mechanics:
1. core.md is the skeleton - its section numbering (s0-s16) is the project's.
2. Each layer's sections state which core section they extend or fill
   ("extend core s4", "fills core s2.1") - splice the layer bullets into that
   core section; layer finding clusters append into core s14 under their own
   cluster heading.
3. Fill every `[ADAPT]` slot with the project's facts before first use - grep
   `[ADAPT` to find them all; none may survive into a working READ_FIRST.
4. Project-LOCAL rules (store paths, model quirks, launch flags) go into the
   merged file's s16 - never back into a shared layer.

## Layer map (one home per layer, never duplicated)
| project    | layers                  |
|------------|-------------------------|
| crowd-eye  | core + python + svelte  |
| rldeck     | core + python + react   |
| craftwerk  | core + python + qt      |
| agentkern  | core + python           |
| kultur-stp | core + svelte           |

qt.md is not yet extracted (lives in craftwerk's READ_FIRST until its own
carve pass).

## The feedback loop
The agent extracts a new finding into the matching shared layer at checkout.
A universal finding goes to core. A framework trap goes to its layer. Every
project receives the lesson through its next re-merge, including the projects
where the bug never appeared. Project-local findings stay in the project's
s16.

## Curation guards
- A finding earns its place only if it COST REAL TIME and carries a MECHANISM.
  "Be careful" without a mechanism is deletable.
- Cluster + grep, never linear read. A cluster passing ~15 entries sub-splits.
- FREEZE-THEN-FINGERPRINT on any restructure: freeze the current file VERBATIM
  to an archive path FIRST, then diff the successor per-entry.
- FINGERPRINT RULE (hard-won, four false alarms in one extraction): a
  fingerprint is ONE single-line, case-exact, literal token unique to its
  entry. Never a phrase (line wraps break it), never a regex passed to a
  literal grep, never a case-mismatched quote. A red fingerprint is READ
  before it is believed - the check itself can lie.
- EXTRACTION SOURCE SET: any extraction pass lists its source files up front,
  INCLUDING the lineage ancestors of every source (a template's parent file
  carries findings the child dropped). A source discovered mid-pass triggers a
  backfill diff, not a shrug.

## About the layers
The core layer describes the working process: how changes are delivered,
verified, committed and handed over. This process keeps quality stable and
applies to any codebase.

The language layers collect the lessons from applying this process to a
specific stack. Every entry names a real problem and explains the mechanism
behind it. Entries that no longer apply are dropped when the layers are
updated.

## Compatibility with agentkern
Layer entries use the same shape as a finding in the agentkern store: a
one-line rule as the title and a body with the mechanism and a reference to
the incident behind it. An entry is never edited in place; a new entry
replaces it and the old one stays in the history.

The layers hold two kinds of entries. A finding describes a mechanism to
check against. A discipline entry describes a procedure to follow; in the
layers these are the rules marked HARD. Both kinds must meet the curation
guards described above.

## Transparency
The templates are public. A reader can see which problems came up during
development and how the work is verified. AI use is disclosed in the shared
AI_POLICY.
