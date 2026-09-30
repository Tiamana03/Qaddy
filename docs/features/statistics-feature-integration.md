# Statistics Feature Integration

## Overview

This document defines how the complete Statistics feature is integrated within Qaddy.

Statistics is the detailed performance-analysis layer that sits behind Profile — career totals, scoring statistics, trends, personal records, season standing and rivalry performance in one place.

This document does **not** define new functionality.

Instead, it explains how Statistics' sections combine into one seamless screen and how it reuses data already established by Profile, Groups, Friends and Trips.

---

# Goals

The Statistics feature should allow users to:

- View their career totals (rounds, courses, trips, lifetime points)
- View their scoring statistics and scoring breakdown
- See whether their Handicap and Average Score are trending up or down
- View their personal records
- View the full season standings for their group
- View their rivalry performance
- Return to Profile

The experience should feel like "Profile, in more depth" rather than a disconnected screen.

---

# Scope

This feature includes:

- Statistics (single screen)
- Placeholder data
- Feature integration

This feature does **not** include:

- Multi-point historical trend charts
- A charting library of any kind
- Custom date range filtering
- Per-course statistics
- A round-by-round history log
- Comparing statistics against any friend other than the existing Rivalry Performance record
- Export or sharing
- Editing any statistic

All data remains placeholder driven. See `docs/architecture/statistics-future-roadmap.md` for how these are expected to arrive later.

---

# Feature Flow

The complete Statistics journey should follow the workflow below.

Dashboard

↓

Profile

↓

Statistics

↓

Profile

Statistics is a single destination reached from Profile — every section below renders on the same screen, matching the "Release 1 Is One Aggregated Screen" pattern already used for Profile itself.

---

# Integration Objectives

Statistics should never restate a figure that already has a canonical source in Profile, Groups, Friends or Trips.

Every number shown must match the equivalent value already established elsewhere in the application — never a new, independent figure for the same concept.

---

# Navigation Flow

## Profile

Displays a "View Statistics" quick link.

Selecting it opens Statistics.

---

## Statistics

Displays, in order:

- Career Totals — Rounds Played, Courses Played, Golf Trips, Total Stableford Points
- Scoring Statistics — Average Score, Average Stableford, Fairways Hit, Greens in Regulation, Average Putts
- Scoring Breakdown — Birdies, Eagles, Pars
- Trends — Handicap and Average Score, each shown as a current value with a trend delta over the last 3 months
- Personal Records — Best Round, Best Front Nine, Best Back Nine, Most Birdies, Longest Drive, Longest Putt
- Season Performance — the full Saturday Boys season summary and leaderboard
- Rivalry Performance — the Tiamana vs. Tom head-to-head record

No section links to another screen — Release 1 has nothing further to open (see Scope).

---

# Route Integration

Statistics is nested under the existing Profile route, per `navigation.md`.

| Route | Screen |
|---------|---------|
| /profile/statistics | Statistics |

No new top-level route or bottom-navigation destination is introduced.

---

# Shared Placeholder Data

Statistics displays the same shared placeholder user, **Tiamana**, already used throughout Rounds, Trips, Friends, Groups and Profile.

The following information must never be duplicated as new literals — it is read from each feature's existing placeholder data instead:

- Career Totals, Scoring Statistics, Scoring Breakdown, Personal Records (`placeholder_profile.dart`)
- Season Performance (`placeholder_groups.dart`'s Saturday Boys leaderboard and season summary)
- Rivalry Performance (`placeholder_friends.dart`'s Tom rivalry record)

The only new placeholder values this feature introduces are the two Trend "previous value" figures — see `placeholder-statistics-data.md`'s "New Placeholder Data" section.

Future backend integration will replace this placeholder data.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- QaddyCard
- QaddySectionCard
- QaddyStatisticCard — including its existing `trend`/`isPositiveTrend` fields, exercised for the first time by this feature
- GroupLeaderboardRow / PositionBadge — for Season Performance, exactly as Group Details already uses them
- ResponsivePadding
- ResponsiveMaxWidth

Create new widgets only when functionality does not already exist.

---

# Model Reuse

Reuse existing models and placeholder data wherever possible. Statistics must not redefine or restate Profile, Group or Friend data.

Reuse:

- `profileRoundsPlayed`, `profileCoursesPlayed`, `profileTripsCount`, `profileTotalStablefordPoints`, `profileAverageScore`, `profileAverageStableford`, `profileFairwaysHitPercent`, `profileGreensInRegulationPercent`, `profileAveragePutts`, `profileBirdies`, `profileEagles`, `profilePars`, `profileBestRound`, `profileBestFrontNine`, `profileBestBackNine`, `profileMostBirdies`, `profileLongestDriveMetres`, `profileLongestPuttMetres` (`placeholder_profile.dart`)
- `GroupLeaderboardEntry`, `GroupSeasonSummary`, `saturdayBoysLeaderboard`, `saturdayBoysSeasonSummary` (`placeholder_groups.dart`)
- `RivalryRecord`, `tomRivalry` (`placeholder_friends.dart`)

New model introduced by this feature only:

- `StatTrend` (`statistics-data-model.md`)

Avoid creating duplicate placeholder models.

---

# Button Behaviour

| Button | Action |
|---------|---------|
| View Statistics (on Profile) | Open Statistics |
| Back | Return to Profile |

No other interactive buttons exist in Release 1 — every Statistics section is read-only display data (see Scope, "Editing any statistic").

---

# Placeholder State

All Statistics information remains in memory.

No backend persistence exists during this feature's implementation.

Closing the application resets placeholder data.

Persistent storage will be implemented in a future release.

---

# Acceptance Criteria

The Statistics feature is complete when a user can:

- Open Statistics from Profile
- View their career totals, scoring statistics and scoring breakdown
- View whether their Handicap and Average Score are trending up or down
- View their personal records
- View the full season standings for their group
- View their rivalry performance
- Return to Profile

Additionally:

- No duplicate placeholder data exists — every reused figure is read from its existing source, not restated
- Existing widgets are reused wherever possible, including `QaddyStatisticCard`'s trend fields
- Navigation has no dead ends
- All tests pass
- The feature behaves as a natural extension of Profile

---

# Future Integration

Future releases will replace placeholder functionality with:

- Supabase
- Multi-point historical trend charts
- A charting library
- Custom date range filtering
- Per-course statistics
- A round-by-round history log
- Broader friend comparisons
- Export and sharing
- AI-driven insights

See `docs/architecture/statistics-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Statistics functionality into one complete feature.
