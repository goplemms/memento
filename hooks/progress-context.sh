#!/bin/bash
# Put the active feature's place back in context after compaction or resume.
#
# Compaction summarizes away exactly what a long orchestrate run needs most:
# which milestone is active, the last green commit, and the next step. That
# lives in PROGRESS.md's "Current block", so re-inject it verbatim.
#
# Finding the workspace:
#   - inside a repo: the feature dirs under bin/workspace-root.sh's answer
#   - otherwise (project threads start above the repo clones): every repo's
#     feature dirs in the shared project folder
# Only PROGRESS.md files touched in the last 14 days count, newest first, at
# most two, so a forgotten feature doesn't hijack an unrelated session.
#
# Never fails the session (always exits 0); with nothing to report it emits
# nothing.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 0
SHARED="${MEMENTO_PROJECT_FILES:-/mnt/project-files}"

DIRS=()
if WS="$("$ROOT/bin/workspace-root.sh" 2>/dev/null)"; then
  DIRS+=("$WS")
elif [ -d "$SHARED/memento/" ]; then
  for d in "$SHARED"/memento/*/; do DIRS+=("${d%/}"); done
fi
[ ${#DIRS[@]} -gt 0 ] || exit 0

FILES="$(find "${DIRS[@]}" -mindepth 2 -maxdepth 2 -name PROGRESS.md \
           -not -path '*/archive/*' -mtime -14 -printf '%T@ %p\n' 2>/dev/null \
         | sort -rn | head -2 | cut -d' ' -f2-)"
[ -n "$FILES" ] || exit 0

BODY="Active memento feature workspace(s), from PROGRESS.md. Resume from the
current block; read plan.md beside it before changing course."
while IFS= read -r f; do
  BLOCK="$(sed -n '/^## Current block/,/^## /p' "$f" | sed '1d;/^## /d')"
  [ -n "$(printf '%s' "$BLOCK" | tr -d '[:space:]')" ] || continue
  BODY="$BODY

$(dirname "$f")/
$BLOCK"
done <<< "$FILES"

ESCAPED="$(printf '%s' "$BODY" \
           | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/ /g' \
           | awk '{ printf "%s\\n", $0 }')" || exit 0

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
  "$ESCAPED"

exit 0
