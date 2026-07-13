#!/usr/bin/env bash
# preflight_core.sh - TEMPLATE. The 3-phase session reconcile skeleton:
#   1) GIT   2) CLEAN .bak   3) VERIFY (layout + project asserts)
# Grep "[ADAPT" for every slot. Project asserts plug into PHASE 3 - the
# language layers (python.md s4 etc.) describe the assert recipes.
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 1; }
cd "$ROOT" || exit 1

# [ADAPT: env activation - venv/conda; report-only or auto-activate]
# [ADAPT: SRC=<source root>  BAKDIR=docs/.bak]
SRC="[ADAPT_SRC]"
BAKDIR="docs/.bak"

ARG_MSG="${1:-}"
pause() { read -rp "$1 [y/N] " a; [ "$a" = "y" ] || [ "$a" = "Y" ]; }

# Full-run log, overwritten each run (paste-once)
LOG="docs/preflight.log"
exec > >(tee "$LOG") 2>&1

echo "############ PHASE 1 - GIT ############"
git status -sb; echo
DIRTY=$(git status --porcelain | wc -l)
if [ "$DIRTY" -eq 0 ]; then
  echo ">> Tree CLEAN. Skipping to cleanup."
else
  git diff --stat HEAD; echo
  echo ">> $DIRTY uncommitted."
  if pause ">> Stage ALL + commit?"; then
    git add -A; git status -s; echo
    MSG="$ARG_MSG"; [ -z "$MSG" ] && read -rp ">> Commit message: " MSG
    [ -z "$MSG" ] && MSG="session checkout: stage working tree"
    git commit -m "$MSG" || { echo "!! commit failed - STOPPING"; exit 1; }
  else
    echo "!! Declined. Cleanup UNSAFE with uncommitted work. STOPPING."; exit 0
  fi
fi
DIRTY2=$(git status --porcelain | grep -v '^??' | wc -l)
[ "$DIRTY2" -ne 0 ] && { echo "!! tracked files still modified - STOPPING"; exit 1; }
echo ">> Clean. Proceeding."; echo

echo "############ PHASE 2 - CLEANUP (.bak) ############"
mapfile -t BAKS < <(find "$SRC" "$BAKDIR" -type f -name '*.bak*' 2>/dev/null)
if [ "${#BAKS[@]}" -eq 0 ]; then
  echo ">> No .bak files."
else
  printf '   %s\n' "${BAKS[@]}"
  if pause ">> Delete ALL ${#BAKS[@]} .bak?"; then
    find "$SRC" "$BAKDIR" -type f -name '*.bak*' -delete; echo ">> deleted."
  else
    echo ">> kept."
  fi
fi
echo

echo "############ PHASE 3 - VERIFY ############"

echo "=== BATON (expect exactly ONE docs/FOLLOWUP_*.md) ==="
mapfile -t FUS < <(ls docs/FOLLOWUP_*.md 2>/dev/null)
if [ "${#FUS[@]}" -eq 1 ]; then printf "  OK  baton: %s\n" "${FUS[0]}"
elif [ "${#FUS[@]}" -eq 0 ]; then echo "  !!  NO baton in docs/ - checkout broken"
else printf "  !!  %s batons - archive the older to docs/legacy/followups/\n" "${#FUS[@]}"; fi
[ -d docs/legacy/followups ] && echo "  OK  docs/legacy/followups/" || echo "  !!  docs/legacy/followups/ MISSING"
echo

echo "=== KEY FILES (exists? lines) ==="
# [ADAPT: list every file whose absence means a broken tree]
for f in docs/READ_FIRST.md docs/USER_TODO.md; do
  if [ -f "$f" ]; then printf "  OK  %5s  %s\n" "$(wc -l < "$f")" "$f"
  else printf "  ??  %5s  %s\n" "-" "$f"; fi
done
echo

echo "=== PROJECT ASSERTS ==="
# [ADAPT: plug the layer assert recipes in here, escalation order:
#   python.md s4: py_compile -> import -> cycle-walk -> INVOKE keystones
#                 -> stubbed run on a TMP store copy
#   svelte.md s5: npm run build tail (post-apply validator)
#   react.md  s5: bundler/tsc pass + endpoint contract asserts
#  Every assert prints "  OK  <what>" or "  !!  <what>" - the summary greps these.]
echo "  ??  no project asserts wired yet [ADAPT]"
echo

echo "############ SUMMARY ############"
sleep 0.3
NOK=$(grep -c "^  OK " "$LOG" || true)
NBAD=$(grep -c "^  !! " "$LOG" || true)
NMISS=$(grep -c "^  ?? " "$LOG" || true)
echo "  OK: $NOK   !!: $NBAD   ??: $NMISS"
if [ "$NBAD" -eq 0 ] && [ "$NMISS" -eq 0 ]; then
  echo "ALL GREEN - proceed with the baton frontier."
else
  echo "ATTENTION - paste from here down:"
  grep -E "^  (!!|\?\?) " "$LOG"
fi
echo ">> full log: $LOG (overwritten each run)"
