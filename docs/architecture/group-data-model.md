# Group Data Model

**Version:** 1.0  
**Status:** Architecture Approved

---

# Purpose

This document defines the Group data model used throughout Qaddy.

Groups allow golfers to organise recurring rounds, trips, competitions, and seasons with the same group of friends.

The Group model acts as the central social hub of the application.

No implementation may introduce additional Group fields without first updating this document.

---

# Overview

A Group represents a collection of Qaddy users.

Examples include:

- Saturday Boys
- Friday Social Golf
- Work Golf Club
- Family Golf
- Annual Golf Trip
- Corporate Golf League

Each Group maintains its own history, members, statistics, achievements, and seasons.

---

# Group Model

| Field | Type | Description |
|--------|------|-------------|
| id | String | Unique Group ID |
| name | String | Group name |
| description | String | Optional description |
| coverImage | String? | Group banner image |
| logo | String? | Group logo |
| ownerId | String | Group owner |
| adminIds | List<String> | Group administrators |
| memberIds | List<String> | Group members |
| createdAt | DateTime | Date created |
| updatedAt | DateTime | Last updated |
| status | GroupStatus | Current group status |
| defaultCourse | String? | Preferred golf course |
| defaultFormat | String? | Preferred scoring format |
| totalRounds | int | Total rounds played |
| totalTrips | int | Total trips completed |
| totalMembers | int | Current member count |

---

# Group Status

Every Group must exist in one of the following states.

| Status | Description |
|----------|-------------|
| Active | Group is operating normally |
| Archived | Historical group |
| Hidden | Hidden from public view |
| Deleted | Soft deleted |

Deleted Groups should never permanently remove historical data.

---

# Membership

A Group contains:

- One Owner
- Zero or more Admins
- One or more Members

Permissions are defined separately in:

```
group-permissions.md
```

---

# Group Statistics

Each Group maintains summary statistics.

Examples:

- Total Rounds
- Total Members
- Total Trips
- Total Seasons
- Average Attendance
- Average Stableford
- Average Gross Score
- Birdies
- Eagles
- Hole-in-Ones
- Longest Drive Winners
- Nearest Pin Winners

Detailed statistics remain inside the Statistics feature.

---

# Group Seasons

Groups may contain multiple Seasons.

Example:

```
Saturday Boys

↓

2026 Season

↓

2027 Season

↓

2028 Season
```

Season behaviour is defined in:

```
group-season-model.md
```

---

# Group Activities

Groups may organise:

- Casual Rounds
- Competitions
- Trips
- Championships
- Challenges
- Social Events

Future versions may include additional activity types.

---

# Relationships

A Group may contain:

- Friends
- Rounds
- Trips
- Seasons
- Statistics
- Achievements
- Photos
- Chat

Relationships are references rather than duplicated data.

---

# Business Rules

- Every Group has exactly one Owner.
- Members must be Qaddy users.
- Duplicate memberships are not permitted.
- Historical Groups remain accessible after completion.
- Removing a member does not delete historical rounds.
- Seasons belong to exactly one Group.
- Trips may belong to one Group or exist independently.

---

# Lifecycle

```
Created

↓

Active

↓

Archived

↓

Deleted
```

Archived Groups remain available for viewing but cannot create new rounds or trips.

Deleted Groups should be recoverable.

---

# Engineering Decisions

The Group model stores summary information only.

Feature-specific information belongs elsewhere:

- Round details → Round Data Model
- Trip details → Trip Data Model
- Member information → Friend Data Model
- Statistics → Statistics feature
- Achievements → Profile Achievements

This avoids duplicated data and keeps the architecture modular.

---

# Future Expansion

Future Group features may include:

- Clubhouses
- Public Groups
- Private Groups
- Club Championships
- League Tables
- Team Competitions
- Sponsorship
- Merchandise
- Events Calendar
- Group Notifications
- AI Insights
- Voting & Polls

---

# Flutter Implementation Notes

All Group functionality should remain inside:

```
lib/features/groups/
```

Reusable widgets may include:

- Group Card
- Group Header
- Member List
- Season Card
- Statistics Card
- Leaderboard
- Activity Feed

Widgets reused across multiple features should move into:

```
lib/core/widgets/
```

---

# Related Documents

- app-architecture.md
- friend-data-model.md
- friend-relationship-model.md
- group-permissions.md
- group-season-model.md
- round-data-model.md
- trip-data-model.md
- profile-achievements.md

---

**End of Document**