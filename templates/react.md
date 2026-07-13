<!-- REACT LAYER - merges after core (+ python if the backend is Python).
     React/TS seam, hook + CSS findings, reconcile asserts. ASCII-only.
     Cite as `re sN`. -->

# READ_FIRST - react layer

Merged after core. The frontend is a projection fed by API/events - agent/
business logic stays backend-side.

---

## 1. DELIVERY (extend core s1)

- TSX full rewrites ship as single-quoted-EOF heredocs so backticks + `${...}`
  stay literal; if `&`/quotes still bite, write via Python `Path.write_text`.
- TS targets: defer validation to post-apply `node --check` / the bundler - a
  Python brace-counter mis-tokenizes TS; never gate the dry-run on it.

## 2. LIVE SEAM (fills core s2.1)

- Browser DevTools on the Vite dev server: Console FIRST for any "the panel
  does X" report -> Network -> Elements (computed CSS) -> Sources.
- A backend probe that SUCCEEDS does not exonerate a UI action - a working curl
  can mask a frontend ReferenceError that aborts the handler before fetch.
- Probe the DOM lifecycle (mount vs async-load order) before re-patching a
  symptom.

## 3. HOT-RELOAD (fills core s2)

- Vite HMR applies `.ts`/`.tsx`/`.css` on save - no restart. EXCEPTION: an
  added/removed npm dep -> one Vite restart. EVERY patch states the server
  action.
- The dev stack STAYS RUNNING during patching - a heredoc only writes disk.

## 4. FINDINGS (React & frontend)

**Hooks & rendering**
- ALL hooks go before ANY conditional return - a hook after an early return is
  a latent crash that survives until React reuses a component instance across a
  role change ("Rendered fewer/more hooks than expected", black screen).
- A `const` referenced before its declaration throws a TDZ error, not
  undefined - placement matters across early-return BRANCHES, not just hook
  order.
- A file importing NAMED hooks only (`import { useState } from "react"`) has NO
  `React` namespace - `React.Fragment` throws ReferenceError; use named
  imports. Grep the import line; grep, don't caveat.
- Each-lists keyed positionally break on wholesale replacement - key by stable
  id.
- Grep a symbol's declaration before ADDING one - a guessed setter name makes a
  duplicate-const build break; a hook may expose no setter at all.

**State & persistence**
- A scroll/state-restore that runs ON MOUNT restores into an EMPTY container -
  async content loads AFTER mount; restore only once content is present.
- Reset-on-reboot-but-not-on-refresh: PROBE the hook in DevTools before
  swapping storage backends - causes seen: browser clear-on-exit
  (environmental) and a load-time FETCH RACE locking empty defaults. Retry a
  failed settings load (bounded); never lock empty defaults.
- Rebuilt-from-history lists carry synthetic ids - any per-item UI action needs
  the UI-state source that carries real ids, never the LLM payload.

**CSS**
- A layout symptom that resists 2+ inline-style patches means a CSS CLASS is
  overriding the inline style - GREP the class rule before patching again
  (flex-direction, white-space, width all bit this way).
- A blanket rule on a SHARED selector (`th,td`) fights per-cell intent -
  override per-cell, never widen the shared rule.
- `opacity` fades the BACKGROUND too - dim TEXT via `color`, never `opacity`,
  on an opaque sticky header.
- Duplicated inline styles DRIFT - a style block in 2+ render paths becomes ONE
  shared component.

**Verification**
- A verify grep matching the bare word (e.g. "localStorage") matches COMMENTS -
  grep the CALL (`localStorage\.(get|set)Item`).
- A no-ref sweep filtered by matched-file path can't tell two same-named files
  apart - filter by the RESOLVED import target.
- A backgrounded server restart races an immediate request - poll the health
  URL until it answers before hitting endpoints.

## 5. RECONCILE ASSERTS (plug into preflight_core.sh)

- Bundler/typecheck pass (`npm run build` tail / `tsc --noEmit`) post-apply.
- Contract asserts on the endpoints the UI consumes; browser confirm stays the
  human's step.
