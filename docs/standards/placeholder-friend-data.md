# Placeholder Friend Data

**Version:** 1.0  
**Status:** Approved Placeholder Data

---

# Purpose

This document defines the official placeholder friend data used throughout Qaddy.

All friend-related screens, widgets, and sprint implementations must use this data.

No AI or developer may invent additional placeholder friends or modify existing values without updating this document.

---

# Friends

| Name | Handicap | Status | Favourite Course | Home Club | Member Since |
|------|----------|---------|------------------|------------|--------------|
| Tom | 8 | Confirmed | Richmond Golf Club | Richmond Golf Club | Jan 2022 |
| Ben | 12 | Confirmed | Brookwater Golf Club | Pacific Harbour | Mar 2021 |
| Luke | 5 | Confirmed | Royal Queensland | Royal Queensland | Jun 2020 |
| Josh | 15 | Pending | Virginia Golf Club | Virginia | Jul 2023 |
| Nick | 10 | Confirmed | Wantima Country Club | Wantima | Apr 2022 |
| Sam | 18 | Pending | Indooroopilly Golf Club | Indooroopilly | Sep 2023 |
| Liam | 7 | Confirmed | Nudgee Golf Club | Nudgee | Feb 2021 |
| Jack | 22 | Declined | Gailes Golf Club | Gailes | Nov 2022 |

---

# Friend Details

Additional Friend model fields not shown in the summary table above — see `friend-data-model.md` for `favourite`, `location`, `roundsPlayed` and `lastPlayed`.

| Name | Favourite | Location | Rounds Played Together | Last Played Together |
|------|:---------:|----------|------------------------:|-----------------------|
| Tom | Yes | Richmond, VIC | 12 | Today |
| Ben | No | Ipswich, QLD | 8 | Yesterday |
| Luke | Yes | Brisbane, QLD | 15 | 3 days ago |
| Josh | No | Brisbane, QLD | 4 | 2 weeks ago |
| Nick | No | Bray Park, QLD | 6 | 3 days ago |
| Sam | No | Indooroopilly, QLD | 2 | 1 month ago |
| Liam | No | Nudgee, QLD | 9 | 4 days ago |
| Jack | No | Gailes, QLD | 1 | 6 months ago |

---

# Friend Summary

Total Friends

```
8
```

Confirmed Friends

```
5
```

Pending Friends

```
2
```

Declined Friends

```
1
```

Average Handicap

```
12
```

---

# Friend Status Definitions

## Confirmed

Friend has accepted the invitation or request.

---

## Pending

Invitation has been sent but not yet accepted.

---

## Declined

Invitation declined or unavailable.

---

# Example Friend Card

```
Tom

Handicap: 8

Status: Confirmed

Favourite Course:
Richmond Golf Club

Member Since:
January 2022
```

---

# Friend Statistics

These placeholder values may be used when displaying summary cards.

| Statistic | Value |
|-----------|------:|
| Friends | 8 |
| Confirmed | 5 |
| Pending | 2 |
| Declined | 1 |
| Average Handicap | 12 |

---

# Favourite Courses

| Course |
|----------|
| Richmond Golf Club |
| Brookwater Golf Club |
| Royal Queensland |
| Virginia Golf Club |
| Wantima Country Club |
| Indooroopilly Golf Club |
| Nudgee Golf Club |
| Gailes Golf Club |

---

# Search Examples

Common search examples:

- Tom
- Ben
- Luke
- Josh
- Nick
- Sam
- Liam
- Jack

---

# Avatar Initials

| Name | Initials |
|------|----------|
| Tom | TO |
| Ben | BE |
| Luke | LU |
| Josh | JO |
| Nick | NI |
| Sam | SA |
| Liam | LI |
| Jack | JA |

---

# Friend Requests

Pending friendships are split by direction for the Friend Requests screen.

## Incoming

| Name | Handicap | Sent |
|------|----------|------|
| Sam | 18 | 3 days ago |

## Outgoing

| Name | Handicap | Sent |
|------|----------|------|
| Josh | 15 | 5 days ago |

Both Sam and Josh already appear in the Friends table above with Status "Pending" — this section only adds which direction each request travelled. See `friend-requests.md`.

---

# Activity Feed

Friend-scoped activity, distinct from the Dashboard's own "Recent Activity" (which shows the current user's activity only). See `activity-feed.md`.

| Actor | Type | Message | When |
|-------|------|---------|------|
| Tom | RoundCompleted | Tom completed a round at Richmond Golf Club | 2 hours ago |
| Ben | GroupJoined | Ben joined Saturday Boys | Yesterday |
| Luke | HandicapChanged | Luke's handicap improved to 5 | 2 days ago |
| Nick | TripCreated | Nick created Gold Coast Golf Escape | 3 days ago |
| Liam | AchievementUnlocked | Liam unlocked Personal Best | 4 days ago |

---

# Rivalries

The shared placeholder rivalry is between the current user (Tiamana) and Tom. See `rivalries.md`.

| Field | Value |
|-------|-------|
| Friend | Tom |
| Rounds Played | 12 |
| Wins | 6 |
| Losses | 5 |
| Draws | 1 |
| Last Result | Won by 2 strokes at Richmond Golf Club |

---

# Future Placeholder Data

Future versions of this document may include:

- Profile Photos
- Golf Bio
- Playing Style
- Preferred Tee Colour
- Average Stableford
- Home Course Coordinates
- Favourite Playing Partners
- Longest Drive
- Fairways Hit %
- Greens in Regulation %
- Putting Average

These values should not be introduced until required by a future sprint.

---

# Engineering Notes

This document supplies placeholder content only.

Business rules belong in:

- friend-data-model.md
- friend-relationship-model.md
- activity-feed.md
- friend-requests.md
- rivalries.md

Implementation details belong inside the relevant sprint documentation.

---

# Related Documents

- friend-data-model.md
- friend-relationship-model.md
- friend-profile.md
- friend-requests.md
- activity-feed.md
- rivalries.md
- search.md
- placeholder-data.md
- placeholder-trip-data.md
- placeholder-group-data.md
- profile-data-model.md
- docs/features/friends-feature-integration.md

---

**End of Document**