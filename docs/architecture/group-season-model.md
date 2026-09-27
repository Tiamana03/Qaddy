# Group Season Model

**Version:** 1.0  
**Status:** Architecture Approved

---

# Purpose

This document defines how Seasons operate within Groups in Qaddy.

A Season provides a structured competition across multiple golf rounds, allowing members to compete over weeks, months, or years.

Seasons create long-term engagement by tracking standings, achievements, statistics, and historical records.

---

# Overview

Every Group may contain multiple Seasons.

Examples:

```
Saturday Boys

2026 Summer Season

↓

20 Rounds

↓

Season Champion
```

```
Saturday Boys

2027 Season

↓

Starts fresh

↓

New Leaderboard
```

Historical Seasons are never deleted.

---

# Season Model

| Field | Type | Description |
|--------|------|-------------|
| id | String | Unique Season ID |
| groupId | String | Parent Group |
| name | String | Season name |
| year | int | Season year |
| description | String | Optional description |
| startDate | DateTime | Season start |
| endDate | DateTime | Season finish |
| status | SeasonStatus | Current season state |
| totalRounds | int | Number of rounds |
| completedRounds | int | Completed rounds |
| members | List<User> | Participating members |
| leaderboard | Leaderboard | Current standings |
| championId | String? | Season winner |
| createdAt | DateTime | Created date |
| updatedAt | DateTime | Last updated |

---

# Season Status

Every Season must have one status.

| Status | Description |
|----------|-------------|
| Planning | Season being prepared |
| Registration | Players joining |
| Active | Season in progress |
| Completed | Finished |
| Archived | Historical season |

---

# Season Lifecycle

```
Planning

↓

Registration

↓

Active

↓

Completed

↓

Archived
```

Once archived, historical records become read-only.

---

# Season Leaderboard

Each Season maintains a live leaderboard.

Example metrics:

- Total Points
- Wins
- Podiums
- Average Score
- Stableford Points
- Best Round
- Lowest Gross Score
- Lowest Net Score
- Longest Drive Wins
- Nearest Pin Wins
- Attendance
- Win Percentage

Leaderboard calculations are derived from completed rounds.

---

# Season Achievements

Each Season records achievements.

Examples:

- Season Champion
- Most Improved
- Lowest Handicap
- Lowest Round
- Best Stableford
- Most Birdies
- Most Eagles
- Longest Drive Champion
- Nearest Pin Champion
- Ironman Award (Highest Attendance)

Achievements remain permanently attached to the completed Season.

---

# Season Statistics

Statistics may include:

- Total Rounds
- Average Players
- Total Birdies
- Total Eagles
- Total Pars
- Average Score
- Average Stableford
- Average Handicap
- Total Kilometres Walked (future)
- Total Prize Pool (future)

---

# Membership Rules

A member may:

- Participate in multiple Seasons.
- Join a Season after creation (if allowed).
- Leave before completion (if permitted).

Historical participation is always retained.

---

# Business Rules

- A Group may have multiple Seasons.
- Only one Active Season is allowed per Group.
- Historical Seasons are read-only.
- Deleting a Group should not silently delete Season history.
- Leaderboards are recalculated after every completed round.
- Achievements are awarded when the Season ends.

---

# Relationships

```
Group

↓

Season

↓

Rounds

↓

Leaderboard

↓

Statistics

↓

Achievements
```

Each Round belongs to exactly one Season.

---

# Future Expansion

Future Seasons may support:

- Divisions
- Match Play
- Stableford Leagues
- Team Seasons
- Knockout Finals
- Promotion & Relegation
- Prize Pools
- Sponsorship
- Fantasy Golf
- AI Predictions

---

# Engineering Decisions

Season data is independent from Round data.

Rounds provide the raw scoring.

The Season aggregates results over time.

This separation keeps calculations efficient and preserves historical accuracy.

---

# Flutter Implementation Notes

Season functionality should remain inside:

```
lib/features/groups/
```

Reusable widgets may include:

- Season Card
- Season Leaderboard
- Season Summary
- Season Statistics
- Achievement Banner
- Champion Card

Shared widgets should only move into `lib/core/widgets/` if reused across multiple features.

---

# Related Documents

- app-architecture.md
- group-data-model.md
- round-data-model.md
- friend-data-model.md
- profile-achievements.md
- group-permissions.md

---

**End of Document**