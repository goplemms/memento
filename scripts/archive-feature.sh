#!/usr/bin/env bash
# archive-feature.sh <dir>
# Date-prefixed move of a finished feature workspace to <scratchpad>/archive/.
# REFUSES to archive unless PROGRESS.md has a completed Closeout section.
set -euo pipefail

usage() { echo "usage: archive-feature.sh <dir>" >&2; exit 2; }
[ $# -eq 1 ] || usage
TARGET="$1"

if ! REPO="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "error: not inside a git repository (cwd: $PWD)" >&2
  exit 1
fi

# Accept either an absolute path or a name under scratchpad/.
if [ -d "$TARGET" ]; then
  SRC="$(cd "$TARGET" && pwd)"
else
  SRC="$REPO/scratchpad/$TARGET"
fi
[ -d "$SRC" ] || { echo "error: no such feature dir: $TARGET" >&2; exit 1; }

PROGRESS="$SRC/PROGRESS.md"
[ -f "$PROGRESS" ] || { echo "error: $PROGRESS missing; refusing to archive" >&2; exit 1; }

# Closeout gate: require a Graduated-to value that is not the placeholder.
if ! grep -qE '^\s*-\s*\*\*Graduated to:\*\*\s*\S' "$PROGRESS"; then
  echo "error: Closeout incomplete in $PROGRESS (no 'Graduated to:' value). Refusing to archive." >&2
  exit 1
fi
if grep -qE '^\s*-\s*\*\*Graduated to:\*\*\s*<' "$PROGRESS"; then
  echo "error: Closeout 'Graduated to:' still holds the template placeholder. Refusing to archive." >&2
  exit 1
fi

ARCHIVE_DIR="$REPO/scratchpad/archive"
mkdir -p "$ARCHIVE_DIR"
STAMP="$(date +%Y-%m-%d)"
BASE="$(basename "$SRC")"
DEST="$ARCHIVE_DIR/${STAMP}-${BASE}"
if [ -e "$DEST" ]; then
  echo "error: $DEST already exists" >&2
  exit 1
fi

mv "$SRC" "$DEST"
echo "archived: $DEST"
