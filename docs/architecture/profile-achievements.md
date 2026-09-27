# Profile Achievements

**Version:** 1.0  
**Status:** Architecture Approved

---

# Purpose

This document defines the Achievement system used throughout Qaddy.

Achievements reward players for participation, improvement, milestones, and exceptional performances.

Achievements encourage long-term engagement while preserving a permanent history of a player's golfing journey.

Achievements are earned automatically through gameplay and participation.

No implementation may introduce new achievement types without updating this document.

---

# Overview

Achievements are permanent rewards attached to a player's profile.

Achievements may be earned through:

- Rounds
- Trips
- Groups
- Seasons
- Statistics
- Challenges
- Special Events

Achievements are displayed within the user's Profile and contribute to their overall golfing history.

---

# Achievement Model

| Field | Type | Description |
|--------|------|-------------|
| id | String | Unique achievement ID |
| title | String | Achievement title |
| description | String | Achievement description |
| category | AchievementCategory | Achievement category |
| rarity | AchievementRarity | Common to Legendary |
| icon | String | Achievement icon |
| unlocked | bool | Unlock status |
| unlockedDate | DateTime? | Date earned |
| progress | double | Current progress |
| target | double | Target required |
| points | int | Achievement points |
| hidden | bool | Hidden until unlocked |

---

# Achievement Categories

Achievements belong to one category.

Available categories:

- Rounds
- Trips
- Friends
- Groups
- Seasons
- Statistics
- Milestones
- Challenges
- Special Events

---

# Achievement Rarity

Every achievement has a rarity level.

| Rarity | Description |
|----------|-------------|
| Common | Easy to obtain |
| Uncommon | Requires consistent play |
| Rare | Difficult |
| Epic | Significant accomplishment |
| Legendary | Exceptional achievement |

---

# Round Achievements

Examples include:

- First Round
- First Birdie
- First Eagle
- Hole In One
- Under Par Round
- Personal Best
- Lowest Gross Score
- Lowest Net Score
- Perfect Front Nine
- Perfect Back Nine

---

# Trip Achievements

Examples include:

- First Golf Trip
- Five Trips Completed
- Overseas Golf Trip
- Visited Ten Courses
- Weekend Warrior
- Road Trip Champion

---

# Group Achievements

Examples include:

- Joined First Group
- Group Champion
- Ten Group Victories
- Most Consistent Player
- Longest Membership

---

# Season Achievements

Examples include:

- Season Champion
- Most Improved
- Most Birdies
- Attendance Champion
- Lowest Handicap
- Lowest Average Score

---

# Friendship Achievements

Examples include:

- First Friend
- Ten Friends
- Fifty Friends
- Played 100 Rounds Together
- Ultimate Golf Partner

---

# Statistics Achievements

Examples include:

- 100 Birdies
- 50 Eagles
- Average Below 80
- Handicap Below 10
- Handicap Below 5
- 500 Stableford Points

---

# Milestone Achievements

Examples include:

- 10 Rounds Played
- 50 Rounds Played
- 100 Rounds Played
- 250 Rounds Played
- 500 Rounds Played

---

# Hidden Achievements

Some achievements remain hidden until unlocked.

Examples:

- Hole In One
- Albatross
- Three Eagles In One Round
- Consecutive Birdies
- Championship Sweep

Hidden achievements encourage discovery.

---

# Achievement Progress

Achievements may track progress.

Example:

```
Birdie Hunter

Progress

38 / 100 Birdies
```

Progress updates automatically after qualifying events.

---

# Achievement Points

Each achievement awards points.

Example values:

| Rarity | Points |
|----------|--------|
| Common | 10 |
| Uncommon | 25 |
| Rare | 50 |
| Epic | 100 |
| Legendary | 250 |

Achievement Points may contribute to future Profile Levels.

---

# Business Rules

- Achievements cannot be manually unlocked.
- Achievements remain permanently attached to a profile.
- Historical achievements are never deleted.
- Progress should always be calculated automatically.
- Duplicate achievements are not permitted.

---

# Relationships

```
Profile

↓

Achievements

↓

Rounds

Trips

Groups

Seasons

Statistics
```

Achievements consume data from other features but do not own it.

---

# Engineering Decisions

Achievements should remain independent from gameplay.

Gameplay records the event.

Achievements evaluate whether requirements have been met.

This separation keeps the system scalable and maintainable.

---

# Future Expansion

Future achievement features may include:

- Achievement Collections
- Monthly Challenges
- Limited-Time Events
- Seasonal Achievements
- Club Achievements
- Regional Achievements
- AI Challenges
- Community Events
- Trophy Cabinet
- Achievement Sharing

Future additions should remain backwards compatible.

---

# Flutter Implementation Notes

Achievement functionality should remain inside:

```
lib/features/profile/
```

Reusable widgets may include:

- Achievement Card
- Achievement Badge
- Progress Bar
- Trophy Cabinet
- Achievement Detail
- Achievement Grid

Reusable components should move into:

```
lib/core/widgets/
```

where appropriate.

---

# Related Documents

- app-architecture.md
- profile-data-model.md
- statistics-data-model.md
- round-data-model.md
- trip-data-model.md
- friend-data-model.md
- group-data-model.md
- group-season-model.md

---

**End of Document**