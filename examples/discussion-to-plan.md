# Example: Discussion to Plan

## Context

A feature idea came out of a planning chat that was not originally about shipping product. You paste a short excerpt and ask Claude Code to run the skill.

## Prior discussion (paste this as context)

```text
Alex: Our standup ran long because nobody knew who owned the deploy.
Sam: We could just tag PRs with a team.
Alex: Or a bot that posts “last deploy” in Slack.
Sam: I like the bot idea but Slack is noisy.
Alex: Yeah, maybe a page in the internal wiki that updates from CI.
Sam: Low effort if we only show commit + time + who merged.
```

## Prompt

Follow `skills/discussion-to-plan/SKILL.md`.

**What I want now:** We are *not* deciding Slack vs wiki yet. I care about low ceremony and something we can ship in a day. Use the excerpt above as the only “prior conversation” unless you need me to paste more.

1. State your one-sentence hypothesis for the feature.
2. Bullet what from the excerpt supports it, what is contradictory or vague, and what you are ignoring for now.
3. Ask at most **three** clarifying questions (one round).
4. After I answer, produce a short plan document: problem, goal, in scope / out of scope, approach, risks, next steps. Save or paste it where I tell you.

*(For a dry run without a human in the loop, answer your own three questions with assumed answers in brackets, then write the plan.)*

## Expected Shape

- Hypothesis labeled as hypothesis, not fact
- Grounded quotes or tight paraphrases from the excerpt, not a wall of paste
- At most three questions, each specific
- Plan section is short and executable, not a strategy deck

## Notes

This example checks that the skill stays **interactive-first**: it does not jump from transcript straight to a full wiki spec without alignment. If you want stricter evals, add success signals to `evals/` for “asked ≤3 questions” and “plan mentions explicit non-goals.”
