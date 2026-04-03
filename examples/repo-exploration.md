# Example: Repo Exploration

## Context

You are in this repo (`memento`). You want to change something in the tiny practice sandbox only, without exploring the whole tree.

## Prompt

Follow `skills/repo-exploration/SKILL.md`.

**Goal:** I want to add a second tiny Python module next to `practice-areas/tiny-repo/app.py` that the practice README can mention, so people can try “find the right file” prompts.

Do not read the entire repo. List every file you open. Then give a short summary of what matters for this goal, what is missing, and the single smallest next action (including path).

## Expected Shape

- One-sentence restatement of the goal
- Bulleted list of inspected files (paths)
- Plain-language summary of `practice-areas/tiny-repo/` only as it relates to the goal
- One concrete next step, not a roadmap

## Notes

If the model starts listing unrelated top-level folders, the skill failed its “stay narrow” test. Good runs stay under `practice-areas/tiny-repo/` plus maybe `skills/repo-exploration/SKILL.md` if you asked it to follow the skill verbatim.
