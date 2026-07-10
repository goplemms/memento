# Architecture

This repo treats each asset type as a simple markdown building block.

## Relationships

- A `persona` shapes how the agent behaves. Personas live in `agents/` and
  propagate as Claude Code subagents (`memento:<name>`).
- A `skill` helps the agent do one focused job well (`skills/`, `memento:<name>`).
- A `workflow` combines skills and personas into a repeatable sequence. It is
  authored AS a skill (a plugin has no separate `workflows/` channel), so
  workflows also live in `skills/` — `orchestrate` and `iterate-on-asset` are
  the two today.
- A `practice-area` provides a small place to test the workflow.
- An `example` shows how to invoke the asset in Claude Code.
- An `eval` records a simple way to check whether the asset was useful.

## Current Shape

The current structure is intentionally small:

- one example skill
- one example workflow
- one example persona
- one small practice area
- one example prompt file
- one sample eval

## Workflow kit

On top of the asset library, memento is the single source of truth for a lean
planning workflow.

### The core loop

Brief goal → back-and-forth to an MVP contract → build in user-testable
milestones → graduate the durable record → archive → GC. Driven by the
`orchestrate` skill, which composes `discussion-to-plan`, `implement`, and
`land`.

### Workflow templates (`templates/workflow/`)

- `plan.md` — north-star goal · non-scope · ordered milestones, each with an
  inline user-testable gate.
- `PROGRESS.md` — resume/survival file: status table, current block, closeout.
- `decisions.md` (opt-in) — ledger for contested work; supersede, never delete.
- `agents.md` (opt-in) — per-subagent scope for the current milestone.

### Structure scripts (`bin/`)

Three scripts, justified because they automate STRUCTURE (scaffolding,
date-math GC), not judgment. Each resolves the consuming repo via
`git rev-parse --show-toplevel`, so one copy works from any repo's cwd.

- `new-feature.sh <name> [--with-agents] [--with-decisions]` — scaffold.
- `archive-feature.sh <dir>` — date-prefixed move to `scratchpad/archive/`;
  refuses without a complete Closeout.
- `sweep-archive.sh [--older-than N] [--delete]` — dry-run GC of old archives;
  flags stale active dirs but never auto-deletes them.

### Install layer (`install.sh`)

- `--user` (default): SYMLINK `skills/`, `agents/`, `templates/` into
  `~/.claude` and put scripts on PATH (`~/.local/bin`). Existing targets are
  backed up first (reversible via `--uninstall`); re-runs are idempotent.
  Because the live files are symlinks into memento, editing them IS editing
  memento — commit here, no backport.
- `--vendor <repo>`: COPY version-pinned assets into a repo with a
  `# sourced from memento@<commit>` provenance header. The only path that
  creates forks; for team/CI, not the daily single-machine path.

### Plugin packaging (`.claude-plugin/`)

memento is also a self-hosting Claude Code plugin: `.claude-plugin/plugin.json`
(the plugin manifest) and `.claude-plugin/marketplace.json` (a one-entry
marketplace pointing at this repo root). Installed as a plugin, `skills/` and
`agents/` load namespaced (`memento:<name>`), `bin/` goes on PATH, and scripts
resolve the kit root via `CLAUDE_PLUGIN_ROOT`. A plugin propagates only these
channels (skills, agents, commands, hooks, MCP servers) — there is no
`workflows/` or `personas/` channel, which is why personas live in `agents/`
and workflows are authored as skills. This is the cloud-first channel — it installs in
ephemeral/web sessions where the `--user` symlinks don't exist. See ADR-0001.

### Identity guarantee and the shadow landmine

On a single dev machine, `--user` symlinks make the workflow byte-identical
across every repo: each `/orchestrate`, template, and script resolves to the
same canonical memento file. The one thing that silently breaks this is Claude
Code's precedence — a PROJECT-scope `.claude/skills/<name>` shadows the
user-scope copy. `install.sh`, `workflow-init`, and `workflow-sync` scan for
such shadows and warn so identity doesn't rot.

### Reverse-drift capture

The primary fix is structural: symlinks mean improvements land in memento
directly, captured during the `land` reflection. For vendored repos,
`workflow-sync` diffs each kit-sourced asset against canonical and reconciles
bidirectionally (repo-ahead → upstream, kit-ahead → refresh). Run it as part of
graduation / `land` so improvements are captured the moment a feature finishes.

## Future Extension

If this grows beyond Claude Code, keep the core directories the same and add agent-specific notes inside assets or under a future `platforms/` or `adapters/` area. Do not introduce a larger abstraction layer until repeated friction makes it necessary.
