# Friend Profile and Rivalries — Release Candidate Polish

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` and `docs/standards/shared-ui-patterns.md`.

**Scope:** Friend Profile (`/friends/profile`) and Rivalries (`/friends/rivalries`), the two Friends sub-screens that still used the older table-of-rows layout.

---

# Why

Both screens were stacks of "Label: value" rows (Home Club, Location, Handicap, Member Since, Rounds Played Together…) and a grid of statistic cards. Next to Friends Home they felt like a different app.

# Friend Profile — a mate's player card

1. **Hero** — a big avatar (ringed in gold when they played in the last two days), their name, "Handicap 8", "Played today", and chips for the home club and place, rounds together and "Since 2022".
2. **Three actions** (the shared `QaddyQuickActions`): **Invite to play** and **Challenge** go through the share sheet; **Activity** opens the activity feed.
3. **Head to head** — `RivalryStrip`: both faces, the tally ("6 – 5"), "You lead by 1" and a split bar that slides in. Tapping it opens the rivalry.
4. **In your crews** — the groups you both belong to, each with its crest and motto, opening the group.
5. **Latest from Tom** — what they have been up to (the shared activity tile), with "See all".

The "Confirmed" badge is gone: only confirmed mates can be opened.

# Rivalries — the whole story

1. **The rivalry card** — the same `RivalrySpotlight` as Friends Home (here without the tap-through, since this is the destination), with the challenge button.
2. **The scoreboard** — wins, halved and losses as three big numbers that count up, and "You have taken 55% of the rounds with a winner."
3. **Plan the rematch** — picks the rival for the next round (`RoundSetupController.pick`) and opens Rounds.

The last result appears once, in the rivalry card.

# How it is built

- `RivalryStrip` (`community/ui/widgets/`) is new; `RivalrySpotlight.onOpen` became optional.
- Friend Profile reads Tom from the friends store (`confirmedFriendsProvider`), falling back to the placeholder; the head-to-head and activity are the same placeholder records Friends Home uses, so the numbers agree everywhere (single source of truth).
- Crews in common come from Groups (`membersOf`), not a list kept here.
- Handicaps use `handicapLabel`, so they read the same on every platform.

# Placeholders and limits

- Only Tom has a profile and a rivalry (`placeholder_friends.dart`); other mates open the peek sheet, whose "View profile" button exists for Tom only.
- The rivalry record (6–5, one halved, twelve rounds) is placeholder data, separate from the rounds the golfer has scored in the app.
- Release 1 has no messaging, so "Invite to play" and "Challenge" are share-sheet messages.
