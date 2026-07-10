# Architecture

This repo treats each asset type as a simple markdown building block.

## Relationships

- A `persona` shapes how the agent behaves (a tone guide, carried into a session).
- An `agent` is a task-delegated subagent: Claude Code hands it a scoped job and
  gets back a result, in its own context window.
- A `skill` helps the agent do one focused job well.
- A `workflow` combines skills and personas into a repeatable sequence.
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

## Agents vs personas

These look similar but are different asset types, and the split is deliberate:

- A `persona` is a **tone guide** — a carried file that shapes voice and posture
  in the main conversation. It is not delegated to; it is worn.
- An `agent` is a **task-delegated subagent** — Claude Code routes a scoped job
  to it, it runs in its own context window with its own tools/model, and returns
  a result. It follows the Claude Code subagent format (YAML frontmatter:
  `name`, `description`, optional `tools`/`model`) and is auto-discovered from
  the plugin's `agents/` directory.

Personas therefore stay as plain carried files; agents live under `agents/`. The
first agent is `decision-adversary` — a decision-hardening subagent that
steelmans the case against a proposed decision or plan, surfaces risks, failure
modes, and hidden assumptions, and argues both blades so the human decides with
full information (critique-only: no verdict, no fix). See ADR-0002.

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

- `--user` (default): SYMLINK `skills/`, `personas/`, `templates/` into
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
marketplace pointing at this repo root). Installed as a plugin, `skills/` load
namespaced (`memento:<name>`), `bin/` goes on PATH, and scripts resolve the kit
root via `CLAUDE_PLUGIN_ROOT`. This is the cloud-first channel — it installs in
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
