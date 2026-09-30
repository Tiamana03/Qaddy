# Profile Feature Integration

## Overview

This document defines how the complete Profile feature is integrated within Qaddy.

Profile is the current user's own identity page. It brings together personal details, playing statistics, achievements, favourite courses and playing partners, equipment, and current season standing into one aggregated screen.

This document does **not** define new functionality.

Instead, it explains how the Profile screen's sections combine into one seamless experience and how it reuses data already established by Rounds, Trips, Friends and Groups.

---

# Goals

The Profile feature should allow users to:

- View their own identity (name, avatar, handicap, home club, location)
- View a summary of their Friends, Groups, Trips, Rounds and Achievements
- View detailed playing statistics and personal bests
- View their current season standing
- View their recent activity
- View their favourite courses and playing partners
- View their equipment
- Return to the Dashboard

The experience should feel like a natural home base that ties every other feature together, without duplicating any of their data.

---

# Scope

This feature includes:

- Profile (single screen)
- Placeholder data
- Feature integration

This feature does **not** include:

- The Statistics screen's own content — Profile only links to it; see `docs/features/statistics-feature-integration.md`
- A dedicated Achievements screen
- A dedicated Settings screen
- A dedicated Premium screen
- An Activity Summary ("This Year") section — deferred, see `placeholder-profile-data.md`'s "Activity Summary"
- Editing any Profile information
- Supabase
- Authentication

All data remains placeholder driven. See `docs/architecture/profile-future-roadmap.md` for how these are expected to arrive later.

---

# Feature Flow

The complete Profile journey should follow the workflow below.

Dashboard

↓

Profile

↓

Dashboard

Profile is a single destination — every section below renders on the same screen, per `docs/architecture/profile-engineering-decisions.md`'s "Release 1 Is One Aggregated Screen".

---

# Integration Objectives

Profile should feel like the user's own golfing identity, not a disconnected settings page.

Every count and figure shown must match the equivalent value already established elsewhere in the application — never a new, independent number for the same concept.

---

# Navigation Flow

## Dashboard

Displays the Profile tab in the persistent bottom navigation (already implemented — see `navigation.md`'s Bottom Navigation table).

Selecting it opens Profile.

---

## Profile

Displays, in order:

- Profile Header — avatar, display name, handicap, home club, status badge
- Profile Summary — Friends, Groups, Trips, Courses Played, Rounds Played, Seasons Completed, Achievements
- Playing Statistics — Average Score, Average Stableford, Best Round, Best Stableford, Birdies, Eagles, Pars, Fairways Hit, Greens in Regulation, Average Putts
- Current Season — season, group, position, points
- Personal Bests — Best Round, Best Front Nine, Best Back Nine, Most Birdies, Longest Drive, Longest Putt
- Achievement Showcase — recent unlocked achievements
- Favourite Courses
- Favourite Playing Partners
- Equipment
- Recent Activity
- A "View Statistics" quick link

Selecting "View Statistics" opens Statistics — see `docs/features/statistics-feature-integration.md`. No other section links to another screen.

---

# Route Integration

The Profile feature uses the route already defined in `navigation.md`.

| Route | Screen |
|---------|---------|
| /profile | Profile |

No new routes are introduced.

---

# Shared Placeholder Data

Profile displays the shared placeholder user, **Tiamana**, already used as the current user throughout Rounds, Trips, Friends and Groups — see `docs/architecture/profile-engineering-decisions.md`'s "Tiamana Is the Shared Placeholder Subject".

The following information must never be duplicated as new literals — it is computed from each feature's existing placeholder data instead:

- Friends count (`placeholder_friends.dart`)
- Groups count (`placeholder_groups.dart`)
- Trips count (`placeholder_trips.dart`)
- Current Season standing (`placeholder_groups.dart`'s Saturday Boys leaderboard)

Rounds Played, Average Score, Best Round, Fairways Hit and Greens in Regulation must match `placeholder-data.md`'s "Statistics" section exactly, since both describe the same placeholder user.

Future backend integration will replace this placeholder data.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- QaddyAvatar
- QaddyCard
- QaddySectionCard
- QaddyStatusBadge
- QaddyStatisticCard
- ResponsivePadding
- ResponsiveMaxWidth

Create new widgets only when functionality does not already exist.

---

# Model Reuse

Reuse existing models and placeholder data wherever possible. Profile must not redefine or restate Friend, Group or Trip data.

Reuse:

- Friend (`community/models/friend.dart`) — for Favourite Playing Partners' avatars
- `totalFriendsCount`, `groups`, `upcomingTrips`/`pastTrips` — for Profile Summary's counts
- `saturdayBoysLeaderboard`, `saturdayBoysSeasonSummary` — for Current Season

New models introduced by this feature only:

- Profile (`profile-data-model.md`)
- AchievementPreview (a simplified stand-in for the full `Achievement` model — see `docs/architecture/profile-engineering-decisions.md`)

Avoid creating duplicate placeholder models.

---

# Button Behaviour

| Button | Action |
|---------|---------|
| View Statistics | Open Statistics (`/profile/statistics`) |

No other interactive buttons exist in Release 1 — every other section is read-only display data (see Scope, "Editing any Profile information").

---

# Placeholder State

All Profile information remains in memory.

No backend persistence exists during this feature's implementation.

Closing the application resets placeholder data.

Persistent storage will be implemented in a future release.

---

# Acceptance Criteria

The Profile feature is complete when a user can:

- View their own identity, handicap, home club and location
- View their Friends, Groups, Trips, Rounds and Achievements summary
- View their playing statistics and personal bests
- View their current season standing
- View their achievement showcase, favourite courses, playing partners and equipment
- View their recent activity
- Return to the Dashboard

Additionally:

- No duplicate placeholder data exists — every shared count is computed, not restated
- Existing widgets are reused wherever possible
- All tests pass
- The feature behaves as one continuous, single-screen experience

---

# Future Integration

Future releases will replace placeholder functionality with:

- Supabase
- A dedicated Achievements screen (with the full Achievement model)
- A dedicated Settings screen
- A dedicated Premium screen
- Editable Profile information

See `docs/architecture/profile-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Profile functionality into one complete feature.
