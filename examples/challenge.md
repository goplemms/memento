# Example: Challenge

*One instance of the skill — challenging an implementation (a suite of checks). The same
skill applied to a plan is a pre-mortem; to a theory, the search for a falsifying
observation. Here the shape is the specificity matrix.*

## Context

A game's browser visual-audit had one coverage "gate" per screen — a predicate that
asserts *the intended screen actually rendered* before its layout checks are trusted.
Seven of them keyed on loose text regexes (e.g. a screen was "reached" if any visible
text matched `/discard|drop|storage/i`). All 14 gates were green. The question wasn't
"do they pass?" — it was "would they catch a **wrong** screen?"

## Prompt

Follow `skills/challenge/SKILL.md`.

**Discrimination claimed:** each gate is true on exactly its own screen and false on
every other.

Don't re-run the happy path. Build the specificity matrix: reach all 14 screens and
evaluate every gate against every screen. Report each gate's false-passes (screens it
wrongly accepts) with the mechanism, then tighten and re-challenge until each fires on
its own screen only.

## Expected Shape

- A matrix verdict: for each gate, the set of screens it passes on (ideal: one — its own)
- False-passes named with their **mechanism**, e.g.:
  - `discard`/`storage` matched **8 of 14** screens — the word "Storage" is a permanent
    HUD chip, not unique to the discard menu (*incidental overlap*)
  - `traveler`/`road` matched the map — its idle hint reads "what waits on the road"
    (*incidental overlap*)
- A rejected "stronger" fix noted: keying on internal state (`s.tentTab === "ledger"`)
  false-passed on later screens because that state is *sticky* — it reads last-set, not
  currently-rendered (*stale state*). Looked stronger, was more fragile.
- Tightened gates, each re-proven specific — unique authored phrases the screen owns
  (`/storage overflowing/i` the menu headline, `/a traveler on the road/i` the panel title)
- The challenge kept as a re-runnable guard so a future loose phrase can't slip back in

## Notes

The tell that the skill worked: it changed the verdict. Before, "14/14 green" read as
"covered." After, the matrix showed two gates were accepting 8 wrong screens each — the
suite was partly vacuous. A good challenge run ends with checks that go **red** on the
adversarial cases, not just a fresh green on the same happy path.
