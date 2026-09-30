# Placeholder Statistics Data

**Version:** 1.0

**Status:** Approved Placeholder Data

---

# Purpose

This document defines the official placeholder data for the Statistics feature.

Almost none of it is new. Per `docs/architecture/statistics-data-model.md`, Statistics reuses figures already established by Profile, Groups, Friends and Trips. This document states exactly which value comes from where, and separately calls out the only two values that are genuinely new (see "New Placeholder Data" below).

No AI or developer may invent additional statistics values without updating this document.

---

# Career Totals

Reused from `placeholder-profile-data.md`'s "Profile Summary" and "Lifetime Statistics" sections.

| Statistic | Value | Source |
|-----------|------:|--------|
| Rounds Played | 68 | `profileRoundsPlayed` |
| Courses Played | 18 | `profileCoursesPlayed` |
| Golf Trips | 4 | `profileTripsCount` |
| Total Stableford Points | 1428 | `profileTotalStablefordPoints` |

---

# Scoring Statistics

Reused from `placeholder-profile-data.md`'s "Playing Statistics" section.

| Statistic | Value | Source |
|-----------|------:|--------|
| Average Score | 83 | `profileAverageScore` |
| Average Stableford | 34 | `profileAverageStableford` |
| Fairways Hit | 62% | `profileFairwaysHitPercent` |
| Greens in Regulation | 48% | `profileGreensInRegulationPercent` |
| Average Putts | 31 | `profileAveragePutts` |

---

# Scoring Breakdown

Reused from `placeholder-profile-data.md`'s "Playing Statistics" section.

| Statistic | Value | Source |
|-----------|------:|--------|
| Birdies | 37 | `profileBirdies` |
| Eagles | 2 | `profileEagles` |
| Pars | 298 | `profilePars` |

---

# New Placeholder Data

The only values this feature introduces that do not already exist anywhere else — both are the "previous value" half of a `StatTrend`, since a trend cannot be shown from a single data point.

| Label | Current Value | Previous Value | Period | Lower Is Better |
|-------|---------------:|----------------:|--------|:---:|
| Handicap | 8.4 | 9.6 | Last 3 months | Yes |
| Average Score | 83 | 86 | Last 3 months | Yes |

Current values match `profile-data-model.md`'s canonical Handicap (8.4) and `placeholder-profile-data.md`'s Average Score (83) exactly — only the Previous Value column is new. Both trends use the same "Last 3 months" window as `placeholder-data.md`'s Dashboard "Recent Activity" entry, "Handicap reduced to 8.4," which already implies this exact improvement without ever stating a starting number.

---

# Personal Records

Reused from `placeholder-profile-data.md`'s "Personal Bests" section.

| Statistic | Value | Source |
|-----------|------:|--------|
| Best Round | 74 | `profileBestRound` |
| Best Front Nine | 37 | `profileBestFrontNine` |
| Best Back Nine | 38 | `profileBestBackNine` |
| Most Birdies | 5 | `profileMostBirdies` |
| Longest Drive | 312m | `profileLongestDriveMetres` |
| Longest Putt | 18m | `profileLongestPuttMetres` |

---

# Season Performance

Reused in full from `placeholder-group-data.md`'s "Saturday Boys" season summary and leaderboard — every entry, not only Tiamana's own row (Profile's Current Season card already shows just her row; Statistics shows the complete standings for context).

See `placeholder-group-data.md`'s "Season Summary" and "Leaderboard" tables.

---

# Rivalry Performance

Reused in full from `placeholder-friend-data.md`'s "Rivalries" section — the Tiamana vs. Tom record (12 rounds, 6 wins, 5 losses, 1 draw, "Won by 2 strokes at Richmond Golf Club").

See `docs/architecture/rivalries.md`.

---

# Engineering Notes

This document contains placeholder statistics information only.

Business rules belong in:

- statistics-data-model.md
- statistics-engineering-decisions.md

Implementation belongs in `docs/features/statistics-feature-integration.md`.

---

# Related Documents

- statistics-data-model.md
- statistics-engineering-decisions.md
- statistics-future-roadmap.md
- docs/features/statistics-feature-integration.md
- placeholder-profile-data.md
- placeholder-group-data.md
- placeholder-friend-data.md
- placeholder-trip-data.md
- placeholder-data.md

---

**End of Document**
