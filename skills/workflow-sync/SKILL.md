# Workflow Sync

## Purpose

Make drift capture one command instead of archaeology. Detect when a repo's
copy of a kit asset has diverged from memento's canonical version — in EITHER
direction — and reconcile. Also detect project-scope skills that silently shadow
the user-scope kit.

## Inputs

- A repo (run from anywhere inside it)
- memento's canonical assets (the kit clone)
- Provenance headers / version pins on any vendored copies
  (`# sourced from memento@<commit>`)

## Process

1. **Locate kit-sourced assets in the repo.** Two sources of drift:
   - **Vendored copies** — files carrying a `# sourced from memento@<commit>`
     header.
   - **Project-scope shadows** — `.claude/skills/<name>` matching kit skill
     names. These take precedence over user-scope and are the #1 silent
     identity-breaker. Flag every one.
2. **Diff against canonical.** For each, diff the repo copy vs memento's current
   version. Ignore pure whitespace/format differences so trivial churn doesn't
   false-positive; report only substantive drift.
3. **Report bidirectionally:**
   - **repo-ahead** (repo copy has improvements) → offer to UPSTREAM
     (repo → memento commit).
   - **kit-ahead** (memento is newer) → offer to REFRESH (memento → repo copy),
     re-stamping the provenance header.
   - **shadow with no real diff** → offer to REMOVE the fork and fall back to
     user-scope.
4. **Reconcile on confirmation.** Apply the chosen direction; never edit
   silently. For upstreams, commit in the memento clone with a clear message.
5. **Habit hook.** Run this as part of graduation / `/land` so a workflow-asset
   improvement is captured the same moment a feature finishes — not later.

## Outputs

- A drift report (repo-ahead / kit-ahead / shadow) per kit-sourced asset
- Reconciled files in the chosen direction, with provenance re-stamped
- Any upstreamed improvement committed back to memento

## Notes

Under `--user` symlink install, most edits never fork — they land in memento
directly, so this skill mainly matters for vendored repos and for catching
project-scope shadows. Prefer symlinked user-scope; vendor only for team/CI.
