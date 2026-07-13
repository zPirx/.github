<!-- SVELTE LAYER - merges after core (+ python if the backend is Python).
     Svelte 5 (runes) seam, frontend findings, reconcile asserts. ASCII-only.
     Cite as `sv sN`. -->

# READ_FIRST - svelte layer

Merged after core. The frontend is a dumb projection over the API - no model/
business logic in Svelte.

---

## 1. DELIVERY (extend core s1)

- A `cat > file.svelte` heredoc breaks on Svelte's `&`/backticks/quotes ->
  write Svelte/JS full rewrites via Python `Path.write_text` inside the patch,
  NEVER a bash heredoc.
- A bash command with `!` history-expands inside double quotes -> single-quote
  JS/curl.
- Heredoc terminator collides with a trailing JS string literal - write JS
  string literals in delivered Python with DOUBLE quotes.
- Svelte/JS targets: a grep-count smoke or `npm run build` AFTER apply - a
  Python brace-counter mis-tokenizes JS/Svelte; never gate the dry-run on it.

## 2. LIVE SEAM (fills core s2.1) - the browser IS the seam

Ladder, cheapest first:
- `$inspect(x)` - logs on init + every update of a reactive value (dev-only,
  stripped from prod builds). The replacement for `$: console.log`.
- `$inspect(x).with((type, x) => { debugger })` - break on a specific change.
- `$inspect.trace()` as the FIRST statement of an `$effect`/`$derived` body -
  prints WHICH reactive dep caused the re-run. Reach for it before
  guess-patching a reactivity bug.
- F12 DevTools: Console first -> Network (the backend<->frontend truth;
  catches "curl passes, UI breaks"; disable-cache + hard-refresh) -> Elements
  (computed CSS) -> Sources (Vite source maps land breakpoints on real lines).
- svelte-devtools extension: its stable line is Vite+Svelte 4; Svelte 5 support
  is partial - do NOT rely on it. `$inspect` + F12 is the real seam.
- After the SECOND failed UI guess, instrument the handler ENTRY POINT.

## 3. HOT-RELOAD (fills core s2)

- Vite HMR applies `.svelte`/`.css` on save - no restart. EXCEPTION: a new npm
  dep -> one Vite restart (dep pre-bundling). EVERY patch states the server
  action.
- Patch delivery blocks are PASTE-SAFE while the app runs (disk write only) -
  never demand the app be closed unless the patch writes the live store.

## 4. FINDINGS (Svelte & frontend)

- A GLOBAL CSS selector silently overrides a scoped one - set width/font-size
  EXPLICITLY on controls, don't rely on scope winning.
- Shared CSS declaration strings appear on MULTIPLE selectors - anchor a UNIQUE
  neighbouring fragment, never the shared value.
- `{ ...i, ...res }` KEEPS stale keys when res omits them - explicit-null
  dropped fields before the spread.
- Svelte each-blocks keyed by array INDEX shuffle/crash on remove - key by a
  stable id.
- A "mode/method" bug can live in TWO separate markup blocks with separate
  handlers (tile vs lightbox) - grep which component renders BEFORE patching.
- A Svelte 5 `$state` proxy read at a breakpoint shows a getter/setter
  FUNCTION, not the value - use `$state.snapshot(x)` or `$inspect`.
- Svelte 5 reactivity: reassign objects (`x = {...x, k}`), never mutate.
- Frontend-only state (`local.*`) resets on hard refresh - don't trust a
  "persists" claim without grepping the API round-trip.
- VIEW-STATE PERSISTENCE: new persisted state must be (1) added to the persist
  payload, (2) hydrated on mount, (3) hydrated AFTER its data source loads -
  the ordering finding.
- Reserve fixed UI space for conditional content - growing content reflows the
  layout. Non-reflow pattern: `position:absolute; top:100%` inside a
  `position:relative` parent.
- Browser is the HUMAN's step: a passing curl does NOT prove a UI fix - say
  "verified by curl: X; please confirm in the browser: Y".

## 5. RECONCILE ASSERTS (plug into preflight_core.sh)

- `cd frontend && npm run build 2>&1 | tail -3 && rm -rf dist` - the real
  JS/Svelte validator; run AFTER apply, never as the dry-run gate.
- Backend<->frontend contract: curl the endpoints the UI consumes; but the
  browser path stays the human's confirm step.
