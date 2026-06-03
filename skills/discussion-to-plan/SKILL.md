# Discussion to Plan

## Purpose

Turn a fuzzy feature idea that emerged from earlier conversation into a clear goal and a single implementation plan document, without over-trusting the transcript or skipping alignment with the user.

## Inputs

- Prior discussion, transcript, or notes the user points to
- What the user cares about now, if that has shifted
- Optional: repo or product context needed to make the plan realistic

## Process

1. Restate in one sentence what you think the feature idea is. Label it as a hypothesis, not a decision.
2. Pull out from prior discussion only what might support that hypothesis: goals, constraints, examples, and explicit non-goals. Quote or paraphrase briefly; do not paste huge blocks unless asked.
3. Ask a small set of focused questions to resolve ambiguity. Prefer one round of tight questions over many vague ones. If the user says “good enough,” stop asking and move on.
4. Confirm with the user which parts of the prior conversation are still relevant and which to ignore.
5. Only after alignment, draft the plan. When this feeds the kit's workflow, write it into the workspace's `plan.md` (from `templates/workflow/plan.md`): a north-star goal, non-scope, and ordered milestones — each milestone carrying an inline user-testable gate (web → page/button · CLI → command + output · lib → invokable runner). Otherwise a short freeform plan (problem, goal, scope, approach, risks, next steps) is fine. Keep it short unless the user asks for depth.

## Outputs

- A short synthesis: inferred feature, what from prior discussion matters, and what was discarded or left open
- The clarifying Q&A (or a note that the user skipped clarification)
- A plan document the team can execute against — `plan.md` when driving the kit's `orchestrate` loop, otherwise stored/pasted where the user wants it

## Notes

Default to interactive alignment first; the transcript informs the conversation, it does not replace it. If the prior discussion is missing or thin, say so and build the plan from live answers.

This skill produces the MVP contract that `orchestrate` builds against. It does not duplicate the milestone-execution loop — once `plan.md` exists, hand off to `orchestrate` / `implement`.
