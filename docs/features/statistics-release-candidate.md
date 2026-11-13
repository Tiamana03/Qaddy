# Statistics — Release Candidate Redesign

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md`, with the shared patterns in `docs/standards/shared-ui-patterns.md`. Statistics follows Rounds, which is the reference for the core golf experience.

**Scope:** the Statistics screen (`/profile/statistics`), the data under it, and the Dashboard's "Your game" card.

---

# Why

Statistics was a spreadsheet of placeholder numbers: 68 rounds, an average score of 83, a "Career Totals" table, a "Season Performance" leaderboard borrowed from Groups and a rivalry borrowed from Friends. None of it came from anything the golfer had done in Qaddy, and none of it changed when they played.

# The idea

Statistics now **tells the story of the rounds the golfer has actually played**. Every number is worked out from finished rounds; there is no estimated, assumed or made-up figure. Play a round and the screen changes.

# What it says

With no finished round it is an invitation — "Your story starts on the first tee" and a **Start a round** button — instead of a table of zeros.

With rounds:

The screen follows the approved Profile mockup's Stats page (visual fidelity pass, November 2026): the app bar, the Profile tab row (Overview, Stats, Equipment, Activity, Achievements, with Stats chosen; the others open Profile, the Golf Bag and My Rounds), then five panels at the mockup's size, with cards 9 px from the screen edge as the mockup draws them.

1. **Handicap** — the handicap index from Profile, big, an info button that explains it, a pill for how form is moving ("On the up", "Quiet patch", "Holding steady", "Early days") with the points a round behind it, and a line beside it: the points per round, oldest first, with a dot on each. "View History" opens My Rounds. Qaddy has no handicap history, so the mockup's falling handicap line is the form line instead.
2. **Scoring Overview** — four tiles: average points, best round, birdies and par-or-better share. "View Details" scrolls to How you score. (The mockup's "Average Score" and "Average to Par" are strokes; Qaddy scores in Stableford, so those are points.)
3. **Driving** and 4. **Approach** — the mockup's tiles (average drive, fairways, greens in regulation, proximity, putts) and a dimmed hole picture, with a dash in each tile. Qaddy does not record them, so nothing is guessed; tapping says they arrive with shot tracking.
5. **Performance by Hole** — eighteen bars around an E line: a hole's average Stableford points against the two a par is worth, green above, gold below, grey level, with a short stub for holes not yet played, and a key. "View Full" scrolls to Your holes.

Under those, the rest of the story:

6. **Your form** — a one-line verdict ("On the up: 9 points a round better over your last three", "A quiet patch…", "Steady…", or how many rounds until there is a form guide), then a bar for each of the last eight rounds (points per eighteen holes), the latest in gold, a trophy over rounds you won.
7. **How you score** — "Par or better on 54% of holes" and one coloured bar of every hole you have played: eagle or better, birdie, par, bogey, double or worse, picked up.
8. **Your holes** — your favourite hole and your nemesis (by average points), and your average on par 3s, 4s and 5s and on the front and back nine. Shown once four holes have been played.
9. **Head to head** — for each playing partner, rounds together and who has won more of them, as a split bar (gold for you, blue for them).
10. **Highlights** — your best round, wins and win rate, the most birdies in a round, your longest win streak (from two) and holes played. A gold button below opens the last round's results.

# How it is worked out

Pure, tested functions in `features/statistics/logic/`:

- `career_stats.dart` — `CareerStats.of(history, you:)`: the average, best round, wins, form trend, the score mix, per-hole averages, par-type and nine-hole averages, records and head-to-head records.
- `stats_story.dart` — the sentences.

Points are Stableford points **scaled to eighteen holes**, so a round cut short compares fairly with a full one. A round counts only if the golfer was in it and at least one hole was played by everyone. A "win" needs someone to beat, and a shared first place counts as a win. Form compares the last three rounds with the three before them and needs four rounds. Head to head compares Stableford points for the round.

# The rounds store keeps every round

To tell a story Statistics needs more than the last round, so `RoundsState` now keeps the **history** — every finished round, newest first, up to 200 — and persists it (storage document version 2; a version 1 document with a single finished round still loads). `completedRoundProvider` is now simply the newest round in `roundHistoryProvider`.

# Dashboard

"Your game" now shows the handicap index and, once there are rounds, wins and rounds ("1 win in 1 round"), rounds played, average points and best round, plus the last round (winner or place, points, strokes, "Today"). Before the first round it shows the handicap and "Play a round to build your game", not invented numbers. The placeholder "Dunes" round and the handicap trend are gone.

# Removed

The placeholder statistics model and data (`placeholder_statistics.dart`, `StatTrend`, the trend formatting), the "Career Totals", "Scoring Statistics", "Scoring Breakdown", "Trends", "Personal Records", "Season Performance" and "Rivalry Performance" cards, and Statistics' dependencies on Groups and Friends. A group's season belongs to Groups, and a friend's rivalry to Friends.

# Placeholders and limits

- The handicap index (8.4) is still Profile's placeholder value. It is not derived from rounds, because a handicap index is an official figure.
- Stats cover rounds scored in Qaddy only. Rounds from before the app do not exist here.
- Fairways, greens, drive length, proximity and putts are not recorded by the scorecard, so Driving and Approach show dashes (as the mockup's layout) until shot tracking exists.
- Head to head counts rounds, not strokes, and compares Stableford points, so handicaps are respected.
- Profile and the Dashboard's highlights still show placeholder figures (rounds played 68 etc.); Profile is a later screen.
