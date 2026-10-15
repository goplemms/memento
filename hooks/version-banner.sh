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
# An installed copy is also checked against main's tip, so a stale install
# (an old setup-script cache, a plugin that never updated) says so:
#
#   memento 347b6da · committed 2026-10-05 · behind main (9f1c2ab): run claude plugin update memento@memento
#
# The tip comes from `git ls-remote` with a 3-second timeout and is cached for
# 12 hours; offline, or with no git, the check is skipped.
# A local checkout is left alone: whoever runs one controls what it's on.
#
# A folder or link in ~/.claude/skills or the project's .claude/skills that has
# a kit skill's name and comes from memento (a link into a memento checkout, or
# a copy of the kit's SKILL.md) is named too. Those are old copies from the pre-plugin install, and
# they answer to the bare name, e.g. /orchestrate:
#
#   memento ... · old copies of kit skills in ~/.claude/skills: implement, land
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

# --- Stale check (installed copies only) ------------------------------------
# Where the install came from: the marketplace clone's origin when there is one.
REMOTE="${MEMENTO_REMOTE:-$(git -C "${CLONE:-/nonexistent}" remote get-url origin 2>/dev/null)}"
REMOTE="${REMOTE:-https://github.com/goplemms/memento}"

# with_timeout <secs> <cmd...>: bash-only, so it works on a stock Mac too.
with_timeout() {
  local secs="$1"; shift
  "$@" & local pid=$!
  ( sleep "$secs"; kill "$pid" ) >/dev/null 2>&1 & local killer=$!
  wait "$pid" 2>/dev/null; local rc=$?
  kill "$killer" >/dev/null 2>&1
  return $rc
}

# The cache holds "<install dir> <main sha>" and is trusted for 12 hours, and
# only by the install that wrote it, so updating the plugin re-checks at once.
main_tip() {
  local cache_dir cache tmp tip
  cache_dir="${CLAUDE_PLUGIN_DATA:-${HOME:-/tmp}/.cache/memento}"
  cache="$cache_dir/main-tip"
  if [ -f "$cache" ] && [ -n "$(find "$cache" -mmin -720 2>/dev/null)" ]; then
    set -- $(head -c 200 "$cache" 2>/dev/null)
    [ "${1:-}" = "$DIR" ] && { printf '%s' "${2:-}"; return 0; }
  fi
  tmp="$(mktemp 2>/dev/null)" || return 0
  GIT_TERMINAL_PROMPT=0 with_timeout 3 git ls-remote "$REMOTE" refs/heads/main >"$tmp" 2>/dev/null
  tip="$(cut -c1-40 "$tmp" 2>/dev/null | head -1)"; rm -f "$tmp"
  case "$tip" in *[!0-9a-f]*|"") return 0 ;; esac
  mkdir -p "$cache_dir" 2>/dev/null && printf '%s %s\n' "$DIR" "$tip" > "$cache" 2>/dev/null
  printf '%s' "$tip"
}

if [ -n "${DIR:-}" ]; then
  TIP="$(main_tip)"
  if [ -n "$TIP" ] && [ "${TIP:0:${#DIR}}" != "$DIR" ]; then
    LINE="$LINE · behind main (${TIP:0:7}): run claude plugin update memento@${MARKETPLACE:-memento}"
  fi
fi

# --- Old copies of kit skills -------------------------------------------------
# Current kit skills plus names retired since the pre-plugin install.
KIT_NAMES="$(ls "$ROOT/skills" 2>/dev/null) repo-exploration curious-builder decision-adversary backlog-reviewer"
USER_SKILLS="${HOME:-/nonexistent}/.claude/skills"
PROJECT_SKILLS="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/skills"
[ "$PROJECT_SKILLS" -ef "$USER_SKILLS" ] && PROJECT_SKILLS=""   # one folder, report it once
for SKILLS_DIR in "$USER_SKILLS" "$PROJECT_SKILLS"; do
  [ -n "$SKILLS_DIR" ] && [ -d "$SKILLS_DIR" ] || continue
  FOUND=""
  for NAME in $KIT_NAMES; do
    [ -e "$SKILLS_DIR/$NAME" ] || [ -L "$SKILLS_DIR/$NAME" ] || continue
    # Only memento's own copies; a project's unrelated "ship" skill is its
    # business. A link counts when it points into a memento checkout; a plain
    # folder when its SKILL.md opens with the same title as the kit's.
    if [ -L "$SKILLS_DIR/$NAME" ]; then
      case "$(readlink "$SKILLS_DIR/$NAME" 2>/dev/null)" in
        *memento*/skills/"$NAME"|*memento*/skills/"$NAME"/) ;;
        *) continue ;;
      esac
    else
      KIT_TITLE="$(grep -m1 '^# ' "$ROOT/skills/$NAME/SKILL.md" 2>/dev/null)"
      [ -n "$KIT_TITLE" ] || continue
      [ "$(grep -m1 '^# ' "$SKILLS_DIR/$NAME/SKILL.md" 2>/dev/null)" = "$KIT_TITLE" ] || continue
    fi
    FOUND="${FOUND:+$FOUND, }$NAME"
  done
  [ -n "$FOUND" ] || continue
  SHOWN="$SKILLS_DIR"
  case "$SKILLS_DIR" in "${HOME:-/nonexistent}"/*) SHOWN="~${SKILLS_DIR#"$HOME"}" ;; esac
  LINE="$LINE · old copies of kit skills in $SHOWN: $FOUND"
done

CONTEXT="Loaded plugin build: $LINE"
case "$LINE" in *"behind main"*)
  CONTEXT="$CONTEXT. In a cloud session memento comes from the environment setup script; editing its date line refreshes it." ;;
esac
case "$LINE" in *"old copies"*)
  CONTEXT="$CONTEXT. Those copies answer to bare names like /orchestrate with stale instructions; prefer the memento: skills and suggest deleting the copies." ;;
esac
LINE="$(printf '%s' "$LINE" | tr -d '"\\\000-\037')"   # keep the JSON below valid
CONTEXT="$(printf '%s' "$CONTEXT" | tr -d '"\\\000-\037')"
printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
  "$LINE" "$CONTEXT"

exit 0
