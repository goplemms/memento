---
name: workflow-init
description: Bootstrap a repo to use the kit's planning workflow — wire .claude/settings.json so cloud sessions auto-install the memento plugin, create the scratchpad/ workspace, wire .gitignore so feature work stays local but templates can be tracked, and surface any project-scope skills that would shadow the kit. Use once per repo before running the orchestrate loop.
---

# Workflow Init

## Purpose

Bootstrap a repo to use the kit's planning workflow: declare the memento
marketplace so cloud sessions auto-install the plugin, create the `scratchpad/`
workspace, wire `.gitignore` so feature work stays local but templates can be
tracked, and surface any project-scope skills that would shadow the kit.

## Inputs

- A git repo (the consuming project)
- The kit reachable as a plugin for *this* run (so `memento:orchestrate` etc.
  resolve and `${CLAUDE_PLUGIN_ROOT}` points at the kit). See the bootstrap note
  below — a brand-new cloud repo won't have the plugin until step 2 lands and a
  fresh session starts, so the very first init may be run from a machine/session
  where the plugin is already loaded.

## Process

1. Confirm the repo via `git rev-parse --show-toplevel`. Fail loud if not a repo.
2. **Wire plugin auto-install.** Ensure `.claude/settings.json` declares the
   memento marketplace and enables the plugin, so future **cloud** sessions of
   this repo install it at session start (a cloud container boots with an empty
   `~/.claude/plugins`; the account-level plugin toggle does NOT materialize
   files into it — only a repo-declared marketplace does). Public repo, so no
   token is needed.

   Merge these keys into any existing `.claude/settings.json` (preserve other
   keys; don't duplicate the `enabledPlugins` entry if it's already present):

   ```json
   {
     "extraKnownMarketplaces": {
       "memento": {
         "source": { "source": "github", "repo": "goplemms/memento" }
       }
     },
     "enabledPlugins": [
       { "marketplace": "memento", "plugin": "memento" }
     ]
   }
   ```

   Commit this file — it must travel with the repo so every collaborator's cloud
   sessions get the kit. Note it only takes effect in a session started *after*
   it lands; it cannot be verified in the run that writes it.
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

- A `.claude/settings.json` that auto-installs the memento plugin in cloud
  sessions (marketplace declared, plugin enabled)
- A `scratchpad/` workspace with archive subdir
- A `.gitignore` using glob + negation (not a bare excluded dir)
- A report of any project-scope shadows to reconcile

## Notes

The `.claude/settings.json` step is what makes the cloud-first workflow work:
without it a cloud session has no way to know the kit exists, so none of the
skills load even when the plugin is "enabled" on your account. This is per-repo
by design — the declaration is version-controlled and travels with the repo.

For a purely local machine you can instead symlink the kit into user scope; the
only reason to vendor skill *copies* into a repo is a concrete team/CI need,
otherwise repos should stay fork-free so the workflow is identical everywhere.
