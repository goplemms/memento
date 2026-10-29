#!/bin/bash
# Tests for bin/ideas-ledger.sh and archive-feature.sh's Closeout gates.
# Run: bash bin/tests/ideas-ledger.test.sh
# Uses temp dirs for the shared folder and a repo, so it touches nothing real.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAIL=0
ok()   { echo "ok   $1"; }
fail() { echo "FAIL $1"; FAIL=1; }
LEDGER() { env -u MEMENTO_IDEAS_LEDGER -u CLAUDE_PLUGIN_ROOT "$@" bash "$ROOT/bin/ideas-ledger.sh"; }

# Shared project folder present: one ledger for the project, made from the template.
mkdir -p "$T/shared"
OUT="$(cd "$ROOT" && LEDGER MEMENTO_PROJECT_FILES="$T/shared")"
[ "$OUT" = "$T/shared/memento/ideas.md" ] && ok "shared folder path" || fail "shared folder path: $OUT"
cmp -s "$OUT" "$ROOT/templates/ideas.md" && ok "created from template" || fail "created from template"

# An existing ledger is never overwritten.
echo "| x | kept |" >> "$OUT"
(cd "$ROOT" && LEDGER MEMENTO_PROJECT_FILES="$T/shared") >/dev/null
grep -q "kept" "$OUT" && ok "existing ledger kept" || fail "existing ledger overwritten"

# Works from outside any repo when the shared folder exists (project threads
# start above the repo clones).
OUT="$(cd "$T" && LEDGER MEMENTO_PROJECT_FILES="$T/shared")"
[ "$OUT" = "$T/shared/memento/ideas.md" ] && ok "shared folder outside a repo" || fail "outside a repo: $OUT"

# No shared folder: the repo's scratchpad.
git init -q "$T/repo"
OUT="$(cd "$T/repo" && LEDGER MEMENTO_PROJECT_FILES="$T/missing")"
[ "$OUT" = "$T/repo/scratchpad/ideas.md" ] && [ -f "$OUT" ] && ok "scratchpad fallback" || fail "scratchpad fallback: $OUT"

# Override wins over both.
OUT="$(cd "$T/repo" && LEDGER MEMENTO_PROJECT_FILES="$T/shared" MEMENTO_IDEAS_LEDGER="$T/o/ideas.md")"
[ "$OUT" = "$T/o/ideas.md" ] && [ -f "$OUT" ] && ok "override" || fail "override: $OUT"

# A CLAUDE_PLUGIN_ROOT naming another build doesn't matter: the template comes
# from the script's own kit.
OUT="$(cd "$T/repo" && env -u MEMENTO_IDEAS_LEDGER CLAUDE_PLUGIN_ROOT="$T/bogus" \
  MEMENTO_PROJECT_FILES="$T/missing" MEMENTO_IDEAS_LEDGER="$T/p/ideas.md" bash "$ROOT/bin/ideas-ledger.sh")"
cmp -s "$OUT" "$ROOT/templates/ideas.md" && ok "ignores a stale CLAUDE_PLUGIN_ROOT" || fail "stale CLAUDE_PLUGIN_ROOT: $OUT"

# A shared folder that can't be written is not used (skipped as root, who can write anyway).
if [ "$(id -u)" != 0 ]; then
  mkdir -p "$T/ro"; chmod a-w "$T/ro"
  OUT="$(cd "$T/repo" && LEDGER MEMENTO_PROJECT_FILES="$T/ro")"
  [ "$OUT" = "$T/repo/scratchpad/ideas.md" ] && ok "unwritable shared folder skipped" || fail "unwritable shared folder: $OUT"
fi

# Neither a repo nor a shared folder: fail loud.
if (cd "$T" && LEDGER MEMENTO_PROJECT_FILES="$T/missing") >/dev/null 2>&1; then
  fail "no repo, no shared folder: should fail"
else
  ok "no repo, no shared folder: fails"
fi

# archive-feature.sh: Closeout must name the ledger rows (or say none: <why>).
WS="$T/ws"; mkdir -p "$WS"
closeout() {  # closeout <name> <ledger line or empty>
  mkdir -p "$WS/$1"
  sed '/^- \*\*Ledger:/d; s/^- \*\*Graduated to:\*\*.*/- **Graduated to:** commit body/' \
    "$ROOT/templates/workflow/PROGRESS.md" > "$WS/$1/PROGRESS.md"
  [ -n "$2" ] && echo "$2" >> "$WS/$1/PROGRESS.md"
  return 0
}
archive() { (cd "$ROOT" && env -u MEMENTO_PROJECT_FILES MEMENTO_WORKSPACE_ROOT="$WS/.." \
  bash "$ROOT/bin/archive-feature.sh" "$WS/$1") 2>&1; }

refuses() {  # refuses <name> <test label>: archive fails, names Ledger, leaves the dir
  local out
  if out="$(archive "$1")"; then fail "$2: should refuse"
  elif [[ "$out" != *"Ledger"* ]]; then fail "$2: refusal doesn't name Ledger: $out"
  elif [ ! -f "$WS/$1/PROGRESS.md" ]; then fail "$2: workspace moved despite refusal"
  else ok "$2"; fi
}
PLACEHOLDER="$(grep '^- \*\*Ledger:' "$ROOT/templates/workflow/PROGRESS.md")"

closeout no-ledger "";                              refuses no-ledger "archive refuses without Ledger"
closeout placeholder "$PLACEHOLDER";                refuses placeholder "archive refuses the template's Ledger placeholder"
closeout empty "- **Ledger:**   ";                  refuses empty "archive refuses an empty Ledger"
closeout crlf "$(printf -- '- **Ledger:** \r')";    refuses crlf "archive refuses an empty CRLF Ledger"
closeout bare-none "- **Ledger:** none";            refuses bare-none "archive refuses none without a reason"
closeout both "$PLACEHOLDER
- **Ledger:** 1029-0a";                             refuses both "archive refuses a placeholder left beside a value"
# A Ledger line outside Closeout doesn't count.
mkdir -p "$WS/outside"
sed '/^- \*\*Ledger:/d; s/^- \*\*Graduated to:\*\*.*/- **Graduated to:** commit body/; s/^## Queue$/## Queue\n\n- **Ledger:** 1029-0a/' \
  "$ROOT/templates/workflow/PROGRESS.md" > "$WS/outside/PROGRESS.md"
grep -q '^- \*\*Ledger:\*\* 1029-0a' "$WS/outside/PROGRESS.md" || fail "fixture: Ledger line not in Queue"
refuses outside "archive ignores a Ledger line outside Closeout"
closeout filled "- **Ledger:** 1029-0a, 1029-7a"
archive filled >/dev/null && [ ! -d "$WS/filled" ] && ok "archive accepts named rows" || fail "archive with named rows"
closeout none "- **Ledger:** none: docs typo, nothing to watch"
archive none >/dev/null && ok "archive accepts none: <why>" || fail "archive with none: <why>"

# The template's Closeout, land and the ledger template agree on the names.
grep -q '^- \*\*Ledger:\*\*' "$ROOT/templates/workflow/PROGRESS.md" \
  && grep -q 'bin/ideas-ledger.sh' "$ROOT/skills/land/SKILL.md" \
  && grep -q '\*\*Ledger\*\*' "$ROOT/skills/land/SKILL.md" \
  && grep -q 'Did it fire?' "$ROOT/skills/land/SKILL.md" \
  && grep -q '| Did it fire? |' "$ROOT/templates/ideas.md" \
  && ok "Ledger wiring: template, land, ledger agree" || fail "Ledger wiring"

exit $FAIL
