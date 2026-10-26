#!/bin/bash
# Tests for hooks/tldr-context.sh and hooks/progress-context.sh.
# Run: bash hooks/tests/context-hooks.test.sh
# Builds fake workspaces in a temp dir, so it touches nothing real.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/../.."
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAIL=0

check() {  # check <name> <output> <expected substring> [absent substring]
  if [[ "$2" != *"$3"* ]]; then echo "FAIL $1: missing '$3' in: $2"; FAIL=1; return; fi
  if [ -n "${4:-}" ] && [[ "$2" == *"$4"* ]]; then echo "FAIL $1: unexpected '$4' in: $2"; FAIL=1; return; fi
  printf '%s' "$2" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null \
    || { echo "FAIL $1: not valid JSON: $2"; FAIL=1; return; }
  echo "ok   $1"
}

SESSION="$(bash "$ROOT/hooks/tldr-context.sh" session </dev/null)"
check "session: TL;DR rule" "$SESSION" "TL;DR convention"
check "session: queue rule" "$SESSION" "Corrections queue" "inject:start"

# A prompt_id ending in 0 is sampled; one ending in f is not.
SAMPLED="$(printf '{"prompt_id":"abc0"}' | bash "$ROOT/hooks/tldr-context.sh" sample)"
check "sampled turn: queue rule" "$SAMPLED" "Corrections queue"
for d in 3 f; do
  OUT="$(printf '{"prompt_id":"abc%s"}' "$d" | bash "$ROOT/hooks/tldr-context.sh" sample)"
  [ -z "$OUT" ] && echo "ok   unsampled turn ($d): silent" || { echo "FAIL unsampled turn ($d): $OUT"; FAIL=1; }
done

# Without working-rules.md the TL;DR rule still goes out.
K="$T/kit"; mkdir -p "$K/hooks" "$K/docs"
cp "$ROOT/hooks/tldr-context.sh" "$K/hooks/"; cp "$ROOT/docs/tldr-convention.md" "$K/docs/"
check "no working rules: TL;DR alone" "$(bash "$K/hooks/tldr-context.sh" session)" "TL;DR convention" "Corrections queue"

# progress-context.sh outside a repo reads $MEMENTO_PROJECT_FILES/memento/*/*/.
progress() { (cd "$T" && MEMENTO_PROJECT_FILES="$T/shared" bash "$ROOT/hooks/progress-context.sh"); }
WS="$T/shared/memento/repo/feat"; mkdir -p "$WS"
sed 's/<FEATURE_NAME>/feat/' "$ROOT/templates/workflow/PROGRESS.md" > "$WS/PROGRESS.md"
check "template queue: guidance not injected" "$(progress)" "Next step" "Queue (corrections"

python3 - "$WS/PROGRESS.md" <<'PY'
import sys; p=sys.argv[1]; s=open(p).read()
s=s.replace("## Review ledger", "- rename the flag\n- add a test for empty input\n\n## Review ledger")
open(p,"w").write(s)
PY
OUT="$(progress)"
check "queued items injected" "$OUT" 'Queue (corrections waiting, in order):\n- rename the flag\n- add a test for empty input'
check "ledger not leaked into queue" "$OUT" "Next step" "Reviewed by"

# Windows line endings must not put raw carriage returns into the JSON.
sed -i 's/$/\r/' "$WS/PROGRESS.md"
check "CRLF file: valid JSON" "$(progress)" "rename the flag"

# An emptied current block must not hide the queue.
printf '# Progress\n\n## Current block\n\n## Queue\n\n- only item\n\n## Review ledger\n' > "$WS/PROGRESS.md"
check "empty current block: queue still injected" "$(progress)" "only item"

exit $FAIL
