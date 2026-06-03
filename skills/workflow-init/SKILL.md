# Workflow Init

## Purpose

Bootstrap a repo to use the kit's planning workflow: create the `scratchpad/`
workspace, wire `.gitignore` so feature work stays local but templates can be
tracked, and surface any project-scope skills that would shadow the kit.

## Inputs

- A git repo (the consuming project)
- The kit installed at user scope (so `/orchestrate` etc. already resolve)

## Process

1. Confirm the repo via `git rev-parse --show-toplevel`. Fail loud if not a repo.
2. Create `scratchpad/` and `scratchpad/archive/` if absent.
3. Wire `.gitignore`. A `.gitignore` CANNOT re-include paths under an excluded
   directory, so use a glob + negation, not a bare `scratchpad/`:

   ```
   scratchpad/*
   !scratchpad/.gitkeep
   ```

   Feature dirs stay untracked by default; adjust negations if a repo wants to
   track specific workspaces.
4. **Shadow scan.** Check for `.claude/skills/<name>` in this repo that match
   kit skill names. Project-scope skills take PRECEDENCE over user-scope, so a
   committed copy silently overrides the kit. Warn for each match and offer to
   reconcile (upstream improvements to memento, then remove the fork) — or hand
   to `/workflow-sync`.
5. Confirm `new-feature.sh` / `archive-feature.sh` / `sweep-archive.sh` are on
   PATH (installed by `install.sh --user`).

## Outputs

- A `scratchpad/` workspace with archive subdir
- A `.gitignore` using glob + negation (not a bare excluded dir)
- A report of any project-scope shadows to reconcile

## Notes

Prefer user-scope symlinks over per-repo copies. The only reason to vendor into
a repo is a concrete team/CI need; otherwise repos should stay fork-free so the
workflow is identical everywhere on the machine.
