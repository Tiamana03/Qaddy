# Groups — Release Candidate Redesign

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` and `docs/standards/shared-ui-patterns.md`.

**Scope:** the Groups list (`/friends/groups`) and a group's own page (`/friends/groups/:groupId`), plus where Friends, the Dashboard and Search lead into them.

---

# Why

Groups was administration. The list was four plain cards of which only one opened; the page behind it was a stack of tables — **Group Overview** ("Owner", "Member Count", "Status"), **Season Summary**, **Leaderboard**, **Upcoming Group Round** — all hard-wired to Saturday Boys. Nothing said why anyone had made the group.

People make a group for friendship, tradition and competition. Opening it should remind them of that straight away.

# The idea

The group page is a **clubhouse**: who we are, what we are playing next, who is winning, and the four things mates actually do together — play, travel, invite, wind each other up.

# The list — "Your crews"

Each group is a card in **its own colour** (teal, indigo, orange, pink — by position, the same colours as the crests on Friends), with a crest, its one-line motto ("Saturday mornings at Richmond. The banter is compulsory."), and — when the group's people are known — **their faces** beside the member count (otherwise size and season), then a gold "Next round Saturday, 8:20 AM" when a round is planned. **Every** card opens its own page. The header line says who plays next.

# The page

1. **Hero** — the crest, the name, the motto in italics, and chips: mates, "Since 2024", home course, format.
2. **Four actions** (the shared `QaddyQuickActions`):
   - **Plan a round** — picks the whole group for the next round (`RoundSetupController.pick`) and opens Rounds.
   - **Plan a trip** — opens Create Trip.
   - **Invite a mate** — shares a ready-written invitation to join the group.
   - **Banter** — shares a line about the table: "Luke leads the Saturday Boys table by 7 points. Time someone did something about it. – Tiamana" (or, when the golfer leads, "I'm top of the … table by N points. Come and get me.").
3. **Next round** (when there is one) — the invitation banner: when, where, the faces playing, and **"Who's in? Rally the group"**. Tapping the story plans the round.
4. **The 2026 Season** — the podium, "You're 5th, 4 points behind Ben", a progress bar ("8 of 18 rounds played") and rounds to go. On the group's own page the card is not a button (the Banter action above sends the line); on Friends Home, where the card is the way in, it opens the group.
5. **The squad** — every member as a face with their handicap; the **captain** (the owner) is labelled, the **table leader** wears a crown. Tapping a mate opens their card (the Friends peek sheet); tapping yourself opens Profile. The faces arrive one after another.
6. **The rest of the field** — ranks 4 and below in **one compact card**: rank, face, name, points and a bar that grows in to show how close each golfer is to the leader. The golfer's own row is **You** on a gold tint.
7. **Head to head** — the golfer's *real* finished rounds against this group's mates, using the Statistics `Rival` record. Before any round is played together it says so kindly instead of showing zeros.

A group **without a season yet** (every group but Saturday Boys in Release 1) shows the hero and the four actions, then "The table starts with a round" with a gold **Plan a round** — no invented table. An unknown group id shows "This group has gone quiet" with a way back to the list.

# How it is built

- `GroupDetailsScreen({groupId})` — the route carries the group's id; the page reads the group and its details through the accessors in `placeholder_groups.dart` (`groupById`, `membersOf`, `leaderboardOf`, `seasonSummaryOf`, `upcomingRoundOf`). Only Saturday Boys has details; every other group answers empty/`null` and the page says so.
- `AppRoutes.friendsGroup(id)` replaces the old fixed `groups/details` route. Friends' clubs strip, the next-round banner and season race, the Dashboard highlight and Search results all open the right group.
- `features/groups/logic/group_insights.dart` — the pure, tested group sentences: the card line, `rallyMessage`, `SeasonRace` (podium, headline, chase, rounds to go), `banterMessage`, `groupInviteMessage`. These moved here from `community/logic/friend_insights.dart`, which keeps only what is about friends.
- `features/groups/ui/widgets/` — `GroupCard`, `GroupCrest` (and `groupAccent`), `NextRoundBanner`, `SeasonRaceCard`, `ClubsStrip`, `GroupLeaderboardRow`. The banner, season race and clubs strip moved here from `community/ui/widgets/`; Friends Home still shows them.
- Shared pieces reused: `QaddyHeroCard`, `QaddyQuickActions`, `QaddyInfoChip`, `QaddyCard`, `QaddySectionHeading`, `QaddyGoldButton`, `QaddyEmptyState`, `QaddyAvatar`, `RivalRow`, `showFriendPeek`, `shareOrCopy`.
- `handicapLabel` moved to `core/utils/formatting.dart` (Friends and Groups both show handicaps); the community logic re-exports it.

# Single source of truth

Group data lives in Groups. Friends shows groups only through the Groups widgets and accessors; it no longer owns group logic. The season table is still **placeholder** data (below); the head-to-head is not — it comes from the rounds the golfer has really played.

# Placeholders and limits

- Descriptions, members, handicaps, the season table, the upcoming round and "Since" years are placeholder data (`docs/standards/placeholder-group-data.md`); only Saturday Boys has a season and a squad.
- Release 1 has no backend: there is no creating, joining, editing or leaving a group, no chat and no group settings. Invite and banter go through the share sheet.
- "Plan a round" picks the group's members who are on the placeholder invitation list; the golfer is always in.
- The old section documents (`docs/architecture/groups.md`, `group-details.md`) describe the earlier admin layout and are superseded by this page for the screens' contents.

## The Groups list, as the mockup draws it

`/friends/groups` is composed as the approved My Groups mockup (`design/mockups/groups/groups-home-v1.png`, left): the brand bar, "My groups" with the gold **Create group** button (it says creating groups is coming), a search bar that narrows by name, course or description, three pill tabs (**My groups (n)**, **Invitations**, **Past groups**; the last two are honest empty states) and each group as a photo card (`GroupCard`): a 112-wide photo slot, the name (a crown and "Admin" when the golfer runs it, otherwise "Member"), the course, the next round, "N members · M confirmed", the faces and a status pill ("Round ready", or "Waiting on N"). A group with no round shows what it is about instead. The mockup's Group Details (right) is still to be rebuilt.
