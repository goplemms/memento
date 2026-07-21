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
| **Workflow Init** skill | `skills/workflow-init/SKILL.md` | Bootstrapping a repo to use the kit (creates `scratchpad/`, wires `.gitignore`, checks for shadows) |
| **Workflow Sync** skill | `skills/workflow-sync/SKILL.md` | Detecting and reconciling drift between a repo's vendored skill copies and the canonical kit |
| **Iterate on Asset** workflow | `skills/iterate-on-asset/SKILL.md` | Improving an existing skill, persona, eval, or example through a draft-try-revise loop |
| **Challenge** skill | `skills/challenge/SKILL.md` | The default pre-commit gate in the loop — before committing a milestone that changed real behavior, try to break it; also fire on demand before accepting any plan or theory |
| **Codebase Audit** skill | `skills/codebase-audit/SKILL.md` | A class of problem (data-access inconsistency, orphaned rows, staleness vs docs, dead code, reuse) seems to span the codebase, or you're about to refactor and want the real extent first |

---

## Typical Sequences

### Starting fresh in an unfamiliar repo
1. **Repo Exploration** — read the repo shape, identify the smallest next action
2. *(proceed with that action)*

### Turning a conversation into a plan
1. **Repo Exploration** — only if repo context is needed to make the plan realistic
2. **Discussion to Plan** — synthesize the prior discussion, align with user, produce a plan document

### Driving a full feature (the main loop)
1. `new-feature.sh <name>` (or `/workflow-init` if the repo isn't set up yet) — scaffold the workspace
2. **Orchestrate** — runs the full loop internally:
   - Calls **Discussion to Plan** to write `plan.md` with milestones and user-testable gates
   - Calls **Implement** once per milestone until tests are green and the gate is met
   - Runs **Challenge** as the default commit gate — breaks each behavior-changing milestone before it's committed
   - Calls **Land** at the end for merge, reflection, and any kit improvements
3. `archive-feature.sh <name>` then `sweep-archive.sh` — clean up the scratchpad

### Auditing a class of problem across the codebase
1. **Repo Exploration** — only if you need the lay of the land first
2. **Codebase Audit** — dispatch a read-only agent per lens; get impact-ranked findings + a systemic root fix, each fix paired with the tripwire that keeps it fixed
3. **Challenge** — pressure-test the audit's fix-list *before the first edit* (the cheapest place to catch a confidently-wrong fix)
4. **Orchestrate** — drive the confirmed fixes as a feature, correctness + tripwires first (each milestone still challenged before commit); file the rest as follow-ups

### Setting up a repo for the first time
1. `./install.sh --user` (once, on the machine) — symlink kit assets into `~/.claude`
2. **Workflow Init** — bootstrap `scratchpad/`, `.gitignore`, and shadow scan in the target repo

### After improving a skill mid-feature
1. **Workflow Sync** — called automatically by **Land**; also run manually anytime to catch drift

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
  └─ Yes → Land  (includes Workflow Sync)

Repo not yet set up for the kit?
  └─ Yes → install.sh --user, then Workflow Init

Suspected drift between repo copy and canonical kit?
  └─ Yes → Workflow Sync

Improving an existing skill/persona/eval?
  └─ Yes → Iterate on Asset workflow

A class of problem seems to span the codebase (or about to refactor)?
  └─ Yes → Codebase Audit (read-only) → Orchestrate the root fix
```

---

## Notes

- **Orchestrate** is the top-level entry point for feature work — it composes all the other skills.
- Skills are self-contained; fire them individually when you only need that piece.
- If unsure, start with **Repo Exploration** — it is intentionally conservative and cheap to run.
- Under `--user` symlink install, editing a skill in `~/.claude` IS editing memento directly.
