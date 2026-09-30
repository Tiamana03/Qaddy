# Statistics Data Model

**Version:** 1.0

**Status:** Architecture Approved

---

# Purpose

This document defines the Statistics feature's data model.

Statistics is Qaddy's detailed performance-analysis layer — career totals, scoring statistics, trends, personal records, season standing and rivalry performance in one place.

Per `docs/architecture/round-data-model.md`'s "Statistics Ownership" section: *"Statistics are NOT stored inside the Round. Statistics are calculated separately from completed rounds. This prevents duplicated data."* Statistics inherits that principle directly — it introduces almost no data of its own. Every figure it shows is either reused from an existing feature's placeholder data or, where a comparison genuinely requires a second data point that doesn't exist anywhere yet (Trends), the smallest possible new value.

No implementation may introduce additional Statistics fields without updating this document.

---

# Overview

Statistics aggregates and presents:

- Career Totals — from Profile
- Scoring Statistics — from Profile
- Scoring Breakdown — from Profile
- Trends — new to this feature (see "Stat Trend Model")
- Personal Records — from Profile
- Season Performance — from Groups
- Rivalry Performance — from Friends

Statistics does not own a Round, a Group, a Friend or a Trip. It reads their already-established placeholder data.

---

# Stat Trend Model

The one new model this feature introduces — a two-point comparison (current value vs. a previous value) used to show whether a statistic is improving.

| Field | Type | Description |
|--------|------|-------------|
| label | String | What is trending, e.g. "Handicap" |
| currentValue | double | The current value |
| previousValue | double | The value at the start of the comparison period |
| period | String | The comparison window, e.g. "Last 3 months" |
| lowerIsBetter | bool | Whether a decrease represents improvement (true for Handicap and Average Score; false for a metric like Stableford where higher is better) |

Derived, not stored:

- **delta** = currentValue − previousValue
- **isImprovement** = `lowerIsBetter ? delta < 0 : delta > 0`

No other new model exists. Everything else reuses an existing type — see "Model Reuse" below.

---

# Model Reuse

Statistics must not redefine or restate any of the following. It reads them directly.

| Source | Reused for |
|---------|-----------|
| `placeholder-profile-data.md` / `placeholder_profile.dart` | Career Totals, Scoring Statistics, Scoring Breakdown, Personal Records |
| `placeholder-group-data.md` / `placeholder_groups.dart` (`GroupLeaderboardEntry`, `GroupSeasonSummary`) | Season Performance — the full Saturday Boys leaderboard and season summary |
| `placeholder-friend-data.md` / `placeholder_friends.dart` (`RivalryRecord`) | Rivalry Performance — the Tiamana vs. Tom record |
| `placeholder-trip-data.md` / `placeholder_trips.dart` | The Trips figure inside Career Totals |

---

# Business Rules

- A figure that already has a canonical source elsewhere is read from that source, never restated as a new literal.
- Trends require exactly two data points (current and previous) for a fixed, named period. Multi-point historical series (month-by-month charts) are out of scope for Release 1 — see `statistics-future-roadmap.md`.
- `lowerIsBetter` must be set correctly per metric — a false setting would show an improving statistic as declining.

---

# Out of Scope (Release 1)

- Any new statistic that does not already exist somewhere else in the application, other than the two Trend "previous value" figures documented in `placeholder-statistics-data.md`.
- Multi-point trend history / line charts.
- Custom date-range filtering.
- Per-course statistics breakdowns.

See `statistics-future-roadmap.md`.

---

# Engineering Decisions

See `docs/architecture/statistics-engineering-decisions.md` for the full reasoning behind this model's shape, including why Release 1 uses two-point trend deltas instead of a charting library.

---

# Flutter Implementation Notes

Statistics functionality should remain inside:

```
lib/features/statistics/
```

The only new model type is `StatTrend`. Every other value is read from the feature that already owns it (Profile, Groups, Friends, Trips) rather than duplicated into a Statistics-owned model.

---

# Related Documents

- round-data-model.md
- profile-data-model.md
- group-data-model.md
- group-season-model.md
- friend-relationship-model.md
- rivalries.md
- docs/features/statistics-feature-integration.md
- statistics-engineering-decisions.md
- statistics-future-roadmap.md

---

**End of Document**
