<!-- PYTHON LAYER - merges after core.md. Python-specific gates, findings,
     and reconcile asserts. ASCII-only. Cite as `py sN`. -->

# READ_FIRST - python layer

Merged after core. Fills core's [ADAPT] slots for a Python codebase.

---

## 1. GATES (extend core s4)

- `.py` targets -> `ast.parse` in the `--dry-run` gate (syntax proof, nothing
  more).
- **ast.parse != name resolution** - grep the import block + subclass tree as
  dry-run reasoning; after any symbol move/rename run `python -c "import <top>"`,
  not just py_compile.
- **ast.parse cannot catch an import CYCLE** - assert it with an ImportFrom-walk
  after any base-module extraction.
- Verify an import by an ast-node walk, not grep (docstrings match grep).
- No bare `except: pass` - let it raise, log the traceback.

## 2. ENVIRONMENT (fills core s2 slots)

- venv at `./venv` or a conda env [ADAPT: name]; activate before anything.
- Run from repo root. [ADAPT: import rooting - PYTHONPATH=src, root-rooted
  `from src.x import`, or installed `-e` package.]
- Test command: `pytest -q` [ADAPT]. A plugin-gated lane (pytest-asyncio,
  pytest-qt) goes SILENTLY INERT if the plugin is missing - the reconcile
  asserts the plugin imports.
- A patch script importing project modules needs
  `sys.path.insert(0, str(ROOT))` - `python patches/NN.py` puts patches/ on
  sys.path, not the repo root.

## 3. FINDINGS (Python-specific)

- Verbatim extraction behind a re-export shim breaks CALL resolution while
  passing IMPORT resolution - always INVOKE + assert the moved function's
  invariant, on the branch that uses the moved dependency.
- Verify the BODY of any function whose RETURN VALUE you pass as an argument.
- An ensure-once/idempotent refactor must be smoked against the path that does
  NOT exist yet.
- `re.sub` replacement strings process backslash escapes - use a lambda repl or
  `str.replace`; never patch a patch twice (second failure = rewrite from
  ground truth).
- A guessed-module import inside try/except-pass is invisible to every
  downstream smoke - grep the callee's `def` line pre-ship.
- A smoke that INSTANTIATES a class greps `def __init__` first.
- Heavy imports (TensorFlow, torch) in a "quick" smoke are slow and grab the
  GPU - keep smokes on the light layers; heavy code is verified by the real run.
- State-mutating smokes run against an ISOLATED db/store (env-var override or a
  tmp copy), never the live store.
- An upstreamed symbol with a CHANGED return shape passes every backend smoke
  and crashes the CONSUMER - grep all consumers before changing a shape.
- An editable-installed (-e) shared package makes the OTHER repo's tree part of
  THIS app's live runtime - before editing the shared package ask "which hosts
  are live"; before debugging host weirdness check the package's git status too.
- Test engine logic with NO GPU or weights by stubbing the heavy deps
  (`module.fn = lambda ...`), then call the pure functions - deterministic and
  instant.
- A new user-facing verb ships WITH a harness scenario in the same patch,
  exercising verb -> continue -> verb. A verb with no scenario is the lurk-space
  where a state bug hides until live use.
- When there is no automated suite, the ladder IS the suite: a no-deps unit
  stub, then an end-to-end call, then a human confirm. Name which rung a check
  belongs to.

## 4. RECONCILE ASSERTS (plug into preflight_core.sh)

The Python assert block, in escalation order (each proves what the previous
cannot):
1. `python -m py_compile <files>` - syntax.
2. `import` each moved/renamed module - name resolution.
3. ImportFrom-walk - cycle stays dead after an extraction.
4. INVOKE keystones and assert the VALUE (import-resolves != call-resolves).
5. Invoke against a TMP COPY of the store with heavy deps stubbed
   (`module.fn = lambda ...`) - exercises real code, touches nothing live.


## 5. PACKAGING & PUBLISHING FINDINGS

- An in-tree pip package must be FLAT (code beside its pyproject via
  package-dir) - a nested pkg/pkg/ layout is CWD-shadowed from repo root.
- A pyproject table inserted mid-[project] REPARENTS the keys below it - new
  tables go at FILE END.
- A local `-e` install never builds the sdist - run `python -m build` before
  any CI tag.
- PyPI: a 200 on the project page is a SOFT page; `/simple/<name>/` is the
  truth. The README is baked into the WHEEL - a GitHub docs fix does not fix
  the PyPI page; only the next release does.
- Re-pushing an EXISTING git tag triggers no workflow - delete remote+local,
  re-tag, push. A PAT scope edit does not apply to the old secret - REGENERATE.
- CI ground truth = `gh run view --log-failed`, never the annotation summary.
