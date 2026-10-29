#!/usr/bin/env bash
# archive-feature.sh <dir>
# Date-prefixed move of a finished feature workspace to <workspace root>/archive/
# (see workspace-root.sh).
# REFUSES to archive unless PROGRESS.md has a completed Closeout section
# (Graduated to and Issues).
set -euo pipefail

usage() { echo "usage: archive-feature.sh <dir>" >&2; exit 2; }
[ $# -eq 1 ] || usage
TARGET="$1"

if ! REPO="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "error: not inside a git repository (cwd: $PWD)" >&2
  exit 1
fi

ROOT="$("$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/workspace-root.sh")"

# Accept either a path or a name under the workspace root.
if [ -d "$TARGET" ]; then
  SRC="$(cd "$TARGET" && pwd)"
else
  SRC="$ROOT/$TARGET"
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

# Issues gate: land must have filed leftovers as idea issues and marked the
# feature's issue for the "did it fire?" check (docs/ideas.md), and named
# them, or said why none. Only the Closeout section counts. Every Issues line
# there must name an issue (#N, owner/repo#N, or an issue URL) or be
# "none: <reason>".
ISSUES_STATE="$(tr -d '\r' < "$PROGRESS" | awk '
  /^## / { in_c = ($0 ~ /^## Closeout/) }
  in_c && /^[[:space:]]*-[[:space:]]*\*\*Issues:\*\*/ {
    v = $0; sub(/^[^:]*:\*\*[[:space:]]*/, "", v)
    if (v ~ /</) bad = 1   # a template placeholder, or part of one, is still there
    else if (v ~ /(^|[^[:alnum:]_])([[:alnum:]_.-]+\/[[:alnum:]_.-]+)?#[1-9][0-9]*/ \
          || v ~ /https:\/\/github\.com\/[^\/ ]+\/[^\/ ]+\/issues\/[1-9][0-9]*/ \
          || v ~ /^[Nn]one[[:space:]]*:[[:space:]]*[^[:space:]]/) good = 1
    else bad = 1
  }
  END { print (bad || !good) ? "bad" : "ok" }')"
if [ "$ISSUES_STATE" != ok ]; then
  echo "error: Closeout 'Issues:' in $PROGRESS is missing, the template placeholder, or names no issue. File the feature's leftovers as idea issues and mark its own issue fire:watching (see memento:land and docs/ideas.md), then name them on a '- **Issues:**' line under Closeout, such as '#41, #42' (add the line by hand in a workspace made before it existed), or write 'none: <why>'. Refusing to archive." >&2
  exit 1
fi

ARCHIVE_DIR="$ROOT/archive"
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
