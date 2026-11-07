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

## The Rounds tab — "My rounds"

Composed as the approved My Rounds mockup (`design/mockups/rounds/rounds-home-v1.png`): the brand bar, "My rounds" with the gold **Create round** button, the line "Play more. Keep track. Make it count.", a search bar with a filter button, three pill tabs (**Upcoming**, **Completed**, **Invitations**) and rounds as photo cards (`QaddyRoundListCard`).

- **A round card:** a 138 x 94 course photo slot, the course, the date, the time, the format with the forecast at the right, the faces and "N players", a status pill and three pill buttons.
- **Upcoming, before a round:** the next round: **View details** (brings "Who's playing" into view), **Share** (when, where and "Who's in?") and the gold **Start round**; status "Planned".
- **Create round** brings the same player list into view: a round is made by choosing who is playing and starting it.
- **Who's playing:** every invited friend with a switch. Friends who have said yes are in; someone who has not replied (Josh) can be added by hand; the golfer is always in. The count updates as you choose.
- **On the course:** the side games, each on its hole.
- **Upcoming, during a round:** the card says "Today", "Hole N of M" and where the golfer stands, status "Live", with **Leaderboard** and **Continue round**; the standings follow once a hole is played.
- **Completed:** every finished round, newest first, with the day and how it went ("You win · 38 pts"), status "Finished". The latest has **View results**; older rounds have no results page of their own yet.
- **Invitations:** says there are none yet. Rounds are not invited to in Release 1.
- **Search** narrows the rounds by course. The **filter** button keeps its place, dimmed, until there is something to filter by.

Not drawn, because nothing is behind them: Get Directions, and the Paid / Pending / Not Paid payment states.

## During — the scorecard

- Full screen (it covers the tab bar), because a round is not the time for navigation.
- A strip of 18 holes: played holes filled in, the current one gold; tap to jump. It scrolls to keep the current hole centred.
- The live scorecard, as the Live Scoring mockup draws it: a top bar (title, the course, the players' faces which open the leaderboard, a round menu), the strip of holes with the current one ringed in gold, "Hole 4" large with "Par 4 | 380 m | SI 10" beneath and the **Next hole** pill beside it, a 290-tall hole view (an aerial placeholder with the hole's length in a frosted card, the side game and the first-tee greeting), then one "Enter scores" panel: a row per golfer with a boxed stepper (minus, the score, plus), a crown for the leader, a small "+1" on the face where a shot is given, and the golfer's running score against par at the right. The foot is **Previous** and the gold **Finish round** (which asks first, unless it is the last hole).
- **Everyone's score on the hole**, you first. Each row has a big number with − and + under the thumb, the word for it (Par, Birdie, Eagle, Double bogey…), the Stableford points it earns and the shots the golfer is given. Untouched scores sit on par, dimmed, so a golfer only taps the exceptions. A birdie or better gets a short glow and a haptic. Taking a score below 1 picks the hole up (no score, no points).
- **Next hole** scores par for anyone not touched. On the last hole it becomes **Finish round**.
- A leaderboard card after each hole shows the top three and where you stand ("2 pts behind Ben").
- A menu for **Finish round now** (only the holes everyone has played count) and **Discard round**, each with a confirmation.
- Scores are saved as they are entered, so a round survives the app being closed in a pocket.

## The table — the leaderboard

Composed as the right-hand Live Scoring mockup: the headline and where you stand, then one **Live leaderboard** card (a **Final leaderboard** once the round is over) with a header row of Pos, Player, Thru and Pts and a row per golfer: the position (ringed in gold for the leader), the face, the name with a crown for the leader, how they stand against par and their strokes, how many holes they have scored, and their points. Below it, **Side games (sample)** as tiles (the game, its hole and whether that hole has been played: Qaddy does not score side games yet, so no entries are shown) and a **Round summary** (holes completed, format, who leads or won, your position).

Stableford points decide it (ties broken by score against par; those still level share a "T" position). Mid-round the headline says who **leads**; at the end, who **wins**.

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
