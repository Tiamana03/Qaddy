# Statistics Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Statistics feature.

Per-document Engineering Decisions sections still apply where they exist (`statistics-data-model.md`, `round-data-model.md`); this document exists for decisions that span the whole feature rather than belonging to one model.

---

## Statistics Is an Aggregation Layer, Not a New Data Store

`round-data-model.md`'s own "Statistics Ownership" section already states statistics are calculated from completed rounds rather than stored redundantly. Every section of the Statistics screen reads a value that already has a canonical home in Profile, Groups, Friends or Trips, rather than declaring a parallel copy.

**Why:** this is the same "Single Source of Truth" discipline already applied when Profile's Friends/Groups/Trips counts and Current Season card were built to compute from each feature's own placeholder data instead of duplicating it — the exact class of drift that had to be fixed once before Profile could be documented cleanly.

**How to apply:** `lib/features/statistics/models/placeholder_statistics.dart` imports Profile's, Groups' and Friends' existing placeholder constants directly. It does not redeclare Career Totals, Scoring Statistics, Scoring Breakdown, Personal Records, Season Performance or Rivalry Performance as new literals.

---

## Trends Use Two-Point Deltas, Not Time Series

Release 1 has no historical, round-by-round dataset anywhere in the application — Rounds' own placeholder data is a single current/upcoming round plus one leaderboard, not a log of completed rounds over time. Building a genuine multi-point trend (e.g., a 6-month line chart) would require inventing an entire historical dataset with no grounding in any other document.

Instead, Trends shows exactly two data points per statistic — the current value (already established elsewhere) and one new "previous value" — over a single named period ("Last 3 months").

**Why:** this satisfies the Sprint 6 goal of showing trends while introducing the smallest possible amount of new placeholder data (two numbers, not a dataset), per `docs/ai/project-rules.md`'s "Never invent placeholder data... only introduce new placeholder data where genuinely required."

**How to apply:** the two Trend entries (Handicap, Average Score) are documented in `placeholder-statistics-data.md`'s "New Placeholder Data" section — the only new values this entire feature introduces. Multi-point historical trends are deferred — see `statistics-future-roadmap.md`.

---

## No Charting Library in Release 1

The Sprint 6 goal names "charts" explicitly, but no chart type is documented anywhere in `docs/ui-component-library.md` or `docs/qaddy-design-bible.md`, and no charting package exists in `pubspec.yaml` today. Adding one is a dependency decision — `docs/ai/architecture-principles.md`'s Definition of Done and the project's engineering guide both treat "add dependencies without justification" as something to avoid, not something to decide inside a documentation pass.

Release 1 instead expresses every visual comparison using components that already exist:

- `QaddyStatisticCard`'s existing `trend`/`isPositiveTrend` fields (documented but never yet exercised by any feature) render the two Trend entries as "↓1.2 (Last 3 months)" style deltas — exactly the widget's own doc-comment example.
- The Season Performance leaderboard reuses `GroupLeaderboardRow`/`PositionBadge` exactly as Group Details does.

**Why:** satisfies "trends" and "performance analysis" without a new dependency, and reuses an existing widget capability that has been sitting unused since Sprint 2.1.

**How to apply:** a real charting library (line graphs, bar charts, pie charts) is deferred — see `statistics-future-roadmap.md`. If a future release needs one, that is a genuine architecture decision requiring explicit approval before implementation, per `docs/ai/project-rules.md`.

---

## Season Performance Shows the Full Leaderboard

Profile's own "Current Season" card (see `profile-engineering-decisions.md`) deliberately shows only Tiamana's rank and points. Statistics' Season Performance section shows the complete Saturday Boys leaderboard (all 8 entries) plus the season summary, giving the fuller performance-analysis context the Sprint goal asks for.

**Why:** the two screens serve different purposes — Profile is a quick identity summary; Statistics is the detailed analysis screen. Showing the same single-row summary in both would make Statistics redundant with Profile.

**How to apply:** reuses `saturdayBoysLeaderboard` and `saturdayBoysSeasonSummary` from `placeholder_groups.dart` directly — the full lists, not a filtered subset.

---

## Statistics Is Reached From Profile, Not the Bottom Navigation

`docs/architecture/navigation.md`'s Profile section already names Statistics as one of Profile's own future expansions ("Future releases will expand Profile into: Statistics..."), not a new bottom-navigation destination. Release 1 implements that exactly: route `/profile/statistics`, nested under the existing Profile branch, opened via a quick link on the Profile screen.

**Why:** matches the navigation architecture that was already decided before this feature existed, rather than inventing a sixth bottom-navigation tab.

**How to apply:** Statistics is a single aggregated screen (matching the "Release 1 Is One Aggregated Screen" pattern `profile-engineering-decisions.md` already established for Profile itself), reached in one tap from Profile — Dashboard → Profile tab → Profile screen → Statistics is 2 taps, well inside the Three Click Rule.

---

# Source of Truth

Statistics should never duplicate values already owned by another feature.

Whenever possible, Statistics derives information from:

- Rounds
- Profile
- Friends
- Trips
- Groups

Only statistics that cannot be calculated elsewhere may define their own placeholder data.

---

# Related Documents

- statistics-data-model.md
- docs/features/statistics-feature-integration.md
- statistics-future-roadmap.md
- profile-engineering-decisions.md

---

**End of Document**
