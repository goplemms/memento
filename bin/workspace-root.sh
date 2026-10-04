#!/usr/bin/env bash
# workspace-root.sh
# Print the directory that holds this repo's feature workspaces.
#
#   1. $MEMENTO_WORKSPACE_ROOT/<repo>   if set (explicit override)
#   2. /mnt/project-files/memento/<repo> in a Claude Projects cloud thread,
#      where that folder is shared by every thread and outlives the container
#   3. <repo>/scratchpad                 everywhere else (local, plain web)
#
# A cloud thread's checkout is thrown away with its container, and scratchpad/
# is gitignored, so without (2) a feature's plan.md and PROGRESS.md would not
# reach the next thread. There is no documented "running in a Project" flag, so
# the shared folder's presence is the signal.
#
# <repo> is the origin remote's repository name, falling back to the checkout's
# directory name, so every thread on the same repo lands in the same folder.
set -euo pipefail

if ! REPO="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "error: not inside a git repository (cwd: $PWD)" >&2
  exit 1
fi

NAME="$(git -C "$REPO" remote get-url origin 2>/dev/null || true)"
NAME="${NAME%/}"; NAME="${NAME%.git}"; NAME="${NAME##*/}"; NAME="${NAME##*:}"
[ -n "$NAME" ] || NAME="$(basename "$REPO")"

SHARED="${MEMENTO_PROJECT_FILES:-/mnt/project-files}"

if [ -n "${MEMENTO_WORKSPACE_ROOT:-}" ]; then
  echo "$MEMENTO_WORKSPACE_ROOT/$NAME"
elif [ -d "$SHARED/" ] && [ -w "$SHARED/" ]; then
  echo "$SHARED/memento/$NAME"
else
  echo "$REPO/scratchpad"
fi
