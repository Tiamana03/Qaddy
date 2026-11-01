# Rounds — Release Candidate Redesign

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md`. Trips, Friends Home and the Dashboard are the reference screens; Rounds reuses their patterns (`docs/standards/shared-ui-patterns.md`) and adds two more to the shared set.

**Scope:** the whole round journey — the Rounds tab, the live scorecard, the leaderboard and the results — plus the Dashboard's links into it.

---

# Why

Rounds was the feature golfers would use most and it was the least finished: the Rounds tab was a form with disabled Start, Edit and Cancel buttons; the scorecard scored one golfer in isolation and kept nothing; the leaderboard and Round Complete were screens nothing could open and showed a fixed, made-up result. It felt like administration software, not a golf round.

# The goal

A golfer should prefer this to a paper card: **excitement before** the round, **confidence during** it, **celebration after**.

# The journey

## Before — the Rounds tab

- A hero for the first tee: "Saturday, 8:20 AM", the course, the weather, the format, the faces of who is playing and one gold **Start round** button.
- **Who's playing:** every invited friend with a switch. Friends who have said yes are in; someone who has not replied (Josh) can be added by hand; the golfer is always in. The count updates as you choose.
- **On the course:** the side games, each on its hole.
- After a round the tab also shows **Last round** — the winner and the points — one tap from the results.

## During — the scorecard

- Full screen (it covers the tab bar), because a round is not the time for navigation.
- A strip of 18 holes: played holes filled in, the current one gold; tap to jump. It scrolls to keep the current hole centred.
- A hole banner: the hole number big, par, metres, stroke index, front or back nine — and the side game if one is played there.
- **Everyone's score on the hole**, you first. Each row has a big number with − and + under the thumb, the word for it (Par, Birdie, Eagle, Double bogey…), the Stableford points it earns and the shots the golfer is given. Untouched scores sit on par, dimmed, so a golfer only taps the exceptions. A birdie or better gets a short glow and a haptic. Taking a score below 1 picks the hole up (no score, no points).
- **Next hole** scores par for anyone not touched. On the last hole it becomes **Finish round**.
- A leaderboard card after each hole shows the top three and where you stand ("2 pts behind Ben").
- A menu for **Finish round now** (only the holes everyone has played count) and **Discard round**, each with a confirmation.
- Scores are saved as they are entered, so a round survives the app being closed in a pocket.

## The table — the leaderboard

Stableford points decide it (ties broken by score against par; those still level share a "T" position). Each row has the position, the face, strokes and score against par, the points and a bar showing how close they are to the leader. Mid-round the headline says who **leads**; at the end, who **wins**.

## After — the celebration

A burst of confetti, the winner's face and name ("You win!", "Tom wins", "Alex and Ben share the win"), then **Your round**: points, place, birdies, pars, bogeys, front and back nine points and your best hole; the final standings; and a gold **Share the result** that sends the winner and the top three to the group. **Back to Home** (or the close button) finishes.

# How it is built

- **Scoring logic is pure and tested:** `logic/stableford.dart` (shots received, points, the word for a score), `logic/standings.dart` (the table, ties, birdies), `logic/round_insights.dart` (headline, recap, chase line, share message).
- **State:** `RoundsController` (`state/rounds_controller.dart`) holds the round in progress and the last finished one. It starts a round, changes scores, moves between holes, finishes or discards. `RoundSetupController` holds who is picked. Screens never change a round any other way.
- **Persistence:** `repositories/rounds_storage.dart` and `rounds_codec.dart` keep both rounds on the device (the same pattern as Trips), versioned. An unreadable document starts fresh instead of crashing.
- **Routes:** `/rounds/scorecard`, `/rounds/leaderboard` and `/rounds/complete` sit on the root navigator, above the tab bar.
- **Dashboard:** the hero, the first shortcut and the last-round row all know about the round: *Start a round / Continue round*, "ROUND IN PROGRESS · Hole 7 of 18", and the real result of the round just played.

# Shared pieces added

`QaddyInfoChip` (the translucent fact pill on heroes) and `QaddyConfetti` (a one-shot burst that respects reduce-motion) in `core/widgets`; `QaddyHeroCard` can now be non-tappable; `ordinal` and `formatScore` live in `core/utils/formatting.dart` (the Rounds work found three copies of `ordinal` and a duplicate score formatter, which are now one).

# Removed

The old Round Setup form (Upcoming Round card, Round Information card, the info-row tables, Edit Round and Cancel Round buttons), the single-player stepper scorecard, the fixed-result leaderboard and Round Complete, and the relative-to-par ranking. Every one of those was replaced by the pieces above.

# Placeholders and limits

- One course (Richmond Golf Club) and one format (Stableford). Handicap shots use the rounded handicap index, not a slope-adjusted course handicap.
- The weather, the invited friends and the side games are placeholder data. Side games are shown on their hole but winners are not recorded yet.
- Only one round can be in progress. Every finished round is kept (up to 200) and feeds Statistics; there is no browsable round-by-round history screen yet.
- Scores are per hole for everyone, entered by one golfer; there is no shared live scoring between phones (a Release 2 feature).
- Not tried on a real phone, so the haptics and one-handed feel are unverified.
