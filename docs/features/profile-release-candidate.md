# Profile — Release Candidate Redesign

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` and `docs/standards/shared-ui-patterns.md`.

**Scope:** the Profile tab (`/profile`) and what sits under it: the achievements engine and the celebration on the results screen.

---

# Why

Profile was twelve stacked cards of tables: a "Details" list, a quick-actions card, eight statistic tiles, ten rows of "Playing Statistics", a "Current Season" card, "Personal Bests", an "Achievement Showcase" of six lines, favourite courses, favourite partners, an "Equipment" list that Golf Bag already shows, and a "Recent Activity" list. Nearly all of it was placeholder (68 rounds, 83 average, a showcase that said everything was unlocked) and none of it changed when the golfer played. A first-time golfer learned nothing about *themselves*.

# The idea

Profile is the golfer's **player card**: it is about me, it is true, and it gives me something to chase.

# The screen

1. **Player card (hero)** — a big face with a gold ring, name, home course and location, chips for the handicap index and the year they joined. With rounds played it shows Rounds, Wins and Average points and a gold **Share my golf card** (the message carries the real numbers). Before the first round it says "Play a round and this card fills with your game" and offers **Start your first round**. Tapping the card opens Statistics.
2. **Shortcuts** — My stats, Golf bag, Settings (the shared quick-actions row).
3. **Achievements** — a shelf of eight badges, earned ones lit in gold, the rest locked, the count in the heading, and **Next up** with a progress bar towards the closest one ("Regular · 7 of 10"). Tapping a badge opens a sheet that says how to earn it and how close they are.
4. **Your world** — Friends, Groups and Trips as three tiles with real counts, each leading to its tab.
5. **Your playing partners** — the golfers they have played with most, from real rounds; opens the head to head in Statistics.
6. **Recent rounds** — the last three, with result, points and date; opens Statistics.

Partners and recent rounds appear only once there are rounds.

# Achievements are earned, not stored

`features/achievements/logic/achievements.dart` works out every achievement from the golfer's finished rounds (the `CareerStats` that Statistics uses), so nothing can drift and nothing is faked:

| Achievement | How |
|---|---|
| First Round | finish a round |
| Full Eighteen | play all 18 holes in a round |
| Birdie Hunter | 5 birdies or better |
| Eagle Eye | an eagle or better |
| Winner | win (or share first place in) a round against mates |
| On a Roll | win 3 rounds in a row |
| Social Golfer | play with 3 different golfers |
| Regular | play 10 rounds |

`newlyUnlocked(history, round)` compares the achievements with and without a round, and the **results screen celebrates anything that round earned** ("ACHIEVEMENT UNLOCKED" card, badge in gold) — the moment a golfer learns they have earned something.

# Shared pieces and single source of truth

- `QaddyQuickActions` (`core/widgets/actions`) — the shortcut tiles, moved out of the Dashboard because Profile needed the same thing.
- Counts come from their owners: friends from the live friends store, trips from the trips store, groups from Groups' placeholder list; rounds, wins and averages from the rounds history.
- `placeholder_profile.dart` now holds only what no round can say: who the golfer is, the handicap index, favourite courses (Search reads them) and the equipment (Golf Bag reads it). Everything else — the career totals, personal bests, the achievement showcase, recent activity, favourite partners and the season card — is deleted, along with `AchievementPreview` and the Dashboard's three placeholder statistics.
- Test support: `test/support/played_rounds.dart` builds a world with rounds already played, shared by the Statistics, Profile and results tests.

# Also fixed

The banter snackbar from the last hole could linger over the results screen and cover **Back to Home**; it is now dismissed when the round finishes.

# Placeholders and limits

- The handicap index (8.4), home course, location and "since 2024" are still placeholder identity; there is no account yet.
- The group count is Groups' placeholder list (four groups).
- The Current Season card was removed from Profile: a group's season belongs on the Groups screen.
- Eight achievements only, and none for trips or friends yet. Achievements earned before this build are recomputed from history, so they simply appear.
- The old `docs/standards/placeholder-profile-data.md` describes data that no longer exists here.
