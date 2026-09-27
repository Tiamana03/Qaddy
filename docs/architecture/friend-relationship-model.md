# Friend Relationship Model

---

# Purpose

This document defines how friendships are created, managed, and maintained throughout Qaddy.

It establishes the rules governing relationships between users, ensuring consistent behaviour across every feature.

All friendship-related functionality must follow this document.

---

# Overview

A Friend relationship is a mutual connection between two Qaddy users.

Friendships allow users to:

- Invite each other to Trips
- Join Groups together
- Play Rounds together
- Compare Statistics
- View Leaderboards
- Share Photos
- Participate in Challenges
- Build Rivalries

A relationship exists independently of any specific Trip, Group, or Round.

---

# Relationship States

Every friendship must exist in one of the following states.

| State | Description |
|--------|-------------|
| Pending | Friend request has been sent |
| Accepted | Both users are connected |
| Declined | Friend request rejected |
| Blocked | Communication prevented |
| Removed | Friendship ended |

---

# Relationship Lifecycle

```
No Relationship
        │
        ▼
Friend Request Sent
        │
        ▼
Pending
   ┌────┴────┐
   ▼         ▼
Accepted  Declined
   │
   ▼
Removed
   │
   ▼
Blocked
```

Only Accepted friendships can participate in Qaddy social features.

---

# Friend Request Rules

A user may send a friend request to another registered Qaddy user.

Rules:

- Users cannot add themselves.
- Duplicate requests are not permitted.
- Existing friends cannot receive another request.
- Blocked users cannot send requests.
- Removed users must send a new request to reconnect.

---

# Accepted Friendships

Accepted friends may:

- Join Trips together
- Join Groups together
- Invite one another to Rounds
- Compare Statistics
- View Public Profiles
- Receive Activity Updates
- Participate in Challenges

---

# Removed Friendships

Removing a friend:

- Ends the active friendship.
- Prevents new invitations.
- Removes them from the Friends list.

Removing a friend does not:

- Delete historical rounds.
- Delete trip history.
- Delete statistics.
- Delete achievements.
- Delete leaderboard history.

Historical data must always remain intact.

---

# Blocked Relationships

Blocking another user:

- Removes the friendship.
- Prevents communication.
- Prevents invitations.
- Prevents future friend requests until unblocked.

Historical data remains unchanged.

---

# Relationship Permissions

| Feature | Pending | Accepted | Removed | Blocked |
|----------|----------|----------|----------|----------|
| View Profile | Limited | Yes | Limited | No |
| Invite to Trip | No | Yes | No | No |
| Invite to Round | No | Yes | No | No |
| Join Groups | No | Yes | No | No |
| Compare Statistics | No | Yes | No | No |
| Send Messages | No | Yes | No | No |

---

# Shared History

Friend relationships preserve shared history.

Examples include:

- Rounds Played Together
- Trips Attended
- Group Memberships
- Tournament Results
- Achievements
- Photos
- Rivalries

Shared history should never be deleted when a friendship ends.

---

# Relationship Metrics

Qaddy may calculate metrics including:

- Total Rounds Together
- Wins
- Losses
- Draws
- Average Score Difference
- Stableford Difference
- Longest Drive Wins
- Nearest Pin Wins
- Trips Together
- Years as Friends

These metrics are derived from existing data rather than manually entered.

---

# Business Rules

- Every friendship involves exactly two users.
- Friendships are always mutual.
- A user cannot have duplicate friendships.
- Historical data must be preserved.
- Blocking overrides every other relationship state.
- Removing a friend does not remove shared history.

---

# Relationships

```
User
 │
 ├── Friend Relationship
 │
 ├── Groups
 │
 ├── Trips
 │
 ├── Rounds
 │
 ├── Statistics
 │
 └── Profile
```

Friend relationships act as the social connection between every major feature.

---

# Engineering Decisions

Friend relationship data is intentionally lightweight.

It stores only the relationship itself.

Feature-specific information remains inside:

- Groups
- Trips
- Statistics
- Profile
- Achievements

This avoids duplicated data and keeps the architecture modular.

---

# Future Expansion

Future versions may include:

- Best Friends
- Close Friends
- Playing Partners
- Rivalries
- Family Members
- Club Members
- Availability Status
- Live Activity
- Shared Calendars
- AI Friend Recommendations

Future additions should remain backwards compatible.

---

# Flutter Implementation Notes

Friend relationship logic should remain separate from UI.

Relationship validation should occur before actions such as:

- Sending invitations
- Joining groups
- Starting trips
- Creating rounds

Widgets should consume relationship state rather than implementing business rules directly.

Relationship services should be reusable across the entire application.