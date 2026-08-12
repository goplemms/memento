#!/bin/bash
# UserPromptSubmit hook: keep the TL;DR convention in context every turn.
#
# The convention has to fire at decision points that arrive deep in long
# sessions — which is exactly where a SessionStart injection has decayed and a
# skill-scoped instruction was never loaded at all. Re-injecting per turn keeps
# it adjacent to the moment it applies, and survives compaction for free.
#
# Single source of truth: the text is extracted from the marked range in
# docs/tldr-convention.md, so there is no second copy to drift.
#
# Never fails the turn (always exits 0); on any error it emits nothing, which
# Claude Code treats as a no-op.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 0
DOC="$ROOT/docs/tldr-convention.md"
[ -r "$DOC" ] || exit 0

# Pull the operative short form out of the doc, dropping the marker lines.
BODY="$(sed -n '/<!-- inject:start -->/,/<!-- inject:end -->/p' "$DOC" \
        | sed '1d;$d')" || exit 0
[ -n "$BODY" ] || exit 0

# Escape for embedding as a JSON string: backslashes, then quotes, then fold
# every newline into a literal \n. The source is plain markdown (no tabs or
# control characters), so these three are sufficient.
ESCAPED="$(printf '%s' "$BODY" \
           | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
           | awk '{ printf "%s\\n", $0 }')" || exit 0

printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' \
  "$ESCAPED"

exit 0
