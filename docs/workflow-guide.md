# Workflow Guide

A step-by-step reference for which skills and workflows to fire, and when.

---

## Core Assets

| Asset | File | Fires when… |
|---|---|---|
| **Repo Exploration** skill | `skills/repo-exploration/SKILL.md` | Starting work in an unfamiliar repo, or before proposing any change |
| **Discussion to Plan** skill | `skills/discussion-to-plan/SKILL.md` | A fuzzy idea from prior conversation needs a concrete plan document |
| **Orchestrate** skill | `skills/orchestrate/SKILL.md` | Driving a feature end-to-end (composes Discussion to Plan, Implement, and Land) |
| **Implement** skill | `skills/implement/SKILL.md` | Executing a single milestone from `plan.md` until tests are green and the gate is demonstrable |
| **Land** skill | `skills/land/SKILL.md` | Closing out a finished feature: merging, reflection, and capturing workflow improvements |
| **Workflow Init** skill | `skills/workflow-init/SKILL.md` | Bootstrapping a repo to use the kit (creates `scratchpad/`, wires `.gitignore`, checks for stale skill copies) |
| **Iterate on Asset** workflow | `workflows/iterate-on-asset/WORKFLOW.md` | Improving an existing skill, persona, eval, or example through a draft-try-revise loop |

---

## Typical Sequences

### Starting fresh in an unfamiliar repo
1. **Repo Exploration** — read the repo shape, identify the smallest next action
2. *(proceed with that action)*

### Turning a conversation into a plan
1. **Repo Exploration** — only if repo context is needed to make the plan realistic
2. **Discussion to Plan** — synthesize the prior discussion, align with user, produce a plan document

### Driving a full feature (the main loop)
1. `new-feature.sh <name>` (or the **Workflow Init** skill if the repo isn't set up yet) — scaffold the workspace
2. **Orchestrate** — runs the full loop internally:
   - Calls **Discussion to Plan** to write `plan.md` with milestones and user-testable gates
   - Calls **Implement** once per milestone until tests are green and the gate is met
   - Calls **Land** at the end for merge, reflection, and any kit improvements
3. `archive-feature.sh <name>` then `sweep-archive.sh` — clean up the scratchpad

### Setting up a repo for the first time
1. Enable the memento plugin (`/plugin marketplace add goplemms/memento` then `/plugin install memento@memento`, or declare it in the repo's `.claude/settings.json`)
2. **Workflow Init** — bootstrap `scratchpad/`, `.gitignore`, and the shadow check in the target repo

### After improving a skill mid-feature
1. Upstream it to memento with a **phone-home PR** (see **Land**) — project-neutral, human-approved

### Improving an asset outside of a feature
1. **Iterate on Asset** workflow — draft, try in a practice area, capture eval, revise

---

## Quick Decision Tree

```
New task in unfamiliar repo?
  └─ Yes → Repo Exploration first

Have a fuzzy idea to formalize into a plan?
  └─ Yes → Discussion to Plan  (+ Repo Exploration if repo context helps)

Driving a feature start-to-finish?
  └─ Yes → Orchestrate (includes Discussion to Plan → Implement → Land)

Finishing and merging a feature?
  └─ Yes → Land

Repo not yet set up for the kit?
  └─ Yes → enable the memento plugin, then Workflow Init

Improved a kit asset and want it upstream?
  └─ Yes → phone-home PR (see Land)

Improving an existing skill/persona/eval?
  └─ Yes → Iterate on Asset workflow
```

---

## Notes

- **Invoking skills:** the kit installs as a plugin, so skills fire namespaced as `memento:<name>` — e.g. `memento:orchestrate`. This guide names skills without the prefix; add `memento:` when you invoke one.
- **Orchestrate** is the top-level entry point for feature work — it composes all the other skills.
- Skills are self-contained; fire them individually when you only need that piece.
- If unsure, start with **Repo Exploration** — it is intentionally conservative and cheap to run.
- Improvements to a kit asset go home as a **phone-home PR** against memento — project-neutral, human-approved.
