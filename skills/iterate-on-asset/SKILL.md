---
name: iterate-on-asset
description: Improve one kit asset (skill, persona, template, example, or eval) through a small draft-try-revise loop, capturing a short trail of evidence as you go. Use when refining an existing asset rather than driving a feature — favors one small draft tried in a practice area over an upfront redesign.
---

# Iterate on Asset

## Purpose

Improve one asset through a small loop of drafting, trying, and revising —
rather than redesigning it upfront. This is the kit's asset-maintenance loop;
it composes `memento:curious-builder` (tone) and `memento:repo-exploration`
(scoped reading).

## Inputs

- One asset to improve (a skill, persona, template, example, or eval)
- The nearest template or existing example for that asset type
- A practice area (`practice-areas/`) or other small place to try the draft

## Process

1. **Pick one asset.** Scope to a single file. If several need work, do them one
   at a time.
2. **Read the nearest shape.** Use `memento:repo-exploration` to read only the
   template or an existing example for this asset type — not the whole tree.
3. **Draft small.** Make one small change rather than a full redesign. Prefer a
   single working slice over a broad rewrite.
4. **Try it.** Exercise the draft in a practice area (or the real flow it serves)
   so you see it behave, not just read it.
5. **Capture evidence.** Add one `examples/` entry and/or one `evals/` note
   showing how the draft was tested and what it produced.
6. **Revise only the friction.** Change only the parts that actually caused
   trouble in step 4. Leave healthy parts alone.

## Outputs

- An updated asset (in its propagating home: `skills/`, `agents/`, or
  `templates/`)
- A small trail of evidence (an `examples/` entry, an `evals/` note, or both)
  showing how it was tried

## Notes

Keep the loop small and honest, in the spirit of `memento:curious-builder`: one
draft, one try, one revision beats a speculative framework. If an asset keeps
causing friction across features, that is a signal to reflect on it at
`memento:land` time and upstream the improvement — not to grow process here.
