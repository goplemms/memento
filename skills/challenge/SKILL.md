---
name: challenge
description: Adversarially pressure-test the plan, implementation, or theory the session is currently working through — before committing to it. State what it claims, construct the cases or scenarios that would break it, and actually run them instead of re-walking the happy path. Trust it only once you've genuinely tried to break it and couldn't. Covers decisions and drafts too: steelman the case against, both blades, no verdict. Use when about to commit to an approach, ship an implementation, accept an explanation, finalize a decision, or send a document — especially when it looks right.
---

# Challenge

## Purpose

Pressure-test the current thinking before committing to it. A plan, an implementation,
or a theory that merely *looks* right — or that you've only ever walked forward through —
hasn't earned commitment. Try to break it; trust it only when you can't.

## Inputs

- the plan / implementation / theory / decision / draft currently under consideration
- what it claims to achieve, produce, or explain
- the context it has to hold in

## Process

1. State it in one line: what does it claim, promise, or assume?
2. Enumerate the ways it could be wrong — failure modes, missed cases, counterexamples,
   false assumptions. Ask "what would have to be true for this to fail?" not just "why
   will it work?"
3. Actually run it against those: trace the plan through the failure scenario, feed the
   implementation the breaking input, seek the observation that would falsify the theory.
   Re-walking the happy path proves little — it only confirms what you already believe.
4. Surface the load-bearing assumptions — the things that must hold for it to work but
   that you haven't checked. An unverified assumption is where it breaks.
5. Diagnose right-for-the-wrong-reason: it "works" or "holds" by coincidence, or because
   an unstated condition happens to be true, or only in the order/context you tried — not
   because of the mechanism you're claiming.
6. Revise to address what broke, then re-challenge. Iterate until it survives a genuine
   attempt to break it — or discard it if it can't.
7. If the challenge is cheap to re-run (a check, a scenario, a script), keep it so the
   same failure can't quietly return.

## Independent pass (optional)

Your own challenge shares your blind spots. When the stakes are high, or the
user asks to "fire off an agent to challenge" something, spawn a fresh
general-purpose subagent with read-only tools and this brief, then fold its
findings into step 6:

```
You are an adversary for a decision, plan, or draft that someone is about to
commit to. Make the case against it as strong as it can honestly be made.
Do not approve it, recommend, or propose the fix. The decision stays theirs.

<WHAT IS BEING DECIDED OR SENT, AND ITS CONTEXT>

Inspect the code, docs, and prior decisions you can reach before reasoning.
Deliver:
1. The decision restated in one or two sentences. If it's too vague to attack,
   say what is missing.
2. The strongest case against, steelmanned. Lead with the objection that would
   most change the decision if true.
3. Risks and failure modes: what breaks, when, who feels it, how you'd notice.
   Separate the likely from the tail.
4. Hidden assumptions: what must be true for it to be right, and what happens
   if it isn't.
5. Both blades: the case for and against side by side. Concede real strengths.
6. What would change the picture: the one check worth running before
   committing. Point at it; don't resolve it.
Cite specifics (a file, a line, a named condition) over abstract hazards. Flag
your confidence. Be terse.
```

For a **draft** (an assessment, a PR description, a memo), also have it read as
the intended reader: where would they get lost, disagree, or stop reading?

## Outputs

- a closing TL;DR block — ≤5 bullets, ≤10 words each, no jargon or paths: what
  broke, what survived, what it now needs (`${CLAUDE_PLUGIN_ROOT}/docs/tldr-convention.md`);
  when it leaves the user a choice and the session offers a decision card, ask
  it there
- the ways it could fail, *tested* — which broke it, which it survived
- the load-bearing assumptions, flagged verified vs unverified
- the revised plan / implementation / theory, re-challenged
- optionally, a preserved check for the failure modes worth guarding against

## Notes

- The failure this prevents: committing to something that only ever got the happy-path
  walk-through — a plan with an unhandled case, an implementation that's green for the
  wrong reason, a theory no evidence could have contradicted.
- Falsification over confirmation: a claim you can't imagine failing is one you haven't
  understood yet. Try to make it lie, and trust it only when you can't.
- "Looks stronger" is not "is stronger." The more elaborate option can be the more
  fragile one — only running the break-cases tells them apart, not your intuition about
  which looks robust.
- Cheapest to skip, most expensive to have skipped. The payoff peaks right *before* you
  commit — challenge it then, not after it has waved something through.
- It takes the shape of the thing under challenge: for a **plan** it's a pre-mortem (walk
  the scenario where it failed and ask why); for an **implementation** it's the breaking
  input / mutation (would it catch a deliberately wrong version?); for a **theory** it's
  the falsifying observation; for a **suite of checks** it's the specificity matrix — does
  each check fire on exactly its own case, or wave others through?
  For a **decision** it's the steelmanned case against, with both blades laid out
  and no verdict. For a **draft** it's the intended reader's first objection.
