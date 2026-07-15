#!/bin/bash
# SessionStart hook: keep the installed memento plugin current.
#
# Cloud (Claude Code on the web) sessions restore a cached environment image
# whose plugin/marketplace clone can be frozen at an old commit, and the
# configured autoUpdate does not reliably refresh it. This hook force-pulls the
# marketplace and updates the installed plugin each session so a session always
# converges on the latest default-branch release.
#
# Safe to run repeatedly; never fails the session (always exits 0).
set -uo pipefail

# Only relevant in the remote/cloud environment; local users manage plugins
# themselves via the interactive /plugin manager.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Refresh the marketplace clone from its source (default-branch HEAD), then
# update the installed plugin to that version. Tolerate failure: if the
# marketplace isn't registered yet, the session-start install from
# .claude/settings.json handles it, and a transient network error must never
# block session startup.
claude plugin marketplace update memento || true
claude plugin update memento@memento     || true

exit 0
