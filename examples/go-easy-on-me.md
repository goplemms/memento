# Example: Go Easy On Me

*One instance of the skill — a beginner asking what a repo they just opened actually is.
The same skill applied to an error message, a design decision, or a library works the
same way: one rung, then let them choose the next.*

## Context

A user opened this repository for the first time, read `README.md`, and came away with
the words but not the shape. They don't want the architecture doc yet — they want to
know whether this thing is worth their afternoon.

## Prompt

> Hm may I request a beginner explanation of this, roughly tweet length, with bullet
> points roughly 10 words max, and we can dig from there

## Expected Shape

Something at this altitude and length (235 characters, bullets of 7-9 words):

> A box of reusable instructions you hand Claude before a task.
>
> - Skills are checklists for one job each
> - Personas set the voice and role Claude adopts
> - Templates are starter files for new ones
> - Nothing runs on its own — you invoke it

What makes it right:

- **One sentence you'd remember a week later**, before any bullets.
- **Bullets are hooks.** "Nothing runs on its own" is the one that gets asked about,
  because it contradicts what "kit" implies.
- **Plain words throughout.** No `SKILL.md`, no "namespaced", no "marketplace" — those
  are the *answers* to the next question, not this one.
- **It ends.** No "want the why, an example, or how to install?" — that menu would be a
  guess at what they're after, and the reader knows better than the guess.

## The Anti-Example

The same content, written without the skill:

> This is a Claude Code plugin repository implementing a workflow kit. `skills/` holds
> SKILL.md files loaded namespaced as `memento:<name>`; `agents/` holds persona
> definitions loaded as subagents; `templates/` provides scaffolds. Installation is via
> `/plugin marketplace add`, or `install.sh --user` for a symlink install that makes
> `~/.claude` edits equivalent to editing the kit directly. See `docs/architecture.md`.

Everything in it is true, and it teaches a beginner nothing — there is no way in. They
can't tell which sentence matters, and every noun needs its own explanation first.

## Digging From There

The reader asks their own question — sharper than any menu would have been, because it
names the part *they* snagged on. The next rung gets more room and stays plain:

> **User:** wait, so nothing runs on its own? what makes a skill fire then

> Right — it's a library, not a robot. Files sit there until something reads them.
>
> - You type `/orchestrate`, Claude reads that skill's steps
> - Claude may also pick one up when it fits
> - Either way, a session has to start it
> - No background jobs, no watchers, no schedule

Note what did **not** happen: the second answer didn't dump the plugin loading model,
frontmatter, or precedence rules. Those are rung three, if they're ever asked for. And it
stops at the last bullet again — the reader has already shown they'll ask.

## Notes

- The hard part is step 1, not the trimming. Once you've picked the one sentence, the
  bullets fall out; if you skip it, you write a compressed wall of text instead.
- Drop the format the moment they ask for depth outright ("ok give me the whole thing").
  Continuing to ration a reader who has asked for the full detail is just annoying.
- Worth trying on things *you* half-understand. If you can't get it to a tweet, you have
  found the gap — that's a useful result, and worth saying out loud rather than padding.
