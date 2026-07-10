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

### Plugin packaging (`.claude-plugin/`) — the install channel

memento installs as a self-hosting Claude Code plugin, and this is the *only*
install channel (ADR-0003). `.claude-plugin/plugin.json` is the manifest and
`.claude-plugin/marketplace.json` a one-entry marketplace pointing at this repo
root. Installed as a plugin: `skills/` load namespaced (`memento:<name>`),
`agents/` auto-discover, `bin/` goes on the Bash tool's PATH, and scripts resolve
the kit root via `CLAUDE_PLUGIN_ROOT`. It installs the same way everywhere,
including ephemeral/web sessions. See ADR-0001 and ADR-0003.

Personas are not a Claude Code plugin primitive; they are carried tone-guide
files shipped in the plugin and referenced from a consuming repo via
`${CLAUDE_PLUGIN_ROOT}/personas/…`.

### Distribution and drift

One channel, one version — every repo resolves the same installed plugin, so
there are no forks to reconcile. An improvement discovered mid-feature goes home
as a **phone-home PR** against memento (GitHub API, project-neutral,
human-approved), captured during the `land` reflection. This replaces both the
old symlink-commit loop (which never worked in the cloud) and the `--vendor` /
`workflow-sync` drift machinery, now retired.

## Future Extension

If this grows beyond Claude Code, keep the core directories the same and add agent-specific notes inside assets or under a future `platforms/` or `adapters/` area. Do not introduce a larger abstraction layer until repeated friction makes it necessary.
