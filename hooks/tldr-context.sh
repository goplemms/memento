#!/bin/bash
# Keep the TL;DR convention in context, cheaply.
#
# Invoked two ways from hooks/hooks.json:
#
#   tldr-context.sh session   SessionStart (startup|resume|clear|compact)
#                             Always emits. This is the FLOOR: every session
#                             gets the convention once, and compaction re-arms
#                             it at exactly the moment the old copy is dropped.
#
#   tldr-context.sh sample    UserPromptSubmit, emitted for ~3 turns in 16.
#                             This is the REFRESH: it pulls the convention back
#                             down next to the decision points that arrive deep
#                             in a long session, where the session-start copy
#                             has scrolled far up-context.
#
# The sampling is stateless on purpose. prompt_id is a per-prompt UUID, so its
# last hex digit is uniform — no counter file to clean up, no transcript parsing
# against an undocumented format, and no dependence on wall-clock time (which
# would correlate with how FAST you type rather than how far into the session
# you are, and could miss a short session entirely).
#
# Injected context is retained per turn rather than replaced, so an unsampled
# per-turn hook costs ~235 tokens EVERY turn, accumulating (~24k by turn 100).
# Floor + 19% sampling costs ~235 per session plus ~45/turn amortized.
#
# Single source of truth: the text is extracted from the marked range in
# docs/tldr-convention.md, so there is no second copy to drift.
#
# Never fails the turn (always exits 0); on any error it emits nothing, which
# Claude Code treats as a no-op.
set -uo pipefail

MODE="${1:-session}"

case "$MODE" in
  session)
    EVENT="SessionStart"
    ;;
  sample)
    EVENT="UserPromptSubmit"
    STDIN="$(cat)" || exit 0
    PROMPT_ID="$(printf '%s' "$STDIN" | tr ',' '\n' | grep '"prompt_id"' | head -1 \
                 | sed -e 's/.*"prompt_id"[[:space:]]*:[[:space:]]*"//' -e 's/".*//')"
    # Unparseable id: skip rather than inject. SessionStart is the floor, so
    # the convention is still present; failing open here would silently restore
    # the every-turn cost this sampling exists to avoid.
    [ -n "$PROMPT_ID" ] || exit 0
    case "${PROMPT_ID: -1}" in
      0|1|2) ;;      # ~19% of turns
      *)     exit 0 ;;
    esac
    ;;
  *)
    exit 0
    ;;
esac

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

printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' \
  "$EVENT" "$ESCAPED"

exit 0
