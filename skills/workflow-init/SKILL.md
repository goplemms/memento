# Workflow Init

## Purpose

Bootstrap a repo to use the kit's planning workflow: create the `scratchpad/`
workspace, wire `.gitignore` so feature work stays local but templates can be
tracked, and surface any project-scope skills that would shadow the kit.

## Inputs

- A git repo (the consuming project)
- The memento plugin enabled (so `memento:orchestrate` etc. already resolve)

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
4. **Shadow check.** Look for `.claude/skills/<name>` in this repo that duplicate
   a kit skill. With plugin namespacing these no longer *collide* (a project
   `/<name>` is distinct from `memento:<name>`), but a stale local copy of a kit
   skill is drift waiting to happen — flag each so it can be deleted in favour of
   the enabled plugin.
5. Confirm the memento plugin is enabled: its `bin/` puts `new-feature.sh` /
   `archive-feature.sh` / `sweep-archive.sh` on the Bash tool's PATH.

## Outputs

- A `scratchpad/` workspace with archive subdir
- A `.gitignore` using glob + negation (not a bare excluded dir)
- A report of any project-scope skill copies to delete in favour of the plugin

## Notes

The kit installs as a plugin — no per-repo copies, no forks. A repo only needs
its `scratchpad/` workspace wired; the skills, agents, and scripts all come from
the enabled plugin, identically everywhere.
