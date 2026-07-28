# Eval: Feature Steward

## Asset Under Test

`agents/feature-steward.md`

## Scenario

Hand it a feature already part-built across earlier sessions, with a tracked record that has
drifted from reality — at least one issue resting on an assumption that is no longer true, and
at least one open product decision buried inside a technical fork. Ask it where the feature
stands and what to do next.

The scenario has to be mid-feature. A steward starting from nothing looks like any other
planning agent; the role only shows itself where continuity, drift, and a stale record are
already in play.

## Success Signals

**Register:**

- leads with what a user can and cannot yet do, not with what has been implemented
- no file paths, function names, or line numbers in the conversation — they appear in the
  brief it writes for the implementation session, which is where they belong
- ends with the decision it needs, phrased so it can be answered in a sentence

**Definition of done:**

- states "done" as user-visible outcomes, and refuses to treat a green test run as done
- when told "all checks pass," asks what a user can now do that they couldn't before
- each outcome is something someone could go and check by using the thing

**Continuity:**

- reads the tracked issues and decision record *before* describing state, and says which parts
  it verified this session versus which it is taking on trust
- corrects a tracked issue whose premise turned out false, rather than working around it
- writes settled decisions somewhere durable, and says plainly what it recorded

**Decisions:**

- translates a technical fork into a product choice with concrete options, a recommendation
  first, and what each costs the user
- decides the obvious-default cases itself, says it did, and moves on

**Orchestration:**

- briefs a subagent with the traps it already knows about, and marks what is out of scope
- re-verifies the subagent's report rather than accepting it
- does not let scope expand quietly

## Result

Not yet run.

The agent was written from one real multi-session feature (a game's finale) where the failure
was structural rather than technical: every guard was green and the headline win condition was
literally unreachable, because the character at the entry point could not open the doors the
objective required. The tests proved the map's routes connected; nobody had checked a player
could walk them. That run is the *source* of the signals above, not evidence for them — the
asset has not been tried against a fresh feature.

## Notes

Two things to watch on the first real run.

**Does the register hold under pressure?** The no-paths-no-function-names rule is easy to
follow while reporting and hard to follow while debugging. If mechanism starts leaking into
the conversation exactly when the feature is in trouble, the rule needs to name that moment
specifically rather than stating the general preference.

**Does "verify before you believe" survive its own convenience?** The agent is told to re-run
the important checks rather than trust a subagent's report. This is the same constraint
`backlog-reviewer` was given after a confidently-wrong finding cost six public retractions,
and the same question applies: does it actually re-verify, or does it restate the constraint
and then trust the first report anyway? A constraint that only appears in the preamble is not
being followed.

Run it as the main thread (`claude --agent feature-steward`) for the full-fidelity version.
Delegated as a subagent it loses `AskUserQuestion`, so the multiple-choice decisions arrive as
prose rather than chips — worth evaluating separately, since the whole point of that section is
that the human answers quickly.
