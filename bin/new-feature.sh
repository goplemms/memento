#!/usr/bin/env bash
# new-feature.sh <name> [--with-agents] [--with-decisions]
# Scaffold a feature workspace from the kit's workflow templates.
# Resolves the consuming repo via `git rev-parse --show-toplevel`, so one copy
# works from any repo's cwd.
set -euo pipefail

usage() {
  echo "usage: new-feature.sh <name> [--with-agents] [--with-decisions]" >&2
  exit 2
}

[ $# -ge 1 ] || usage
NAME=""
WITH_AGENTS=0
WITH_DECISIONS=0
for arg in "$@"; do
  case "$arg" in
    --with-agents)    WITH_AGENTS=1 ;;
    --with-decisions) WITH_DECISIONS=1 ;;
    --*)              echo "unknown flag: $arg" >&2; usage ;;
    *)
      if [ -z "$NAME" ]; then NAME="$arg"; else echo "unexpected arg: $arg" >&2; usage; fi
      ;;
  esac
done
[ -n "$NAME" ] || usage

# Fail loud if not inside a git repo.
if ! REPO="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "error: not inside a git repository (cwd: $PWD)" >&2
  exit 1
fi

# Templates ship with the kit. Resolve the kit root two ways:
#   - As a plugin, Claude Code exports CLAUDE_PLUGIN_ROOT (the plugin dir).
#   - Otherwise (direct run from a clone), fall back to this script's real path.
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  KIT_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  SCRIPT_REAL="$(readlink -f "${BASH_SOURCE[0]}")"
  KIT_ROOT="$(cd "$(dirname "$SCRIPT_REAL")/.." && pwd)"
fi
TPL="$KIT_ROOT/templates/workflow"
[ -d "$TPL" ] || { echo "error: templates not found at $TPL" >&2; exit 1; }

DEST="$REPO/scratchpad/$NAME"
if [ -e "$DEST" ]; then
  echo "error: $DEST already exists" >&2
  exit 1
fi
mkdir -p "$DEST"

subst() { sed "s/<FEATURE_NAME>/$NAME/g" "$1" > "$2"; }

subst "$TPL/plan.md"     "$DEST/plan.md"
subst "$TPL/PROGRESS.md" "$DEST/PROGRESS.md"
[ "$WITH_DECISIONS" -eq 1 ] && subst "$TPL/decisions.md" "$DEST/decisions.md"
[ "$WITH_AGENTS"    -eq 1 ] && subst "$TPL/agents.md"    "$DEST/agents.md"

echo "scaffolded: $DEST"
ls -1 "$DEST"
