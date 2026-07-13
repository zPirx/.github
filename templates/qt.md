<!-- QT LAYER - merges after core + python. PySide/PyQt GUI findings and the
     live seam. ASCII-only. Cite as `qt sN`. -->

# READ_FIRST - qt layer

Merged after core + python. A Qt desktop host. GUI mutation stays on the GUI
thread; store and compute run off-thread and reach the GUI through queued
signals.

---

## 1. LIVE SEAM (fills core s2.1)

- A crashy widget is inspected offscreen first: construct it headless with a
  QApplication, drive it, read geometry (`y`/`h`/`sizeHint`) before guessing a
  style or layout fix.
- Window-aggregate behaviour (a dock/central shrink floor) needs a LIVE probe -
  offscreen construction ignores `propagateSizeHints`.
- After the SECOND failed layer guess on a perceived freeze, escalate to py-spy
  against the live pid, never a third guess.

## 2. THREADING (HARD)

- A cross-thread `Signal.connect(LAMBDA)` runs the lambda in the EMITTER's
  worker thread, so a GUI mutation there silently no-ops. Marshal via a BOUND
  METHOD on a QObject; the payload carries the id. Grep `.connect(lambda` on any
  off-thread signal.
- A shared/`__init__` singleton constructs at IMPORT time, before QApplication -
  a QTimer created there never fires. Lazy-start it via an `ensure_*()` called
  from the GUI side.
- A poller saturates the loop invisibly - audit QTimer intervals first (a 192ms
  tick on a 500ms budget is 40% of the loop).

## 3. LAYOUT & SIZING (HARD)

- A Qt widget cannot shrink below its children's `minimumSizeHint`. Set an
  Ignored horizontal policy and classify against the RESIZE EVENT width
  (`e.size().width()`), never `self.width()`.
- A QMainWindow's shrink floor is the SUM of every dock and central
  `minimumSizeHint`; a multi-pane panel hard-blocks resize silently (no resize
  event fires). `setSizePolicy(Ignored)` does NOT lower `minimumSizeHint` - only
  a `minimumSizeHint()` override does. qtflex FloorCap is the reusable override.
- `parentWidget().layout()` is NOT the row a widget sits in - Qt nesting can
  resolve it to an outer VBox. Read the layout construction code and anchor on
  the actual HBox variable before inserting beside a widget.
- Baseline drift with IDENTICAL styles is the GLYPH: fullwidth chars
  (U+FF0B/FF0D) and the ASCII hyphen have different vertical metrics than `+`;
  U+2212 MINUS SIGN matches `+` exactly.

## 4. PAINT & VISIBILITY

- A visibility flip in a scroll area completes via a POSTED LayoutRequest.
  `setUpdatesEnabled(False)` -> mutate -> re-enable via `singleShot(0)`, never a
  synchronous `update()` (a sync paint squeezes intermediate geometry).
- An app-GLOBAL event filter installed during widget construction segfaults on a
  web-view compositor. Scope the filter to a widget tree and arm it
  post-construction via `singleShot(0)`.
- The wheel-focus guard: WheelFocus lets the wheel grab focus and Enter lands on
  viewports, not widgets. Use click-to-engage plus a forwarded `event.clone()`
  to the enclosing scroll area; install with StrongFocus.

## 5. LIFETIME & STATE (HARD)

- A closable pane holding a slot into an app-lifetime singleton crashes when the
  C++ object is deleted (libshiboken). Guard the slot with `try/except
  RuntimeError` and self-disconnect.
- A QTabWidget PAGE never receives `hideEvent` - a save hooked to hideEvent
  never fires. A save hooked to STARTUP tab-restore fires with the bar at index
  0 and CLOBBERS the stored value. Persist panel-page state in the layout save
  path (close-only), restore after geometry, and PROBE both save and restore
  values before hooking.
- A new stateful UI element (sort, selection, splitter, collapse, toggle,
  active tab) ships WITH persistence in the SAME patch: saved to the app config
  on change, restored in `__init__`.

## 6. PATCHING QT CODE (HARD)

- An inline edit that INSERTS a method after an anchor inside a class must
  invoke-assert the HOST method still runs its TAIL statements. A displaced
  `super().start()` passed ast.parse, passed unrelated tests, and left every
  scan thread silently dead.
- A patch that ADDS a user-visible element or a NEW WRITER to an existing UI
  slot is a UX decision - ask before implementing, even when trivial, and grep
  the slot's existing writers first (a second writer races the first).
