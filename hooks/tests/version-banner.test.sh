#!/bin/bash
# Tests for hooks/version-banner.sh. Run: bash hooks/tests/version-banner.test.sh
# Builds a fake plugin install, a "remote" memento repo and skills folders in a
# temp dir, so it needs no network and touches nothing real.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$HERE/../version-banner.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAIL=0

check() {  # check <name> <output> <expected substring> [absent substring]
  if [[ "$2" != *"$3"* ]]; then echo "FAIL $1: missing '$3' in: $2"; FAIL=1; return; fi
  if [ -n "${4:-}" ] && [[ "$2" == *"$4"* ]]; then echo "FAIL $1: unexpected '$4' in: $2"; FAIL=1; return; fi
  printf '%s' "$2" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null \
    || { echo "FAIL $1: not valid JSON: $2"; FAIL=1; return; }
  echo "ok   $1"
}

# A "remote" memento repo with two commits; main is the second.
G=(git -C "$T/remote" -c user.email=t@t -c user.name=t)
git init -q -b main "$T/remote"
"${G[@]}" commit -q --allow-empty -m one
OLD="$("${G[@]}" rev-parse HEAD)"
"${G[@]}" commit -q --allow-empty -m two
NEW="$("${G[@]}" rev-parse HEAD)"

# An installed copy: ~/.claude/plugins/cache/memento/memento/<sha12>/ holding the hook.
install() {  # install <sha> -> prints plugin root
  local root="$T/home/.claude/plugins/cache/memento/memento/${1:0:12}"
  mkdir -p "$root/hooks"
  cp "$HOOK" "$root/hooks/"
  for s in orchestrate implement land ship; do
    mkdir -p "$root/skills/$s"; printf -- '---\nname: %s\n---\n\n# Kit %s\n' "$s" "$s" > "$root/skills/$s/SKILL.md"
  done
  printf '%s' "$root"
}

run() {  # run <plugin root> [VAR=value...]
  local root="$1"; shift
  env -i PATH="$PATH" HOME="$T/home" CLAUDE_PROJECT_DIR="$T/project" \
      CLAUDE_PLUGIN_DATA="$T/data" MEMENTO_REMOTE="$T/remote" "$@" \
      bash "$root/hooks/version-banner.sh" </dev/null
}

mkdir -p "$T/project"
OLD_ROOT="$(install "$OLD")"
NEW_ROOT="$(install "$NEW")"

check "current install: no warning" "$(run "$NEW_ROOT")" "memento ${NEW:0:7}" "behind main"
rm -rf "$T/data"
check "old install: behind main" "$(run "$OLD_ROOT")" \
  "behind main (${NEW:0:7}): run claude plugin update memento@memento"
check "tip is cached" "$(run "$OLD_ROOT" MEMENTO_REMOTE="$T/nowhere")" "behind main (${NEW:0:7})"
# The cache says OLD is main, but main moved on and the install was updated.
printf '%s %s\n' "${OLD:0:12}" "$OLD" > "$T/data/main-tip"
check "stale cache doesn't flag a fresh install" "$(run "$NEW_ROOT")" "memento ${NEW:0:7}" "behind main"
rm -rf "$T/data"
check "offline: no warning, still a banner" "$(run "$OLD_ROOT" MEMENTO_REMOTE="$T/nowhere")" \
  "memento ${OLD:0:7}" "behind main"

# Old copies: user-scope links into an old memento checkout, like John's.
mkdir -p "$T/old-memento/skills/land" "$T/old-memento/skills/repo-exploration" "$T/home/.claude/skills"
ln -s "$T/old-memento/skills/land" "$T/home/.claude/skills/land"
ln -s "$T/old-memento/skills/repo-exploration" "$T/home/.claude/skills/repo-exploration"
ln -s "$T/gone/memento/skills/implement" "$T/home/.claude/skills/implement"   # dangling
mkdir -p "$T/home/.claude/skills/orchestrate"
echo "an unrelated skill" > "$T/home/.claude/skills/orchestrate/SKILL.md"
check "user-scope old copies named, unrelated one not" "$(run "$NEW_ROOT")" \
  "old copies of kit skills in ~/.claude/skills: implement, land, repo-exploration" "land, orchestrate"

# Project-scope vendored copy of the kit's SKILL.md.
mkdir -p "$T/project/.claude/skills/ship"
cp "$NEW_ROOT/skills/ship/SKILL.md" "$T/project/.claude/skills/ship/"
check "project-scope copy named" "$(run "$NEW_ROOT")" \
  "old copies of kit skills in $T/project/.claude/skills: ship"

# Project dir is the home dir: the same folder is not reported twice.
OUT="$(run "$NEW_ROOT" CLAUDE_PROJECT_DIR="$T/home")"
N="$(printf '%s' "$OUT" | grep -o 'old copies' | wc -l)"
[ "$N" -eq 2 ] && echo "ok   home as project: reported once" \
  || { echo "FAIL home as project: reported $N/2 times: $OUT"; FAIL=1; }

# A project whose path says memento, with its own unrelated "ship" skill.
mkdir -p "$T/code/memento-app/.claude/skills/ship"
printf '# Ship our app\nPrefer this over memento:ship.\n' > "$T/code/memento-app/.claude/skills/ship/SKILL.md"
check "unrelated skill under a memento-named path not flagged" \
  "$(run "$NEW_ROOT" CLAUDE_PROJECT_DIR="$T/code/memento-app")" "memento ${NEW:0:7}" "memento-app/.claude/skills: ship"

# A sibling of HOME that starts with the same letters isn't shortened to ~.
mkdir -p "$T/homer/.claude/skills"; cp -r "$T/project/.claude/skills/ship" "$T/homer/.claude/skills/"
check "no false ~ for a HOME-prefixed sibling" "$(run "$NEW_ROOT" CLAUDE_PROJECT_DIR="$T/homer")" \
  "in $T/homer/.claude/skills: ship"

# Control characters in a path don't break the JSON.
TAB="$T/tab$(printf '\t')dir"; mkdir -p "$TAB/.claude/skills/ship"; cp "$NEW_ROOT/skills/ship/SKILL.md" "$TAB/.claude/skills/ship/"
check "tab in path, valid JSON" "$(run "$NEW_ROOT" CLAUDE_PROJECT_DIR="$TAB")" "ship"

# No timeout command on PATH (stock macOS): the check still runs.
rm -rf "$T/data"; mkdir -p "$T/bin"
for c in bash git env mktemp cut head find mkdir rm sleep kill readlink grep tr ls basename dirname cat printf; do
  p="$(command -v "$c")" && ln -sf "$p" "$T/bin/$c"
done
check "works without a timeout command" "$(run "$OLD_ROOT" PATH="$T/bin")" "behind main (${NEW:0:7})"

exit $FAIL
