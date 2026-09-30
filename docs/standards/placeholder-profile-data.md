# Placeholder Profile Data

**Version:** 1.0  
**Status:** Approved Placeholder Data

---

# Purpose

This document defines the official placeholder profile data used throughout Qaddy.

All profile-related screens, widgets, and sprint implementations must use this data.

No AI or developer may invent additional profile values without updating this document.

---

# Player Profile

| Field | Value |
|--------|-------|
| Name | Tiamana |
| Handicap | 8.4 |
| Home Club | Richmond Golf Club |
| Favourite Course | Royal Queensland Golf Club |
| Member Since | January 2024 |
| Status | Active |
| Location | Queensland, Australia |
| Profile Visibility | Friends Only |

Handicap and Member Since match `placeholder-data.md`'s "User Profile" section exactly — Tiamana is the same placeholder user throughout the application (see `docs/architecture/profile-engineering-decisions.md`). Location combines the model's single `location` field (`profile-data-model.md`) rather than the separate Country/State fields an earlier draft of this document used, since those aren't part of the documented Profile Model. "Preferred Tee" has been removed for the same reason — no Profile Model field exists for it yet.

---

# Profile Summary

| Statistic | Value |
|-----------|------:|
| Friends | 8 |
| Groups | 4 |
| Trips | 4 |
| Courses Played | 18 |
| Rounds Played | 68 |
| Seasons Completed | 1 |
| Achievements | 12 |

Friends, Groups, Trips and Rounds Played match the totals already established in `placeholder-friend-data.md`, `placeholder-group-data.md`, `placeholder-trip-data.md` and `placeholder-data.md` respectively — see "Engineering Notes" below.

---

# Playing Statistics

| Statistic | Value |
|-----------|------:|
| Handicap | 8.4 |
| Average Score | 83 |
| Average Stableford | 34 |
| Best Round | 74 |
| Best Stableford | 42 |
| Birdies | 37 |
| Eagles | 2 |
| Pars | 298 |
| Fairways Hit | 62% |
| Greens in Regulation | 48% |
| Average Putts | 31 |

Handicap, Average Score, Best Round, Fairways Hit and Greens in Regulation match `placeholder-data.md`'s "Statistics" section exactly — both describe the same placeholder user's lifetime statistics.

---

# Activity Summary

**Status:** Deferred — not implemented in Release 1. See `docs/features/profile-feature-integration.md`'s Scope; kept here for a future "This Year" summary section.

| Activity | Value |
|----------|------:|
| Rounds This Year | 18 |
| Trips This Year | 2 |
| Friends Added | 8 |
| Groups Joined | 4 |
| Achievements Earned | 5 |

---

# Current Season

| Field | Value |
|--------|-------|
| Season | 2026 Season |
| Group | Saturday Boys |
| Position | 5th |
| Points | 97 |

Matches `placeholder-group-data.md`'s "Saturday Boys" season and leaderboard exactly — Tiamana is rank 5 with 97 points there too.

---

# Recent Activity

| Date | Activity |
|------|----------|
| Yesterday | Completed Richmond Golf Club |
| 3 Days Ago | Joined Wednesday Warriors |
| Last Week | Earned "Course Collector" |
| 2 Weeks Ago | Planned Gold Coast Golf Escape |
| 3 Weeks Ago | Added Nick as Friend |

---

# Achievement Showcase

| Achievement | Status |
|-------------|--------|
| First Round | Unlocked |
| Birdie Hunter | Unlocked |
| Course Collector | Unlocked |
| Weekend Warrior | Unlocked |
| Road Tripper | Unlocked |
| Season Competitor | Unlocked |

---

# Favourite Courses

| Course |
|--------|
| Royal Queensland Golf Club |
| Richmond Golf Club |
| Brookwater Golf Club |
| Virginia Golf Club |
| Wantima Country Club |

---

# Favourite Playing Partners

| Name |
|------|
| Tom |
| Luke |
| Ben |
| Nick |

---

# Equipment

| Club | Value |
|------|-------|
| Driver | TaylorMade Qi35 |
| Irons | TaylorMade P790 |
| Wedges | Cleveland RTX |
| Putter | Odyssey White Hot |
| Ball | Titleist Pro V1 |

---

# Personal Bests

| Statistic | Value |
|-----------|------:|
| Best Round | 74 |
| Best Front Nine | 37 |
| Best Back Nine | 38 |
| Most Birdies | 5 |
| Longest Drive | 312m |
| Longest Putt | 18m |

---

# Lifetime Statistics

| Statistic | Value |
|-----------|------:|
| Courses Played | 18 |
| Rounds Played | 68 |
| Total Birdies | 37 |
| Total Eagles | 2 |
| Total Pars | 298 |
| Total Stableford Points | 1428 |
| Golf Trips | 4 |

---

# Avatar

| Field | Value |
|--------|-------|
| Initials | TI |
| Avatar Style | Initials |
| Background | Dynamic Accent Colour |

---

# Search Examples

Common searches:

- Tiamana
- Handicap
- Richmond Golf Club
- Saturday Boys
- Royal Queensland

---

# Future Placeholder Data

Future versions of this document may include:

- Swing Speed
- Ball Speed
- Club Distances
- AI Golf IQ
- Equipment History
- Golf Goals
- Practice Sessions
- Fitness Statistics
- Walking Distance
- Calories Burned
- Social Rankings
- Club Fittings
- Coaching Sessions
- Preferred Playing Times
- Favourite Golf Brands

These values should not be introduced until required by a future sprint.

---

# Engineering Notes

This document contains placeholder profile information only.

Business rules belong in:

- profile-data-model.md
- profile-achievements.md

Implementation belongs in `docs/features/profile-feature-integration.md`.

---

# Related Documents

- profile-data-model.md
- profile-achievements.md
- profile-engineering-decisions.md
- profile-future-roadmap.md
- docs/features/profile-feature-integration.md
- placeholder-data.md
- placeholder-friend-data.md
- placeholder-group-data.md
- placeholder-trip-data.md

---

**End of Document**