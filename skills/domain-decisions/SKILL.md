---
name: domain-decisions
description: Surface the judgment calls only a domain expert should make (accounting treatment, legal reading, clinical or business rules), then walk the user through them one at a time — plain-language summary, the options, what each would change, and a recommendation — and record each verdict where the work tracks it. Never guesses a domain judgment. Use when the user says "review for decisions our domain expert must weigh in on", "go over these one at a time", or "I'll act as the domain expert".
when_to_use: Work contains judgment calls outside engineering; the user asks to find or adjudicate decisions for a domain expert; a batch of open decisions needs discussing one at a time.
---

# Domain Decisions

## Purpose

Keep domain judgments with the person who owns them. Code, data and issues
collect calls that engineering can't settle on its own, like how to treat a
restatement, which concept counts as revenue, or what a rule means. Guessing
those silently produces confident, wrong software. This skill finds them, puts
them to the user in a form they can decide, and records the answer.

Usage data showed this pattern repeatedly: "DO NOT GUESS ACCOUNTING", "review
our issues, codebase, and data for decisions our domain expert will have to
weigh in on", and "can we go over those attention items one at a time".

## Inputs

- The scope to search: issues, code, data, or a list the user already has
- Where decisions are tracked (an issue label such as `needs:domain-expert`, an
  ADR folder, or a decisions file)
- Who the expert is. Often it's the user, sometimes while they learn the domain.

## Process

1. **Find the calls.** Search the scope for judgments outside engineering:
   labelled issues, TODOs, special cases in code, data that disagrees with
   itself, and places where the code picked one reading of a rule. For each,
   note where it lives and what currently happens.
2. **List them first.** Give the user the full list as one line each, ordered
   by what blocks the most work. Let them reorder or drop items before
   discussing any.
3. **Take them one at a time.** For each decision:
   - Explain the issue in plain language, as if the user is learning the
     domain. Keep it short and let them dig from there.
   - Give the options and what each would change, with a real example from the
     data where you can.
   - Give your recommendation and why, clearly marked as a recommendation.
   - Wait for the user's call. Research in parallel if they ask.
4. **Record the verdict** where the work tracks it (an issue comment, an ADR, a
   decisions file): the decision, the reasoning, and who made it. Anything left
   undecided stays visibly under review, never quietly defaulted.
5. **Close the loop.** List what was decided, what's still open, and which
   issues or code the decisions unblock.

## Outputs

- A prioritized list of domain decisions, each with where it lives
- One recorded verdict per decision made, with its reasoning
- The open items, marked as under review

## Notes

- Never resolve a domain judgment by guessing, even to unblock work. Ship the
  undecided case marked "under review" instead.
- One decision per turn. Batching them invites rubber-stamping.
- The user may be learning the domain as they go, so explain the concepts
  rather than the code. File paths belong below the explanation, not in it.
