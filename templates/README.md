# READ_FIRST Templates

Composable working-agreement + finding templates, merged per project into a
working READ_FIRST. One source of truth per layer.

- core.md    - the spine (delivery, checkout, baton, probe-first, universal findings)
- python.md  - Python layer (ast.parse gate, venv, import-cycle findings)
- svelte.md  - Svelte layer ($inspect/runes seam, scoped-CSS findings)
- react.md   - React layer (hooks/DevTools seam)
- qt.md      - Qt layer
- ASSEMBLE.md - which layers merge per project, and the curation guards

A project merges core + language + framework into its own docs/READ_FIRST.md.
The layers grow out of real project work. New findings are extracted from
the projects at checkout and reach the other projects through their next
re-merge.

## About the layers
The core layer describes the working process: how changes are delivered,
verified, committed and handed over. This process keeps quality stable and
applies to any codebase.

The language layers collect the lessons from applying this process to a
specific stack. Every entry names a real problem and explains the mechanism
behind it. Entries that no longer apply are dropped when the layers are
updated.

