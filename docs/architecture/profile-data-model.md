# Profile Data Model

**Version:** 1.0  
**Status:** Architecture Approved

---

# Purpose

This document defines the Profile data model used throughout Qaddy.

Every Qaddy user owns exactly one Profile.

The Profile acts as the central identity of the application, bringing together personal information, golfing statistics, achievements, friendships, groups, rounds, and trips.

No implementation may introduce additional Profile fields without updating this document.

---

# Overview

A Profile represents an individual golfer.

The Profile stores summary information and references other features rather than duplicating data.

Examples:

- Personal Details
- Handicap
- Home Course
- Statistics
- Achievements
- Friends
- Groups
- Trips
- Playing History

---

# Profile Model

| Field | Type | Description |
|--------|------|-------------|
| id | String | Unique Profile ID |
| userId | String | Linked authentication user |
| firstName | String | First name |
| lastName | String | Last name |
| displayName | String | Public display name |
| email | String | Email address |
| avatarUrl | String? | Profile photo |
| handicap | double | Current handicap |
| homeCourse | String? | Preferred golf course |
| location | String? | City or region |
| bio | String? | Player biography |
| favouriteClub | String? | Favourite golf club |
| favouriteCourse | String? | Favourite course |
| joinedDate | DateTime | Date joined Qaddy |
| lastActive | DateTime | Last activity |
| profileVisibility | ProfileVisibility | Privacy setting |
| status | ProfileStatus | Account status |

---

# Profile Status

Every Profile exists in one of the following states.

| Status | Description |
|----------|-------------|
| Active | Normal account |
| Inactive | Temporarily inactive |
| Suspended | Restricted account |
| Deleted | Soft deleted |

Profiles should never be permanently removed without explicit administrative action.

---

# Profile Visibility

Visibility determines who can view profile information.

Available options:

- Public
- Friends Only
- Private

Different sections of a Profile may support different visibility settings in future versions.

---

# Profile Summary

The Profile should present a summary of the golfer's activity, including:

- Current Handicap
- Home Course
- Total Rounds
- Total Trips
- Friends
- Groups
- Seasons Played
- Achievement Count
- Average Score
- Best Round

Detailed information belongs within its own feature.

---

# Relationships

A Profile may reference:

- Friends
- Groups
- Trips
- Rounds
- Seasons
- Statistics
- Achievements

These relationships should be stored as references rather than duplicated data.

---

# Business Rules

- Every authenticated user owns exactly one Profile.
- A Profile belongs to only one user.
- Display names should be unique where possible.
- Historical golfing data remains attached to the Profile.
- Deleted Profiles should preserve historical round data where required.

---

# Statistics

The Profile displays summary statistics sourced from the Statistics feature.

Examples include:

- Total Rounds
- Average Gross Score
- Average Net Score
- Stableford Average
- Birdies
- Eagles
- Pars
- Fairways Hit
- Greens in Regulation
- Longest Drive

Statistics should not be duplicated inside the Profile model.

---

# Achievements

Achievements are referenced from:

```
profile-achievements.md
```

The Profile displays:

- Achievement Count
- Recent Achievements
- Achievement Points
- Trophy Cabinet

Achievement logic belongs within the Achievement system.

---

# Friendships

Friendships are defined in:

```
friend-data-model.md
friend-relationship-model.md
```

The Profile may display:

- Friend Count
- Favourite Playing Partners
- Recent Activity
- Mutual Friends

---

# Groups

The Profile references Groups the player belongs to.

Examples:

- Saturday Boys
- Work Golf Club
- Family Golf

Group data remains inside:

```
group-data-model.md
```

---

# Trips

The Profile references golf trips the player has participated in.

Examples:

- Upcoming Trips
- Previous Trips
- Favourite Destination
- Courses Played

Trip details belong to:

```
trip-data-model.md
```

---

# Privacy

Users should control the visibility of:

- Profile Information
- Handicap
- Statistics
- Friends List
- Achievements
- Trips
- Groups

Privacy settings may expand in future versions.

---

# Engineering Decisions

The Profile acts as an aggregation layer.

It references data from other features rather than owning it.

This prevents duplicated information and keeps data consistent across the application.

---

# Future Expansion

Future Profile features may include:

- Player Levels
- Experience Points
- AI Golf Coach
- Golf Goals
- Equipment Tracking
- Swing Analysis
- Social Feed
- Verified Golf Clubs
- Custom Themes
- Digital Golf Passport
- Public Player Cards

Future additions should remain backwards compatible.

---

# Flutter Implementation Notes

Profile functionality should remain inside:

```
lib/features/profile/
```

Reusable widgets may include:

- Profile Header
- Player Card
- Handicap Badge
- Statistics Summary
- Achievement Grid
- Friends Preview
- Trip Preview
- Season History

Reusable components should move into:

```
lib/core/widgets/
```

when shared across multiple features.

---

# Related Documents

- app-architecture.md
- friend-data-model.md
- friend-relationship-model.md
- group-data-model.md
- group-season-model.md
- round-data-model.md
- statistics-data-model.md
- trip-data-model.md
- profile-achievements.md

---

## Release 1

Release 1 implements a documented subset of the Profile model.

Additional fields defined within this model are reserved for future releases.

See:

profile-engineering-decisions.md

---

**End of Document**