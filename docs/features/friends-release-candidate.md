# Friends Home — Release Candidate Redesign

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md`. Trips is the approved design reference (`docs/features/trips-release-candidate.md`); Friends takes its animation language, spacing, elevation and pacing, with an identity of its own.

**Scope:** the Friends Home screen (`/friends`) only. Friends List, Friend Profile, Activity Feed, Requests, Search, Groups and Rivalries are unchanged in design (Friends List, Requests and Activity Feed read the shared friends store so state stays consistent) and are reviewed one at a time later.

---

# Why

Friends Home was a contacts list: three grey statistic tiles ("Total 8 · Confirmed 5 · Pending 2") and a menu of six identical links. Accept and Decline did nothing, and only Tom could be opened. Nothing on it gave a golfer a reason to come back tomorrow.

# Identity

Trips is a *journey*: full-bleed cover gradients and a countdown. Friends is a *clubhouse*: faces first, banter, rivalry. The screen is organised around people and what they did, not around navigation.

# The screen

1. **Header** — "Friends", a one-line pulse ("5 friends · Tom and Ben played recently") and two buttons: Search golfers, All friends.
2. **Your squad** — a strip of avatars. A gold ring means they played in the last two days; a crown marks the best handicap. Each shows name and handicap. Tapping *any* friend opens a quick-look sheet (handicap, home club, favourite course, location, last played, rounds together, friends since); Tom's sheet also offers his full profile. A trailing **Add** tile opens Search.
3. **Requests** — only when there are any, with a count. A request that was sent to you shows Accept and Decline (large, and they work); one you sent is a single quiet line with Cancel. Accepting turns them into a friend straight away — they join the squad — with a haptic and "You and Sam are now friends".
4. **Rivalry** — the screenshot moment: you against Tom, the score counting up (6 – 5), "You lead by 1", a win bar, the last result, and **Send Tom a challenge** — a share-sheet message with the record and a nudge to settle it. Tapping the story opens the full Rivalries screen.
5. **Latest from mates** — the latest three moments. Each has a coloured icon badge by type (round, handicap drop, trophy…) and its own cheer ("Nice round", "Welcome in", "Well played"). Cheering toggles and is remembered; there are no invented counts of other people's reactions.
6. **Your clubs** — the groups, each with a crest in its own colour and the one thing worth knowing: the next round for Saturday Boys, otherwise size and season.

Every destination the old Quick Actions offered is still one tap away: Friends List (header button, "See all" on the squad), Search (header button, Add tile), Requests ("See all"), Groups ("See all" on clubs, or a club), Activity ("See all"), Rivalries (the rivalry card).

A golfer with no friends sees "Build your squad" with a "Find golfers" button instead of an empty strip.

# Motion and feel

Reuses the Trips language: staggered entrance for sections, squad faces and club cards; press-down cards; the score and win bar animate in; the Requests section eases open and shut as requests are answered; haptics on cheering, accepting and declining. Reduce-motion turns every animation off; nothing loops.

# State

`FriendsController` (`features/community/state/friends_controller.dart`) holds every friend, every open request and the cheered moments. It starts from the placeholder data and changes through `acceptRequest`, `declineRequest`, `cancelRequest` and `toggleCheer`. Friends Home, Friends List, Friend Requests and Activity Feed all read it, so an accepted friend appears on all of them. `confirmedFriendsProvider` orders favourites first, then the most recent player (the rule in `friend-data-model.md`).

Pure logic in `features/community/logic/friend_insights.dart` (played recently, best handicap, last-played wording, rivalry summary and challenge message, club line) is unit-tested without UI.

# Shared pieces added to `core`

`QaddySectionHeading` (title, optional count badge, "See all"), `link_actions.dart` (tell, copy, open-link-or-copy, share-or-copy — moved out of Trips so any feature can use them), `user/current_user.dart` (the signed-in golfer's name, so features no longer import each other's placeholder data to learn it).

# Placeholders and limits

- The store is in memory: an accepted request or a cheer is lost on restart (TD-014). Search, Trips and Profile still read the placeholder friends directly, so they don't yet see an accepted friend.
- Only Tom has a full profile and a rivalry record.
- Friends' "played recently" comes from placeholder dates, not real rounds.
