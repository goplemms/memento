#!/usr/bin/env bash
# sweep-archive.sh [--older-than DAYS] [--delete]
# Garbage-collect archived feature dirs past their TTL and flag stale ACTIVE
# dirs. Dry-run by default. ACTIVE (non-archive) dirs are NEVER auto-deleted.
set -euo pipefail

DAYS=15
DELETE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --older-than) shift; [ $# -ge 1 ] || { echo "--older-than needs a value" >&2; exit 2; }; DAYS="$1" ;;
    --delete)     DELETE=1 ;;
    *)            echo "unknown flag: $1" >&2; exit 2 ;;
  esac
  shift
done
case "$DAYS" in (*[!0-9]*|'') echo "error: --older-than must be an integer" >&2; exit 2 ;; esac

if ! REPO="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "error: not inside a git repository (cwd: $PWD)" >&2
  exit 1
fi

SCRATCH="$REPO/scratchpad"
ARCHIVE_DIR="$SCRATCH/archive"
NOW="$(date +%s)"
CUTOFF=$(( DAYS * 86400 ))

echo "sweep: repo=$REPO ttl=${DAYS}d mode=$([ "$DELETE" -eq 1 ] && echo DELETE || echo dry-run)"

# 1. Archived dirs past TTL (by mtime).
if [ -d "$ARCHIVE_DIR" ]; then
  shopt -s nullglob
  for d in "$ARCHIVE_DIR"/*/; do
    d="${d%/}"
    mtime="$(date -r "$d" +%s)"
    age=$(( NOW - mtime ))
    if [ "$age" -gt "$CUTOFF" ]; then
      age_d=$(( age / 86400 ))
      if [ "$DELETE" -eq 1 ]; then
        rm -rf "$d"
        echo "deleted (archived, ${age_d}d): $d"
      else
        echo "would delete (archived, ${age_d}d): $d"
      fi
    fi
  done
  shopt -u nullglob
fi

# 2. Flag stale ACTIVE dirs — report only, never delete.
shopt -s nullglob
for d in "$SCRATCH"/*/; do
  d="${d%/}"
  [ "$d" = "$ARCHIVE_DIR" ] && continue
  mtime="$(date -r "$d" +%s)"
  age=$(( NOW - mtime ))
  if [ "$age" -gt "$CUTOFF" ]; then
    age_d=$(( age / 86400 ))
    echo "stale ACTIVE (${age_d}d, not deleted): $d"
  fi
done
shopt -u nullglob
