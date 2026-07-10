#!/usr/bin/env bash
# install.sh — make memento the single source of truth for the workflow kit.
#
#   --user (default)   SYMLINK skills/agents/personas/templates into ~/.claude and put
#                      scripts on PATH (~/.local/bin). Edits to the live files
#                      ARE edits to memento — commit here, no backport.
#   --vendor <repo>    COPY version-pinned assets into <repo>, stamping a
#                      provenance header. The only path that creates forks.
#   --uninstall        Remove kit symlinks and restore the most recent backup.
#   --dry-run          Print what would happen; change nothing.
#
# Reversible: any pre-existing real target is backed up before we touch it.
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
BIN_DIR="${KIT_BIN_DIR:-$HOME/.local/bin}"
BACKUP_ROOT="$CLAUDE_DIR/.memento-backups"
LINKED_DIRS=(skills agents personas templates)

MODE="user"
VENDOR_REPO=""
DRY=0

log()  { echo "$@"; }
done_msg() { [ "$DRY" -eq 1 ] || echo "$@"; }
do_or_say() { if [ "$DRY" -eq 1 ]; then echo "[dry-run] $*"; else eval "$*"; fi; }

while [ $# -gt 0 ]; do
  case "$1" in
    --user)      MODE="user" ;;
    --vendor)    MODE="vendor"; shift; VENDOR_REPO="${1:-}"; [ -n "$VENDOR_REPO" ] || { echo "--vendor needs a repo path" >&2; exit 2; } ;;
    --uninstall) MODE="uninstall" ;;
    --dry-run)   DRY=1 ;;
    -h|--help)   sed -n '2,12p' "$0"; exit 0 ;;
    *)           echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

# ---- shadow scan: project-scope skills that would shadow the kit ----
scan_shadows() {
  # Look one level under common dev roots for repos carrying committed
  # .claude/skills that would take precedence over user-scope (silent drift).
  local roots=("$HOME" "$HOME/git" "$HOME/src" "$HOME/code")
  local found=0
  local kit_skills
  kit_skills="$(cd "$KIT_ROOT/skills" 2>/dev/null && ls -1 2>/dev/null || true)"
  for root in "${roots[@]}"; do
    [ -d "$root" ] || continue
    while IFS= read -r -d '' sk; do
      # Skip the kit's own and the user-scope dir.
      case "$sk" in "$KIT_ROOT"/*|"$CLAUDE_DIR"/*) continue ;; esac
      local name; name="$(basename "$sk")"
      if printf '%s\n' $kit_skills | grep -qx "$name"; then
        [ "$found" -eq 0 ] && echo "" && echo "WARNING: project-scope skills shadow the kit (these win over ~/.claude):"
        found=1
        echo "  - $sk"
      fi
    done < <(find "$root" -maxdepth 4 -type d -path '*/.claude/skills/*' -prune -print0 2>/dev/null)
  done
  if [ "$found" -eq 1 ]; then
    echo "  -> run /workflow-sync in each repo to reconcile (upstream or remove)."
  fi
}

backup_target() {
  local target="$1"
  if [ -L "$target" ]; then
    # Existing symlink: record where it pointed, then remove.
    local dest; dest="$(readlink "$target")"
    do_or_say "mkdir -p '$BACKUP_ROOT'"
    do_or_say "echo '$target -> $dest' >> '$BACKUP_ROOT/symlinks.log'"
    do_or_say "rm '$target'"
  elif [ -e "$target" ]; then
    # Real file/dir: move it into a timestamped backup.
    local stamp; stamp="$(date +%Y%m%d-%H%M%S)"
    do_or_say "mkdir -p '$BACKUP_ROOT/$stamp'"
    do_or_say "mv '$target' '$BACKUP_ROOT/$stamp/'"
    done_msg "backed up $target -> $BACKUP_ROOT/$stamp/"
  fi
}

link_one() {
  local src="$1" target="$2"
  [ -e "$src" ] || { log "skip (no source): $src"; return; }
  # Broken symlink also caught by -L.
  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$src")" ]; then
    log "ok (already linked): $target"
    return
  fi
  backup_target "$target"
  do_or_say "mkdir -p '$(dirname "$target")'"
  do_or_say "ln -s '$src' '$target'"
  done_msg "linked $target -> $src"
}

install_user() {
  do_or_say "mkdir -p '$CLAUDE_DIR'"
  for d in "${LINKED_DIRS[@]}"; do
    link_one "$KIT_ROOT/$d" "$CLAUDE_DIR/$d"
  done
  do_or_say "mkdir -p '$BIN_DIR'"
  for s in "$KIT_ROOT"/bin/*.sh; do
    link_one "$s" "$BIN_DIR/$(basename "$s")"
  done
  scan_shadows
  echo ""
  echo "done (--user). Edits to ~/.claude/{skills,agents,personas,templates} ARE edits to memento."
  echo "Ensure $BIN_DIR is on your PATH."
}

uninstall_user() {
  for d in "${LINKED_DIRS[@]}"; do
    local t="$CLAUDE_DIR/$d"
    if [ -L "$t" ]; then do_or_say "rm '$t'"; done_msg "removed link $t"; fi
  done
  for s in "$KIT_ROOT"/bin/*.sh; do
    local t="$BIN_DIR/$(basename "$s")"
    if [ -L "$t" ]; then do_or_say "rm '$t'"; done_msg "removed link $t"; fi
  done
  # Restore the most recent timestamped backup, if any.
  if [ -d "$BACKUP_ROOT" ]; then
    local latest; latest="$(ls -1d "$BACKUP_ROOT"/*/ 2>/dev/null | sort | tail -1 || true)"
    if [ -n "$latest" ]; then
      log "restoring backup from $latest"
      for item in "$latest"*; do
        [ -e "$item" ] || continue
        do_or_say "mv '$item' '$CLAUDE_DIR/'"
      done
    fi
  fi
  echo "uninstalled. Backups (if any) under $BACKUP_ROOT remain for inspection."
}

install_vendor() {
  local repo="$VENDOR_REPO"
  [ -d "$repo" ] || { echo "error: vendor repo not found: $repo" >&2; exit 1; }
  local commit; commit="$(git -C "$KIT_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  echo "vendor mode copies version-pinned assets into $repo with a provenance header."
  echo "memento@$commit"
  echo ""
  echo "NOTE: --vendor is the team/CI path and creates deliberate forks."
  echo "For a single dev machine, prefer --user (symlinks) so repos never fork."
  echo "Per-file copy with '# sourced from memento@$commit' headers + .gitignore"
  echo "negation is intentionally left for when a team/CI need is concrete."
  exit 0
}

case "$MODE" in
  user)      install_user ;;
  uninstall) uninstall_user ;;
  vendor)    install_vendor ;;
esac
