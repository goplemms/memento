---
name: go-easy-on-me
description: Explain something to a beginner as a first rung, not a full answer — tweet-length total, 3-5 bullets of ≤10 words each, no jargon, ending with the threads they can pull next. Detail is deliberately withheld until asked, then handed over one rung at a time. Use when the user asks for a beginner/simple/plain-English explanation, says "go easy on me" or "ELI5", or asks what something is before deciding how deep to go.
when_to_use: The user asks what something is or how it works and signals they're new to it; they ask for the short version first; they want to decide where to dig before reading a wall of text.
---

# Go Easy On Me

## Purpose

Give a beginner a first rung they can stand on, and let them choose the next one.

The failure this prevents is the correct wall of text: an explanation that answers
everything, is accurate throughout, and leaves the reader no way in. A beginner
cannot tell which paragraph matters, so they either read all of it badly or none
of it. Answering less, on purpose, and naming what was left out turns one dense
reply into a conversation the reader steers.

This is not the TL;DR block. A TL;DR summarizes detail that sits directly below
it. Here the detail is **not** below it — it is withheld until asked for.

## Inputs

- the thing to explain (a codebase, a concept, a file, an error, a decision)
- any signal about what the reader already knows — assume little, never nothing
- what they're likely trying to do with the answer, if it's knowable

## Process

1. **Find the one sentence.** If the reader remembered exactly one thing from
   this reply, what should it be? That's the opener. Everything else is optional.
2. **Cut to a tweet.** The whole reply — opener plus bullets — fits in roughly
   280 characters. Not "short-ish." If it doesn't fit, you picked too big a
   scope; narrow the question, don't compress the words.
3. **Write 3-5 bullets, ≤10 words each.** One idea per bullet. Plain words only:
   no jargon, file paths, symbol names, or acronyms the reader hasn't met. If a
   term is genuinely load-bearing, spend a bullet naming it in plain English —
   that's the vocabulary they need to ask the next question.
4. **Simplify by narrowing, never by lying.** Leaving something out is fine;
   saying something false because it's easier is not. If a simplification is
   load-bearing and wrong later, flag it in four words ("roughly — there's a
   catch") rather than smuggling it through.
5. **Check any analogy actually holds** for the part being asked about. A vivid
   analogy that breaks exactly where the reader is headed costs more than no
   analogy. When in doubt, drop it and use a concrete example instead.
6. **End with the threads.** One short line naming 2-3 specific directions they
   could pull, phrased as choices. "Want the why, the how, or where it bites?"
   beats "let me know if you have questions" — the first is answerable.
7. **On the next rung, re-apply this.** When they pick a thread, go one level
   deeper — not all the way. More room than a tweet, still plain language, still
   ending with the next choice. Keep going until they stop asking or say they're
   good. Drop the format the moment they signal they want the full detail.

## Outputs

- an opener: one plain sentence, the thing worth remembering
- 3-5 bullets, ≤10 words each, one idea apiece, no jargon
- the whole thing within roughly a tweet
- a closing line offering 2-3 named threads to pull
- nothing else — no preamble, no restating the question, no summary of the summary

## Notes

- **Nothing is being dumbed down.** Scope shrinks; truth doesn't. The reader is
  new to this, not incapable — condescension ("don't worry about that part") is
  worse than jargon, because jargon they can look up.
- **The bullets are hooks, not a table of contents.** Each should be interesting
  enough to want expanded. A bullet nobody would ask about is a wasted line.
- **Resist the completeness reflex.** The urge to add the caveat, the exception,
  the "well, technically" is exactly what this skill exists to interrupt. The
  exception gets its own rung if they ask for it.
- **Length is the constraint that does the work.** If you're allowed 400 words,
  you'll write 400 words and skip step 1 entirely. The tweet forces the choice.
- Related but distinct: `docs/tldr-convention.md` is a lens over detail that is
  present; this is a first rung with the detail deliberately absent. Don't stack
  both in one reply — a TL;DR above a tweet-length answer is pure formatting.
