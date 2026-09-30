#!/bin/bash
# Show which memento build this session loaded, once, at session start.
#
#   memento d5dc136 · committed 2026-09-30
#
# plugin.json carries no "version", so Claude Code installs memento under a
# directory named after the commit it installed from:
#
#   ~/.claude/plugins/cache/<marketplace>/memento/<12-char sha>/
#
# That directory has no .git, so the commit DATE comes from the marketplace
# clone next to it (~/.claude/plugins/marketplaces/<marketplace>/). The clone is
# shallow and can auto-update past the installed commit; when it no longer has
# that commit, fall back to the install date recorded in installed_plugins.json.
# A local checkout loaded with --plugin-dir is its own git repo and reports
# HEAD directly.
#
# Emits the line twice: systemMessage for the person, additionalContext so
# Claude can answer "which memento version is this?" without running anything.
#
# Never fails the session (always exits 0); on any error it emits nothing.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 0

SHA=""
DATE=""
DATE_KIND="committed"

if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
   && [ "$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null)" = "$ROOT" ]; then
  # Local checkout.
  SHA="$(git -C "$ROOT" rev-parse --short=7 HEAD 2>/dev/null)"
  DATE="$(git -C "$ROOT" show -s --format=%cs HEAD 2>/dev/null)"
  git -C "$ROOT" diff --quiet HEAD 2>/dev/null || SHA="$SHA+dirty"
else
  # Installed copy: the directory name is the commit.
  DIR="$(basename "$ROOT")"
  case "$DIR" in
    *[!0-9a-f]*|"") exit 0 ;;   # not a sha-named install (e.g. a pinned version)
  esac
  SHA="${DIR:0:7}"
  MARKETPLACE="$(basename "$(dirname "$(dirname "$ROOT")")")"
  PLUGINS="$(dirname "$(dirname "$(dirname "$(dirname "$ROOT")")")")"
  CLONE="$PLUGINS/marketplaces/$MARKETPLACE"
  DATE="$(git -C "$CLONE" show -s --format=%cs "$DIR" 2>/dev/null)"
  if [ -z "$DATE" ] && [ -r "$PLUGINS/installed_plugins.json" ]; then
    DATE="$(grep -A6 "\"installPath\": *\"$ROOT\"" "$PLUGINS/installed_plugins.json" \
            | grep -m1 '"installedAt"' | sed -e 's/.*"installedAt": *"//' -e 's/T.*//')"
    DATE_KIND="installed"
  fi
fi

[ -n "$SHA" ] || exit 0
LINE="memento $SHA"
[ -n "$DATE" ] && LINE="$LINE · $DATE_KIND $DATE"

printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Loaded plugin build: %s"}}\n' \
  "$LINE" "$LINE"

exit 0
