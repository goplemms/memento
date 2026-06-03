# Workflow Guide

A step-by-step reference for which skills and workflows to fire, and when.

---

## Core Assets

| Asset | File | Fires when… |
|---|---|---|
| **Repo Exploration** skill | `skills/repo-exploration/SKILL.md` | Starting work in an unfamiliar repo, or before proposing any change |
| **Discussion to Plan** skill | `skills/discussion-to-plan/SKILL.md` | A fuzzy idea from prior conversation needs a concrete plan document |
| **Iterate on Asset** workflow | `workflows/iterate-on-asset/WORKFLOW.md` | Improving an existing skill, persona, eval, or example through a draft-try-revise loop |

---

## Typical Sequences

### Starting fresh in a repo
1. **Repo Exploration** — read the repo shape, identify the smallest next action
2. *(proceed with that action)*

### Turning a conversation into a plan
1. **Repo Exploration** — only if repo context is needed to make the plan realistic
2. **Discussion to Plan** — synthesize the prior discussion, align with user, produce a plan document

### Improving an asset
1. **Iterate on Asset** workflow, which internally calls:
   - **Repo Exploration** — understand the current asset and nearby context
   - *(draft, try in practice area, capture eval, revise)*

---

## Quick Decision Tree

```
New task in unfamiliar repo?
  └─ Yes → Repo Exploration first

Have a fuzzy idea to formalize?
  └─ Yes → Discussion to Plan  (+ Repo Exploration if repo context helps)

Improving an existing asset?
  └─ Yes → Iterate on Asset workflow (includes Repo Exploration internally)
```

---

## Notes

- Skills are self-contained; fire them individually when you only need that piece.
- The workflow composes skills; use it when you want the full draft-try-revise loop.
- If unsure, start with **Repo Exploration** — it is intentionally conservative and cheap to run.
