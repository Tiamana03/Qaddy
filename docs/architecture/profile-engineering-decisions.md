# Profile Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Profile feature.

Per-document Engineering Decisions sections still apply where they exist (`profile-data-model.md`, `profile-achievements.md`); this document exists for decisions that span the whole feature rather than belonging to one model.

---

## Release 1 Is One Aggregated Screen, Plus Three Nested Destinations

`docs/architecture/navigation.md` defines a single route for Profile (`/profile`) and explicitly defers Achievements and Premium to future releases as their own routes. Statistics, Golf Bag and Settings are the three exceptions — all three are implemented now, nested at `/profile/statistics`, `/profile/bag` and `/profile/settings` respectively, each reached via its own quick link on Profile, per `docs/features/statistics-feature-integration.md`, `docs/features/golf-bag-feature-integration.md` and `docs/features/settings-feature-integration.md`.

The Profile screen itself is still a single, scrollable aggregation page — like the Dashboard, it combines many small summary sections rather than linking out to sub-screens for its own content. Statistics, Golf Bag and Settings are the only links out.

**Why:** matches the documented route table exactly; avoids inventing navigation that isn't in `navigation.md`.

**How to apply:** every section in `docs/features/profile-feature-integration.md`'s Screen Contents renders directly on `/profile`, except "View Statistics," "View Golf Bag" and "View Settings," which open their respective nested routes.

---

## Tiamana Is the Shared Placeholder Subject

Every other feature designates a shared placeholder subject (Tom for Friend Profile, Melbourne Golf Weekend for Trips, Saturday Boys for Group Details). Profile's subject is simpler: it is always **Tiamana**, the same placeholder user already used as "the current user" throughout Rounds, Trips, Friends and Groups.

**Why:** Profile is the current user's own identity page — there is no other candidate subject.

**How to apply:** Handicap, Member Since and every lifetime statistic on Profile must match the equivalent values already established for Tiamana in `placeholder-data.md`, `placeholder-trip-data.md`, `placeholder-group-data.md` and `placeholder-friend-data.md`. This document's own placeholder file, `placeholder-profile-data.md`, was corrected to match those values exactly rather than the reverse (see that document's Player Profile and Playing Statistics notes) — those four documents were already cross-consistent before Profile existed, so they are the source of truth.

---

## Friends, Groups and Rounds-Played Counts Are Computed, Not Duplicated

Profile Summary's Friends, Groups and Trips counts are computed from each feature's own placeholder data (`placeholder_friends.dart`'s `totalFriendsCount`, `placeholder_groups.dart`'s `groups.length`, `placeholder_trips.dart`'s `upcomingTrips.length + pastTrips.length`) rather than declared as separate literals in a new Profile placeholder file.

Profile's Current Season card is computed the same way, reading Tiamana's rank and points directly from `placeholder_groups.dart`'s `saturdayBoysLeaderboard` rather than restating "5th" and "97" as new literals.

**Why:** these exact figures already drifted out of sync once before Profile existed (see the Handicap Consistency fix applied across Dashboard, Rounds, Trips, Friends and Groups). Computing them from each feature's own already-correct data makes a repeat drift impossible.

**How to apply:** `lib/features/profile/models/placeholder_profile.dart` imports `package:qaddy/features/community/models/placeholder_friends.dart`, `package:qaddy/features/groups/models/placeholder_groups.dart` and `package:qaddy/features/trips/models/placeholder_trips.dart` for these values. Rounds Played, Average Score, Best Round, Fairways Hit and Greens in Regulation have no equivalent public constant to import (Dashboard's own values are private literals inside `dashboard_screen.dart`'s widget tree), so these remain literals in Profile's own placeholder file — but they must match `placeholder-data.md`'s "Statistics" section exactly, per that document's own note.

---

## Favourite Playing Partners Is Not the Friend Model's `favourite` Flag

Profile's "Favourite Playing Partners" list (Tom, Luke, Ben, Nick) is a Profile-specific, independently curated list. It is not derived from `friend-data-model.md`'s `favourite` boolean (which only Tom and Luke currently have set) or from `roundsPlayed` ordering (which would rank Luke, Tom, Liam, Ben highest).

**Why:** the two concepts answer different questions — `Friend.favourite` controls display order on Friends List; "Favourite Playing Partners" is the user's own free-form highlight reel on their Profile. Conflating them would force one list to always match the other, which nothing in either document requires.

**How to apply:** Profile's Favourite Playing Partners list is its own placeholder data, reusing the existing `Friend` objects from `placeholder_friends.dart` for display (avatar, initials) but not filtered or derived by `favourite`.

---

## Achievements Use a Simplified Preview, Not the Full Achievement Model

`profile-achievements.md`'s Achievement Model has 12 fields, including `rarity`, `points`, `progress` and `target` — none of which have any placeholder value defined anywhere for the 6 named achievements in `placeholder-profile-data.md`'s "Achievement Showcase" table (only a title and an Unlocked status are given).

Since `navigation.md` already defers a dedicated Achievements screen to a future release, Release 1's Profile screen displays a small `AchievementPreview` (title, unlocked) instead of instantiating the full `Achievement` model with invented rarity/points/progress values. Every preview tile uses the same generic trophy icon rather than inventing a per-achievement icon that no document specifies.

**Why:** instantiating every field would require inventing business data (rarity, points, progress, target) that no document defines — forbidden by every workflow document in this repository. Deferring the full model to the future Achievements screen (where that data can be properly designed) avoids this.

**How to apply:** `lib/features/profile/models/achievement_preview.dart` defines `AchievementPreview` for Release 1. The full `Achievement`/`AchievementCategory`/`AchievementRarity` model in `profile-achievements.md` remains reserved for that future screen.

---

## Profile Model Fields Not Yet Populated

`profile-data-model.md`'s Profile Model table includes several fields with no placeholder value anywhere and no Release 1 screen that would display them: `firstName`/`lastName` (only a single display name, "Tiamana", is documented — the same limitation `friend-data-model.md`'s Friend Model has for every placeholder friend), `email` (no authentication in Release 1), `avatarUrl` (always null — initials-only, per placeholder-data.md's "Placeholder Images" rule), `bio`, `favouriteClub` (undifferentiated from `favouriteCourse`, which is the only one with a placeholder value), and `lastActive`.

**Why:** matches the precedent already set by the Friend model (`friend-data-model.md`'s Flutter Implementation Notes) — implement only the fields with real placeholder backing and actual on-screen use, without inventing values for the rest.

**How to apply:** `lib/features/profile/models/profile.dart` implements `id`, `userId`, `displayName`, `handicap`, `homeCourse`, `favouriteCourse`, `location`, `joinedDate`, `status` and `profileVisibility` only. `profile-data-model.md` itself is unchanged — it remains the complete, aspirational model for when those fields are needed.

---

# Related Documents

- profile-data-model.md
- profile-achievements.md
- docs/features/profile-feature-integration.md
- profile-future-roadmap.md
- docs/features/statistics-feature-integration.md
- docs/features/golf-bag-feature-integration.md
- docs/features/settings-feature-integration.md

---

**End of Document**
