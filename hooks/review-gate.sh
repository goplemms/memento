#!/bin/bash
# Stop a milestone commit that no review has looked at.
#
# The kit's review steps (implement's code-and-tests review, orchestrate's
# commit-gate challenge) used to live only in skill prose, and sessions skipped
# them, especially late in a long run. A repo rule that a hook enforces ran
# every time. This hook is that enforcement for the kit.
#
# Runs as a PreToolUse hook on Bash. When the command is a `git commit` and the
# repo has an active feature workspace, it reads PROGRESS.md:
#   - the active milestone is the first word of "Milestone:" in the Current
#     block (e.g. M2)
#   - the gate applies only while that milestone's Status row says
#     in-progress or testable, and only when PROGRESS.md has a
#     "## Review ledger" section (older workspaces are left alone)
#   - it passes when the ledger has a row for that milestone, including a
#     "skipped: <why>" row for a trivial change
# Otherwise it denies the commit with a reason saying what to do.
#
# Never fails the session: any parsing problem means "allow" (exit 0, no
# output).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 0
INPUT="$(cat)" || exit 0

field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$INPUT" | python3 -c '
import json, sys
d = json.load(sys.stdin)
for k in sys.argv[1].lstrip(".").split("."):
    d = d.get(k) if isinstance(d, dict) else None
print(d if isinstance(d, str) else "")' "$1" 2>/dev/null
  fi
}

CMD="$(field .tool_input.command)"
[ -n "$CMD" ] || exit 0
printf '%s' "$CMD" \
  | grep -Eq '(^|[;&|(`[:space:]])git([[:space:]]+-[cC][[:space:]]+[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)' \
  || exit 0

CWD="$(field .cwd)"
[ -n "$CWD" ] && [ -d "$CWD" ] && cd "$CWD" 2>/dev/null
WS="$("$ROOT/bin/workspace-root.sh" 2>/dev/null)" || exit 0
[ -d "$WS" ] || exit 0

FILES="$(find "$WS" -mindepth 2 -maxdepth 2 -name PROGRESS.md \
           -not -path '*/archive/*' -mtime -14 2>/dev/null)"
[ -n "$FILES" ] || exit 0

MISSING=""
while IFS= read -r f; do
  grep -q '^## Review ledger' "$f" || continue
  ID="$(sed -n '/^## Current block/,/^## /p' "$f" \
        | sed -n 's/^- \*\*Milestone:\*\*[[:space:]]*//p' | head -1 \
        | awk '{print $1}')"
  case "$ID" in ''|'<'*) continue ;; esac
  STATE="$(sed -n '/^## Status/,/^## /p' "$f" \
           | awk -F'|' -v id="$ID" '{ m=$2; gsub(/^[ \t]+/, "", m); split(m, w, /[ \t]/)
                                    if (w[1] == id) { s=$3; gsub(/[ \t]/, "", s); print s; exit } }')"
  case "$STATE" in in-progress|testable) ;; *) continue ;; esac
  ROW="$(sed -n '/^## Review ledger/,/^## /p' "$f" \
         | awk -F'|' -v id="$ID" '{ m=$2; gsub(/^[ \t]+/, "", m); split(m, w, /[ \t]/)
                                  if (w[1] == id) { print; exit } }')"
  [ -n "$ROW" ] && continue
  MISSING="$MISSING $ID ($f)"
done <<< "$FILES"

[ -n "$MISSING" ] || exit 0

REASON="memento review gate: no review is recorded for the active milestone:$MISSING.
Before committing, review the milestone (memento:implement's code-and-tests
review, then memento:orchestrate's commit-gate challenge), and add a row to
PROGRESS.md's Review ledger: what reviewed it, what it found, what was folded
in. For a trivial change (docs, config, a rename with green tests), add the row
with 'skipped: <why>' instead. Then retry the commit."

ESCAPED="$(printf '%s' "$REASON" \
           | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/ /g' \
           | awk '{ printf "%s\\n", $0 }')" || exit 0

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' \
  "$ESCAPED"
exit 0
