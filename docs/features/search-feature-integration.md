# Search Feature Integration

## Overview

This document defines how the complete Search feature (Release 1 Feature 10 / Sprint 11) is integrated within Qaddy.

Search is a single, global screen that lets a user find a Friend, Group, Trip, Round or Course by typing a name, and jump straight to it.

This document does **not** define new data. Every result Search shows is read from a feature that already owns it — see `docs/architecture/search-data-model.md` and `docs/architecture/data-ownership.md`.

**This is not the same feature as Search Friends** (`/friends/search`, `docs/architecture/search.md`). Search Friends is a narrower, already-implemented Friends-feature sub-screen that only searches golfers to add as a friend. This feature is a new, separate, global screen reachable from Dashboard that searches across five categories at once. Search Friends is unaffected by this feature and is not modified by it.

---

# Goals

The Search feature should allow users to:

- Open a single search screen from anywhere in the app (via Dashboard)
- Type a query and see matching Friends, Rounds, Trips, Groups and Courses, grouped by category
- Jump directly to a result's existing screen, where one exists
- See every result when the query is empty, grouped the same way

---

# Scope

This feature includes:

- One Search screen (`/home/search`)
- A search icon on Dashboard's app bar, opening it
- Case-insensitive, substring matching against five existing data sources (no new placeholder data)
- A minimal public constant for Rounds' single upcoming round (see Engineering Decisions) so Search can read it without duplicating it

This feature does **not** include:

- Real backend search, indexing or ranking
- A dedicated Courses feature/model — "Courses" is a read of course names that already exist on Profile and Trips, not a new entity
- Search filters, recent searches, or search history
- Search across Statistics, Golf Bag, Notifications or Settings — none of Release 1's five named categories (friends, rounds, trips, groups, courses) include these, and Sprint 11's own goal names only the five
- Searching individual Friends' own `favouriteCourse` values under Courses — see Engineering Decisions for why

See `docs/architecture/search-future-roadmap.md` for what is deferred.

---

# Feature Flow

Dashboard

↓ (tap the search icon)

Search

↓ (tap a result)

The result's existing screen (Friend Profile, Group Details, Trip Details, Rounds, or Profile/Trip Golf Schedule for a Course)

Search is a single destination reached from Dashboard, the same pattern already used for Notifications (`docs/features/notifications-feature-integration.md`) — an app bar icon opening one nested screen, not a new bottom-navigation tab.

---

# Integration Objectives

Search should never restate a value that already has a canonical source in another feature. It reads directly from Friends, Groups, Trips, Rounds and Profile — see `search-data-model.md`.

---

# Navigation Flow

## Dashboard

Displays a search icon in the app bar, alongside the existing notification bell.

Selecting it opens Search.

---

## Search

Displays, in order:

- A search field (reuses `QaddySearchField`)
- Results grouped under five category headers (Friends, Rounds, Trips, Groups, Courses) — only categories with at least one match are shown
- An empty state if no category has any match

Selecting a result:

- Navigates to that result's existing screen, if one exists for that specific item (see "Partial Detail Data" below)
- Does nothing, if no detail screen exists for that specific item — identical to how Friends List, Groups and Trips already handle their own non-detailed list rows

---

# Route Integration

Search is nested under the existing Home route, per `navigation.md`.

| Route | Screen |
|---------|---------|
| /home/search | Search |

No new top-level route or bottom-navigation destination is introduced.

---

# Shared Placeholder Data

Search introduces no new placeholder data of its own. It reads:

- `friends` (`placeholder_friends.dart`) — Friends category
- `groups` (`placeholder_groups.dart`) — Groups category
- `upcomingTrips` + `pastTrips` (`placeholder_trips.dart`) — Trips category
- `upcomingRound` (new — see Engineering Decisions) — Rounds category
- `profileFavouriteCourses` (`placeholder_profile.dart`) + `melbourneGolfWeekendCourses` (`placeholder_trips.dart`) — Courses category

See `search-data-model.md` for the full mapping.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- `QaddyScaffold`
- `QaddySearchField`
- `QaddyCard`
- `QaddyAvatar` (Friends results)
- `QaddyEmptyState`

Create new widgets only when functionality does not already exist — a single `_SearchResultRow` private widget is added to lay out {icon or avatar, title, subtitle} consistently across all five categories, since no existing row widget covers an optional-avatar/optional-icon combination.

---

# Model Reuse

Reuse existing models and placeholder data wherever possible. Search must not redefine or restate Friends, Groups, Trips, Rounds or Profile data — see `search-data-model.md`.

Reuse:

- `Friend` (`friend.dart`)
- `Group` (`group.dart`)
- `Trip` (`trip.dart`)
- `UpcomingRound` (new, `placeholder_rounds.dart` — see Engineering Decisions)
- `profileFavouriteCourses`, `melbourneGolfWeekendCourses` (plain `String`/`TripCourse` lists)

Search adds exactly one new model of its own: `SearchResult` (`search_result.dart`) — a presentation-only row shape (title, subtitle, icon, category, onTap), not placeholder data. It exists to let the screen render five differently-shaped sources through one consistent list, the same role `LeaderboardEntry` plays for Rounds' leaderboard.

---

# Button Behaviour

| Button | Action |
|---------|---------|
| Search icon (on Dashboard) | Open Search |
| Result row (detailed item) | Open that item's existing screen |
| Result row (non-detailed item) | No action — matches Friends List/Groups/Trips' own existing rows |
| Back | Return to Dashboard |

---

# Placeholder State

All Search results remain in memory and are recomputed from existing feature data on every keystroke.

No backend search, indexing or persistence exists during this feature's implementation.

Closing the application resets nothing Search-specific, since Search owns no state beyond the current query string.

---

# Partial Detail Data

Release 1's Friends, Groups and Trips features each have exactly one "detailed" item with a real detail screen (Tom, Saturday Boys, Melbourne Golf Weekend respectively) — every other list row is summary-only and not tappable, per `friends-engineering-decisions.md`'s and the equivalent Groups/Trips "Shared Placeholder Subjects" pattern.

Search surfaces every matching item regardless of whether it is the detailed one, exactly as Friends List, Groups and Trips already do on their own list screens — but only the detailed item's result row is tappable. This is not a Search-specific limitation; it is the existing Release 1 constraint, surfaced through a new screen rather than worked around.

---

# Acceptance Criteria

The Search feature is complete when a user can:

- Open Search from Dashboard
- See every Friend, Round, Trip, Group and Course when the query is empty, grouped by category
- Type a query and see only matching results, still grouped by category
- See an empty state when nothing matches
- Open a detailed result's existing screen by tapping it
- Return to Dashboard

Additionally:

- No duplicate placeholder data exists — every value is read from Friends, Groups, Trips, Rounds or Profile, not restated
- Existing widgets are reused wherever possible
- All tests pass
- The feature behaves as a natural, global extension of Dashboard

---

# Future Integration

Future releases will replace placeholder functionality with:

- Real backend search across a live user/course database
- Search filters and sort
- Recent/saved searches
- Search across Statistics, Golf Bag, Notifications and Settings, if a genuine need emerges
- Full per-friend/per-group/per-trip detail screens, which would make every result tappable, not just the one detailed item per category

See `docs/architecture/search-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Search functionality into one complete feature.
