#!/usr/bin/env bash
# ideas-ledger.sh
# Print the path of the ideas ledger, creating it from templates/ideas.md when
# it doesn't exist yet.
#
#   1. $MEMENTO_IDEAS_LEDGER                if set (explicit override)
#   2. /mnt/project-files/memento/ideas.md  in a Claude Projects cloud thread:
#      one ledger for the whole project, across repos
#   3. <repo>/scratchpad/ideas.md           everywhere else
#
# Same shared-folder signal as workspace-root.sh.
set -euo pipefail

# The template ships next to this script, so take the kit root from the
# script's own path rather than CLAUDE_PLUGIN_ROOT, which may name another build.
KIT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

SHARED="${MEMENTO_PROJECT_FILES:-/mnt/project-files}"

if [ -n "${MEMENTO_IDEAS_LEDGER:-}" ]; then
  LEDGER="$MEMENTO_IDEAS_LEDGER"
elif [ -d "$SHARED/" ] && [ -w "$SHARED/" ]; then
  LEDGER="$SHARED/memento/ideas.md"
elif REPO="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  LEDGER="$REPO/scratchpad/ideas.md"
else
  echo "error: not inside a git repository and no shared project folder (cwd: $PWD)" >&2
  exit 1
fi

TEMPLATE="$KIT_ROOT/templates/ideas.md"
[ -f "$TEMPLATE" ] || { echo "error: template not found at $TEMPLATE" >&2; exit 1; }
if [ ! -e "$LEDGER" ]; then
  mkdir -p "$(dirname "$LEDGER")"
  # noclobber: if another thread made it a moment ago, keep theirs.
  ( set -C; cat "$TEMPLATE" > "$LEDGER" ) 2>/dev/null || [ -e "$LEDGER" ]
fi
echo "$LEDGER"
