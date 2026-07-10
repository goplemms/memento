# ADR-0002: Introduce task-delegated agents as a first-class asset type

- **Status:** Accepted
- **Date:** 2026-07-10

## Context

The kit carries several asset types — skills, workflows, personas, templates —
each a plain markdown building block. A recurring need did not fit any of them:
during planning, and before finalizing a decision, we want to hand a scoped
critique job to a worker that runs *away* from the main conversation, reasons
adversarially against a proposal, and returns only its findings. Doing that
inline floods the main context and biases toward agreement with the plan already
in progress.

Claude Code already has a native shape for exactly this — the subagent: a
markdown file with YAML frontmatter (`name`, `description`, optional
`tools`/`model`), auto-discovered from a plugin's `agents/` directory, running in
its own context window with its own tool and model scope. Now that the kit ships
as a plugin (ADR-0001), that directory is a channel we can use, and it had no
counterpart in the asset library.

This raised a structural question: is a subagent just a persona with tools, or a
distinct asset type? Personas already shape agent behavior — but they are *tone
guides*, carried into the main conversation and worn, never delegated to. A
subagent is delegated to: Claude routes a job to it and gets a result back. That
is a different relationship, a different lifecycle, and a different file format.

## Decision

Introduce **agents** as a first-class asset type, in a new top-level `agents/`
directory, following the Claude Code subagent format so the plugin auto-discovers
them. Keep **personas** as they are — plain carried tone-guide files, not
converted to agents — because the two solve different problems (worn vs.
delegated). Ship one agent to establish the shape: `decision-adversary`, a
critique-only decision-hardening subagent (steelman the case against, surface
risks, failure modes, and hidden assumptions, argue both blades; no verdict, no
proposed fix — the decision stays with the human).

## Alternatives considered

- **Convert personas into agents.** Collapses two concepts into one directory,
  but erases a real distinction: a persona is worn in the main context, an agent
  is delegated to in its own. Conversion would also force a tone guide into a
  subagent's task-and-return lifecycle it was never meant for. Rejected.
- **Model the adversary as a skill instead of an agent.** A skill runs inline in
  the main conversation — the exact context-flooding and confirmation-bias
  problem we wanted to avoid. A subagent's separate context window is the point.
  Rejected.
- **Make the adversary give a verdict or propose fixes.** More immediately
  actionable, but it takes the decision away from the human and turns an adversary
  into an advisor. The value is a sharpened trade-off, not a recommendation.
  Scoped to critique-only.
- **Wait for a second use case before adding the directory.** Consistent with the
  kit's "stay thin" rule, but the subagent format is stable, the need is
  concrete, and one clear example is the kit's own bar for adding structure.
  Introduced now, with a single example.

## Consequences

- **Easier:** on-demand adversarial review during planning and before an ADR is
  finalized, in a separate context window that neither pollutes the main
  conversation nor inherits its momentum toward the plan in progress. The kit now
  has a home for future task-delegated workers.
- **Harder / owed:** a new asset type is new surface to keep thin and neutral —
  every agent must stay project-generic (the same phone-home gate as skills), and
  the persona-vs-agent line has to be held so the two directories don't blur.
  Agents also carry format coupling to Claude Code's subagent spec; a spec change
  is now something the kit tracks.
- **Operational (the `decision-adversary` `model: opus` pin):** on a session or
  plan where opus is unavailable, Claude Code skips the excluded model and runs
  the subagent on the session's inherited model — a *silent downgrade*, not a
  failure. So the pin is a quality preference, not a guarantee: on a capped
  session the steelman runs at the session model's quality. Acceptable, and worth
  knowing before relying on it.
- **Revisit when:** agents accumulate enough that they need their own conventions
  doc or template (as skills and ADRs have), or if the persona/agent distinction
  stops paying for itself in practice — at which point supersede with a
  consolidation ADR.
