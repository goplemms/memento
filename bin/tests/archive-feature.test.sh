#!/bin/bash
# Tests for archive-feature.sh's Closeout gate on the Issues line.
# Run: bash bin/tests/archive-feature.test.sh
# Builds fake workspaces in a temp dir, so it touches nothing real.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAIL=0
ok()   { echo "ok   $1"; }
fail() { echo "FAIL $1"; FAIL=1; }

WS="$T/ws"; mkdir -p "$WS"
TPL="$ROOT/templates/workflow/PROGRESS.md"
closeout() {  # closeout <name> <Issues line(s), or empty>: a Closeout with Graduated to filled
  mkdir -p "$WS/$1"
  sed '/^- \*\*Issues:/d; s/^- \*\*Graduated to:\*\*.*/- **Graduated to:** commit body/' "$TPL" > "$WS/$1/PROGRESS.md"
  [ -n "$2" ] && echo "$2" >> "$WS/$1/PROGRESS.md"
  return 0
}
archive() { (cd "$ROOT" && env -u MEMENTO_PROJECT_FILES MEMENTO_WORKSPACE_ROOT="$WS/.." \
  bash "$ROOT/bin/archive-feature.sh" "$WS/$1") 2>&1; }
refuses() {  # refuses <name> <label>: archive fails, names Issues, leaves the dir in place
  local out
  if out="$(archive "$1")"; then fail "$2: should refuse"
  elif [[ "$out" != *"Issues"* ]]; then fail "$2: refusal doesn't name Issues: $out"
  elif [ ! -f "$WS/$1/PROGRESS.md" ]; then fail "$2: workspace moved despite refusal"
  else ok "$2"; fi
}
accepts() {  # accepts <name> <label>: archive succeeds and the dir is gone
  archive "$1" >/dev/null && [ ! -d "$WS/$1" ] && ok "$2" || fail "$2"
}
PLACEHOLDER="$(grep '^- \*\*Issues:' "$TPL")"

closeout no-line "";                             refuses no-line "refuses without an Issues line"
closeout placeholder "$PLACEHOLDER";             refuses placeholder "refuses the template's placeholder"
closeout empty "- **Issues:**   ";               refuses empty "refuses an empty value"
closeout crlf "$(printf -- '- **Issues:** \r')"; refuses crlf "refuses an empty CRLF value"
closeout bare-none "- **Issues:** none";         refuses bare-none "refuses none without a reason"
closeout no-number "- **Issues:** filed some";   refuses no-number "refuses a value naming no issue"
closeout both "$PLACEHOLDER
- **Issues:** #41";                              refuses both "refuses a placeholder left beside a value"
closeout hash-q "- **Issues:** pending #?";        refuses hash-q "refuses a # with no number"
closeout csharp "- **Issues:** C# port";          refuses csharp "refuses C# (no issue number)"
closeout zero "- **Issues:** #0";                 refuses zero "refuses #0"
closeout none-why "- **Issues:** none: <why>";    refuses none-why "refuses the literal none: <why>"
closeout none-sp "- **Issues:** none:    ";       refuses none-sp "refuses none: with only spaces"
closeout pull-url "- **Issues:** https://github.com/goplemms/memento/pull/5"; refuses pull-url "refuses a PR URL"
closeout fake-url "- **Issues:** o/r/issues/5";   refuses fake-url "refuses a non-URL issues path"
# An Issues line outside Closeout doesn't count.
mkdir -p "$WS/outside"
sed '/^- \*\*Issues:/d; s/^- \*\*Graduated to:\*\*.*/- **Graduated to:** commit body/; s/^## Queue$/## Queue\n\n- **Issues:** #41/' \
  "$TPL" > "$WS/outside/PROGRESS.md"
grep -q '^- \*\*Issues:\*\* #41' "$WS/outside/PROGRESS.md" || fail "fixture: Issues line not in Queue"
refuses outside "ignores an Issues line outside Closeout"

closeout numbers "- **Issues:** #41, #42";                            accepts numbers "accepts issue numbers"
closeout other-repo "- **Issues:** goplemms/ds-stock-screener#7";     accepts other-repo "accepts owner/repo#N"
closeout url "- **Issues:** https://github.com/goplemms/memento/issues/41"; accepts url "accepts an issue URL"
closeout none "- **Issues:** none: docs typo, nothing to watch";      accepts none "accepts none: <why>"
closeout crlf-ok "$(printf -- '- **Issues:** #41\r')";               accepts crlf-ok "accepts a CRLF line"
closeout cap-none "- **Issues:** None: spike, nothing shipped";       accepts cap-none "accepts None: <why>"
# An Issues line in a ### subsection under Closeout still counts.
closeout sub "### Filed
- **Issues:** #41";                                                    accepts sub "accepts an Issues line in a Closeout subsection"

# The template, land, ship and the scheme agree on the names.
grep -q '^- \*\*Issues:\*\*' "$TPL" \
  && grep -q '\*\*Issues\*\*' "$ROOT/skills/land/SKILL.md" \
  && grep -q 'docs/ideas.md' "$ROOT/skills/land/SKILL.md" \
  && grep -q 'fire:watching' "$ROOT/skills/land/SKILL.md" \
  && grep -q 'fire:watching' "$ROOT/skills/ship/SKILL.md" \
  && grep -q 'Closes #N' "$ROOT/skills/ship/SKILL.md" \
  && grep -q '`picked`' "$ROOT/skills/orchestrate/SKILL.md" \
  && grep -q 'fire:watching' "$ROOT/docs/ideas.md" \
  && grep -q 'label:"fire:watching"' "$ROOT/docs/projects.md" \
  && ok "wiring: template, land, ship, scheme and pulse prompt agree" || fail "wiring"

exit $FAIL
