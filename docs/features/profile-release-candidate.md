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

Composed as the approved Profile mockup (`design/mockups/profile/profile-home-v1.png`), top to bottom:

1. **Brand bar** — the brand, Notifications (a gold unread count) and Settings' gear where the golfer's face is on other tabs.
2. **Identity** — the golfer's face in a white ring with the camera badge (it holds its place: a photograph is Release 2), their name, where they play and since when, and **Edit profile** (the sheet Settings uses; below the name on a narrow screen).
3. **Four stat tiles** — Handicap, Avg points, Rounds, Wins (the shared `QaddyStatTiles`, Profile layout); a dash for what is not known yet. Shown once there is a handicap or a finished round; they open Statistics.
4. **Your golf journey** — the next badge to earn, how many badges are earned ("3 of 8") and a gold bar towards it; tapping says how to earn it. This is the mockup's XP card: Qaddy has no XP, so it shows real progress instead.
5. **The badges** — a row of hexagons, earned ones outlined in gold, the rest locked; six fit across and the others scroll. Tapping one says how to earn it and how close they are.
6. **Recent rounds** — a card with "View all": the last three, each with a thumbnail slot, the course and day, the points in a box and where they finished (a green "Won" when they did).
7. **The gold button** — **View full statistics** once there are rounds; before the first round, **Start your first round**.
8. **Quiet shortcuts** — Golf bag, Share card (the message carries the real numbers) and My stats.
9. **Your world** (once they have made something of their own) and **Your playing partners** follow.



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
