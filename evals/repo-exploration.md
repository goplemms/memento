# Eval: Repo Exploration

## Asset Under Test

`skills/repo-exploration/SKILL.md`

## Scenario

Ask Claude Code to inspect `practice-areas/tiny-repo/` and recommend one small improvement.

## Success Signals

- it reads only the files needed
- it summarizes the repo accurately
- it suggests one scoped next step
- it does not invent a large architecture

## Result

Pass.

## Notes

Trial run against `practice-areas/tiny-repo/` inspected only `README.md`, `app.py`, and `notes.md` in that area plus the starter asset files.

The resulting recommendation was to make the skill explicitly report inspected files so the behavior stays observable and easy to evaluate.
