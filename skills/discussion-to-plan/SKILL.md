---
name: discussion-to-plan
description: Turn a fuzzy feature idea from an earlier conversation into a clear goal and a single implementation plan document, without over-trusting the transcript, skipping alignment with the user, or graduating a consequential decision that hasn't survived an adversarial red-team. Produces the MVP contract that orchestrate builds against. Use when a prior discussion needs to become a concrete plan.
when_to_use: A prior discussion or transcript needs to become a concrete plan document; the user asks to turn an idea into a plan or MVP contract before building.
---

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
5. **Red-team before you commit — up to two rounds, revise-and-re-attack.** Before a substantive decision (or a small batch of them) graduates into the plan, stress-test it.
   - **Round 1.** Fan out a few *independent* critics, each with a *distinct lens* (correctness/feasibility · incentives/trade-offs · architecture/scope · internal coherence · does-it-serve-the-goal), each told to *break* the decision and to ground every claim in the actual code and artifacts — not the decision's own framing. Keep only the objections that survive.
   - **Round 2 — only if round 1 bit.** If surviving objections remain, *revise the decision to address them*, then run a **fresh** independent fan-out against the **revised** decision. This is the "back and forth," done as attack → revise → re-attack — **not** a debate between critics, and never over a shared critic transcript. Independence is the load-bearing property: a two-party dialogue converges toward a negotiated consensus (a plausible-but-wrong settlement), which is the blind spot the gate exists to catch. The push-back is *your revision*, attacked afresh.
   - **Stop / cap.** If round 1 comes back clean, stop there — do not manufacture a second round. Hard cap: two rounds. Mark a decision **PROVISIONAL** until a round leaves no surviving objection (or you consciously accept the residual and say so), and **CLEARED** after.
   - Batch decisions before a pass (each round costs real tokens) and reserve the whole gate for calls that would be expensive to get wrong — skip it for reversible micro-choices.
   - **Close with a TLDR readout.** Once the loop settles, recap what the red-team surfaced for a fast scan: bullets of **≤10 words each**, and under each bullet a one-line grounding — a `file:line`, *or* a named condition when the finding is a gap or a cross-artifact relation with no single line — naming the mechanism in a clause. A bare locator is not the grounding; the *why* is, so never let the line number stand in for it. Frame it as a readout of the surviving objections and how each was resolved (folded in / residual accepted), **not** a go/no-go verdict — the decision stays the user's.
6. Only after alignment and review, draft the plan. When this feeds the kit's workflow, write it into the workspace's `plan.md` (from `${CLAUDE_PLUGIN_ROOT}/templates/workflow/plan.md`): a north-star goal, non-scope, and ordered milestones — each milestone carrying an inline user-testable gate (web → page/button · CLI → command + output · lib → invokable runner). Otherwise a short freeform plan (problem, goal, scope, approach, risks, next steps) is fine. Keep it short unless the user asks for depth.

## Outputs

- A short synthesis: inferred feature, what from prior discussion matters, and what was discarded or left open
- The clarifying Q&A (or a note that the user skipped clarification)
- A plan document the team can execute against — `plan.md` when driving the kit's `orchestrate` loop, otherwise stored/pasted where the user wants it
- A closing TLDR readout of the red-team: ≤10-word bullets recapping the surviving objections and their resolution, each grounded (a `file:line` or a named condition) — a readout, not a verdict

## Notes

Default to interactive alignment first; the transcript informs the conversation, it does not replace it. If the prior discussion is missing or thin, say so and build the plan from live answers.

An independent, artifact-grounded red-team (step 5) catches plausible-but-wrong decisions before they reach the plan, where they'd otherwise surface at build time — far more expensive to unwind. The independence and the grounding are what make it work: a single generic "review" pass tends to reproduce the author's blind spot, and ungrounded critique invents problems. Scale it to stakes — a couple of finders for a small call, several diverse lenses plus a synthesis for a large one.

The second round is **revise-and-re-attack**, not a defender arguing back. A dedicated defender that rebuts objections before you see them (or that shares a transcript with the adversary) quietly reintroduces the failure this gate removes — it rationalizes real objections away and converges the two voices toward consensus. Keep the push-back in *your revision* and let fresh, independent critics attack the revised decision. Round 2 fires only when round 1 surfaced something worth re-attacking, so a clean decision is never taxed a second round.

This skill produces the MVP contract that `memento:orchestrate` builds against. It does not duplicate the milestone-execution loop — once `plan.md` exists, hand off to `memento:orchestrate` / `memento:implement`.
