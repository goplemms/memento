---
name: workflow-init
description: Bootstrap a repo to use the kit's planning workflow — wire .claude/settings.json so local sessions install the memento plugin, create the scratchpad/ workspace, wire .gitignore so feature work stays local but templates can be tracked, and surface any project-scope skills that would shadow the kit. Use once per repo before running the orchestrate loop.
when_to_use: Setting up a new repo for the memento workflow; scratchpad/ or .gitignore isn't wired yet; before the first new-feature.sh in a repo.
---

# Workflow Init

## Purpose

Bootstrap a repo to use the kit's planning workflow: declare the memento
marketplace so local sessions install the plugin, create the `scratchpad/`
workspace, wire `.gitignore` so feature work stays local but templates can be
tracked, and surface any project-scope skills that would shadow the kit.

## Inputs

- A git repo (the consuming project)
- The kit reachable as a plugin for *this* run (so `memento:orchestrate` etc.
  resolve and `${CLAUDE_PLUGIN_ROOT}` points at the kit). In cloud sessions that
  comes from the environment's setup script (README, "Install in cloud
  sessions"); locally, from a plugin install.

## Process

1. Confirm the repo via `git rev-parse --show-toplevel`. Fail loud if not a repo.
2. **Wire plugin install for local sessions.** Ensure `.claude/settings.json`
   declares the memento marketplace and enables the plugin, so local sessions
   in this repo offer it once the folder is trusted. Public repo, so no token
   is needed.

   Merge these keys into any existing `.claude/settings.json` (preserve other
   keys; don't duplicate the `enabledPlugins` entry if it's already present):

   ```json
   {
     "extraKnownMarketplaces": {
       "memento": {
         "source": { "source": "github", "repo": "goplemms/memento" }
       }
     },
     "enabledPlugins": { "memento@memento": true }
   }
   ```

   **Cloud sessions ignore these keys.** They get memento from the cloud
   environment's setup script instead (see the README's "Install in cloud
   sessions" and ADR-0003). That is set once per environment, not per repo, so
   don't add anything cloud-specific here; just tell the user whether their
   environment's setup script already installs memento.
3. Create `scratchpad/` and `scratchpad/archive/` if absent.
4. Wire `.gitignore`. A `.gitignore` CANNOT re-include paths under an excluded
   directory, so use a glob + negation, not a bare `scratchpad/`:

   ```
   scratchpad/*
   !scratchpad/.gitkeep
   ```

   Feature dirs stay untracked by default; adjust negations if a repo wants to
   track specific workspaces.
5. **Shadow scan.** Check for `.claude/skills/<name>` in this repo that match
   kit skill names. Project-scope skills take PRECEDENCE over user-scope, so a
   committed copy silently overrides the kit. Warn for each match and offer to
   reconcile (upstream improvements to memento, then remove the fork) — or hand
   to `memento:workflow-sync`.
6. Confirm the structure scripts resolve under the installed plugin:
   `${CLAUDE_PLUGIN_ROOT}/bin/new-feature.sh`,
   `${CLAUDE_PLUGIN_ROOT}/bin/archive-feature.sh`,
   `${CLAUDE_PLUGIN_ROOT}/bin/sweep-archive.sh`.

## Outputs

- A `.claude/settings.json` that declares the memento marketplace and enables
  the plugin for local sessions
- A `scratchpad/` workspace with archive subdir
- A `.gitignore` using glob + negation (not a bare excluded dir)
- A report of any project-scope shadows to reconcile

## Notes

The `.claude/settings.json` step only affects local sessions. Cloud sessions
don't install plugins a repo declares; they rely on the environment setup
script, which covers every repo in that environment (ADR-0003).

For a purely local machine you can instead symlink the kit into user scope; the
only reason to vendor skill *copies* into a repo is a concrete team/CI need,
otherwise repos should stay fork-free so the workflow is identical everywhere.
