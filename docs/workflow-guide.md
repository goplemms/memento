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
| **Decompose to Issues** skill | `skills/decompose-to-issues/SKILL.md` | A plan needs to become a tracker backlog several sessions can work in parallel, or you've inherited a backlog written before the code existed and need to know which of its claims still hold |
| **Backlog Reviewer** agent | `agents/backlog-reviewer.md` | The review gate inside Decompose to Issues — auditing a *set* of issues against the code and against each other before anyone implements |
| **Feature Steward** agent | `agents/feature-steward.md` | A feature spans multiple sessions and the human wants to steer the product without reading code, or technical detail has started crowding out the product decisions |

---

## Cross-Cutting Conventions

| Convention | File | Applies when… |
|---|---|---|
| **TL;DR block** | `docs/tldr-convention.md` | Any decision point hands the user something to choose — the commit gate, a red-team readout, an audit's findings, a plan hand-off, a backlog review, or any mid-flow fork. Lead with ≤5 jargon-free bullets of ≤10 words, detail below |

Unlike everything above, the TL;DR block is not skill-scoped: the plugin's hooks
(`hooks/hooks.json`) inject it once per session — and again after compaction —
plus on ~19% of turns to keep it near the decision points that arrive late in a
long session. So it applies even where no kit skill was ever invoked. The named
skills still reference it at their own decision points, which is what tells them
*where* in their output it goes.

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

### Turning a plan into a backlog several sessions can work
1. **Repo Exploration** — only if the repo is unfamiliar; the code is the source of truth for every claim an issue will make
2. **Decompose to Issues** — cut along real code seams, map the file collisions, label the phase boundary, split closeable slices into linked child issues
3. *(inside step 2)* **Backlog Reviewer** agent — the read-only gate over the whole set: contradicted premises, phantom dependencies, duplicate ownership, unverifiable criteria, collisions, gaps
4. **Orchestrate** — drive the first issue as a feature; the rest of the backlog is now sequenced and safe to parallelise

### Inheriting a backlog written before the code existed
1. **Decompose to Issues** — start at step 1: verify the shared premise every issue assumes before reviewing any single one
2. Fix the issue bodies in place, leaving a changelog comment per issue; escalate decisions rather than picking silently

### Steering a feature across sessions without reading code
1. **Feature Steward** agent — define "done" as user-visible outcomes *before* building; keep mechanism out of the conversation and in the briefs
2. **Decompose to Issues** — if the feature is large enough that several sessions will work it in parallel
3. *(each session)* the steward checks real state before describing it, drives open questions to decisions, records what's settled, then briefs an implementation subagent and verifies the result
4. **Challenge** — the steward's own guard: "all green" is not done; ask what a *user* can now do that they couldn't before

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

Plan needs to become issues several sessions can work in parallel?
  └─ Yes → Decompose to Issues (includes the Backlog Reviewer gate)

Inherited a backlog written before the code existed?
  └─ Yes → Decompose to Issues — verify the shared premise first, then review

Steering a multi-session feature without reading code?
  └─ Yes → Feature Steward — define "done" as user-visible outcomes first
```

---

## Notes

- **Orchestrate** is the top-level entry point for feature work — it composes all the other skills.
- Skills are self-contained; fire them individually when you only need that piece.
- If unsure, start with **Repo Exploration** — it is intentionally conservative and cheap to run.
- Under `--user` symlink install, editing a skill in `~/.claude` IS editing memento directly.
