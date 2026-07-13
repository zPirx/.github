# preflight - the session reconcile

`preflight_core.sh` is a skeleton. Each project fills its `[ADAPT]` slots and
keeps the filled script as `preflight.sh` in its own repo. The script runs at
the start of every session and asserts the project's claims against disk.

## The three phases
GIT commits any uncommitted work on confirm, then refuses to continue while the
tree is dirty. Nothing else runs until the tree is clean.

CLEAN removes stale `.bak` files left by reverted patches.

VERIFY is the reconcile. It checks the key files exist, imports the changed
code, and invokes the critical paths to assert they return real values. A claim
in the baton is treated as a claim until VERIFY confirms it on disk.

## The [ADAPT] slots
- env activation: venv or conda, activated before any language command.
- SRC and BAKDIR: the source root and where `.bak` files are written.
- KEY FILES: every file whose absence means a broken tree.
- PROJECT ASSERTS: the language layer's reconcile recipe plugged into PHASE 3.
  python.md s4 gives the Python escalation (compile, import, cycle-walk, invoke,
  stubbed run on a tmp store copy). svelte.md s5 and react.md s5 give the build
  and endpoint checks.

## The summary contract
Every assert prints `  OK  <what>` or `  !!  <what>` or `  ??  <what>`. The
summary greps those markers. All green means proceed with the baton frontier.
Any `!!` or `??` means paste the flagged lines and fix them first.

## Another harness
A harness reads this the same way a person does: run the script, read the
summary, trust disk over the baton. VERIFY is where "what the docs say" and
"what the code does" get checked against each other.
