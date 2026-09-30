# Eval: skill routing for the 2026-09 refresh

## Asset

`skills/ship`, `skills/handoff-prompt`, `skills/domain-decisions`, and
`skills/challenge` (which now covers drafts and decisions).

## Question

Does a real user phrasing, taken word for word from the Aug–Sep 2026 session
history, route to the intended skill from its description alone?

## Method

`claude -p --plugin-dir <memento>` with the prompt: "Do not do the task. Reply
with only the name of the one skill from your available skills list that best
fits this user message, or 'none'", followed by the phrasing.

## Result (2026-09-30)

| User phrasing | Picked |
|---|---|
| May I request a copy-paste prompt to pick this up fresh from main | `memento:handoff-prompt` |
| Perfect! May I request we check CI and merge if it's green | `memento:ship` |
| Can we review our issues for decisions our domain expert must weigh in on, one at a time? | `memento:domain-decisions` |
| May I request we fire off an agent to challenge the assessment draft | `memento:challenge` |

4 of 4 routed as intended.

## Re-run when

A skill description changes, or a new skill's description overlaps one of these.
