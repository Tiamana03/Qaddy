# Search Data Model

**Version:** 1.0

**Status:** Architecture Approved

---

# Purpose

This document defines the Search feature's data model.

Per `docs/roadmap/release-1-roadmap.md`'s Sprint 11 goal, Search implements "global search across friends, rounds, trips, groups and courses."

No implementation may introduce additional Search fields, or a sixth category, without updating this document.

---

# Overview

Search displays, grouped by category:

- Friends — every `Friend` whose `displayName` matches
- Rounds — the single upcoming round, if its course matches
- Trips — every `Trip` (upcoming or past) whose `name` matches
- Groups — every `Group` whose `name` matches
- Courses — every course name (from Profile's Favourite Courses and the current Trip's golf schedule) that matches

Search owns none of this data. It reads every value directly from its existing feature — see "Model Reuse" below.

---

# SearchResult Model

The one new model this feature introduces — a presentation-only row, not placeholder data.

| Field | Type | Description |
|--------|------|-------------|
| category | SearchCategory | Which of the five groups this result belongs to |
| title | String | The primary matched text (name) |
| subtitle | String? | Supporting detail shown under the title (e.g. a handicap, a date, a course's source) |
| icon | IconData? | Icon shown when no avatar applies (null for Friends, which show a `QaddyAvatar` instead) |
| onTap | VoidCallback? | Navigates to the result's existing screen; null when no detail screen exists for this specific item (see "Partial Detail Data" in `docs/features/search-feature-integration.md`) |

```dart
enum SearchCategory { friends, rounds, trips, groups, courses }
```

Derived, not stored: nothing. A `SearchResult` list is rebuilt from the five source lists on every keystroke; Search holds no state beyond the current query string.

---

# Model Reuse

Search must not redefine or restate any of the following. It reads them directly.

| Source | Reused for |
|---------|-----------|
| `friends` (`placeholder_friends.dart`) | Friends category — matches `Friend.displayName` |
| `groups` (`placeholder_groups.dart`) | Groups category — matches `Group.name` |
| `upcomingTrips` + `pastTrips` (`placeholder_trips.dart`) | Trips category — matches `Trip.name` |
| `upcomingRound` (`placeholder_rounds.dart` — new, see below) | Rounds category — matches `UpcomingRound.course` |
| `profileFavouriteCourses` (`placeholder_profile.dart`) | Courses category (Profile's 5 favourite courses) |
| `melbourneGolfWeekendCourses` (`placeholder_trips.dart`) | Courses category (the current trip's 3 golf-schedule courses) |

Tap targets reuse each category's existing "is this the detailed item" check, verbatim from the list screen that already performs it:

| Category | Detailed check | Destination route |
|-----------|----------------|---------------------|
| Friends | `friend.id == tom.id` | `AppRoutes.friendProfile` |
| Groups | `group.id == saturdayBoys.id` | `AppRoutes.friendsGroupDetails` |
| Trips | `trip.id == melbourneGolfWeekend.id` | `AppRoutes.tripDetails` |
| Rounds | always true — Release 1 has exactly one round | `AppRoutes.rounds` |
| Courses (Profile's favourites) | always true — Profile is always reachable | `AppRoutes.profile` |
| Courses (trip golf schedule) | always true — the courses are only ever Melbourne Golf Weekend's | `AppRoutes.tripGolf` |

---

# A New Public Constant: `upcomingRound`

Rounds' single upcoming round (course, date, tee time, players, weather, format, holes) previously existed only as private literals duplicated across two of `rounds_screen.dart`'s own widgets (`_UpcomingRoundCard` and `_RoundInformationCard` both separately hardcoded `'Richmond Golf Club'` and `'8:20 AM'`).

Search cannot read a value that has no public source without duplicating it, which would violate Single Source of Truth. `lib/features/rounds/models/placeholder_rounds.dart` extracts these literals into one public `UpcomingRound` model and `upcomingRound` constant; `rounds_screen.dart` is updated to read from it instead of its own private literals, removing the pre-existing internal duplication as a side effect.

This is the only new placeholder data constant this feature introduces, and it introduces no new *values* — every field is the exact literal Rounds already displayed. See `search-engineering-decisions.md`.

---

# Business Rules

- Matching is case-insensitive and matches on any part of the name or course, identical to Search Friends' existing rule (`docs/architecture/search.md`'s "Matching Rules").
- A category is shown only when it has at least one match; an empty query matches everything, so all five categories show by default.
- Only the one "detailed" item per category (and the always-reachable Rounds/Courses results) are tappable. Every other result is still shown, but `onTap` is null — identical to how Friends List, Groups and Trips already render their own non-detailed rows.
- Friends' individual `favouriteCourse` fields are deliberately excluded from the Courses category — see `search-engineering-decisions.md`.

---

# Out of Scope (Release 1)

- A real search backend, index, or ranking.
- A dedicated Courses entity/model — "Courses" stays a read of existing course-name strings, never a new owned concept.
- Search filters, recent searches, or search history.
- Search across Statistics, Golf Bag, Notifications or Settings.

See `search-future-roadmap.md`.

---

# Engineering Decisions

See `docs/architecture/search-engineering-decisions.md` for the full reasoning, including the Dashboard entry-point choice and the Courses scope decision.

---

# Flutter Implementation Notes

Search functionality should remain inside:

```
lib/features/search/
```

The only new model type is `SearchResult` (plus `SearchCategory`). `UpcomingRound` is a Rounds-feature model, not a Search one, even though Search is the reason it now exists publicly.

---

# Related Documents

- friend-data-model.md
- group-data-model.md
- trip-data-model.md
- round-data-model.md
- profile-data-model.md
- docs/architecture/data-ownership.md
- docs/features/search-feature-integration.md
- search-engineering-decisions.md
- search-future-roadmap.md

---

**End of Document**
