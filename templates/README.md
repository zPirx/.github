# READ_FIRST Templates

Composable working-agreement + scar templates, merged per project into a
working READ_FIRST. One source of truth per layer.

- core.md    - the spine (delivery, checkout, baton, probe-first, universal scars)
- python.md  - Python layer (ast.parse gate, venv, import-cycle scars)
- svelte.md  - Svelte layer ($inspect/runes seam, scoped-CSS scars)
- react.md   - React layer (hooks/DevTools seam)
- qt.md      - Qt layer
- ASSEMBLE.md - which layers merge per project, and the curation guards

A project merges core + language + framework into its own docs/READ_FIRST.md.
Layers are extracted and grown from real project work; this is a living
knowledge base, not a static ruleset.

(Templates are being extracted from existing projects - see commit history.)
