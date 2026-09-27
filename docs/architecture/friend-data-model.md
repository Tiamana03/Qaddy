# Friend Data Model

---

# Purpose

This document defines the Friend data model used throughout Qaddy.

A Friend represents another Qaddy user that has an accepted friendship connection with the current user.

The Friend model is the foundation for:

- Groups
- Trips
- Rounds
- Leaderboards
- Statistics
- Invitations
- Chat
- Rivalries
- Achievements

No implementation may introduce additional Friend fields without first updating this document.

---

# Friend Model

| Field | Type | Description |
|--------|------|-------------|
| id | String | Unique Friend identifier |
| userId | String | Linked Qaddy user ID |
| firstName | String | Friend's first name |
| lastName | String | Friend's last name |
| displayName | String | Preferred display name |
| initials | String | Avatar initials |
| profilePhoto | String? | Profile image |
| handicap | Double | Current golf handicap |
| homeClub | String | Home golf club |
| location | String | City or suburb |
| status | FriendStatus | Friendship status |
| favourite | bool | Favourite friend |
| lastPlayed | DateTime | Most recent round together |
| roundsPlayed | int | Total rounds together |
| createdAt | DateTime | Friendship created date |
| updatedAt | DateTime | Last updated |

---

# Friend Status

Every friendship must have one status.

```
Pending
Accepted
Declined
Blocked
Removed
```

Meaning:

Pending

Friend request has been sent.

Accepted

Both users are connected.

Declined

Friend request declined.

Blocked

Communication disabled.

Removed

Friendship previously existed but has been removed.

---

# Friendship Lifecycle

```
Request Sent
        │
        ▼
Pending
        │
 ┌──────┴──────┐
 ▼             ▼
Accepted    Declined
 │
 ▼
Removed
 │
 ▼
Blocked
```

---

# Friend Statistics

Each Friend stores summary statistics.

Examples:

- Rounds Played Together
- Wins Against Friend
- Losses
- Draws
- Average Score
- Average Stableford
- Best Score
- Best Round
- Longest Drive Wins
- Nearest Pin Wins

Detailed statistics belong in the Statistics feature.

The Friend model stores only summary information.

---

# Friend Preferences

Friends may expose optional preferences.

Examples:

- Preferred Tee Colour
- Walking or Cart
- Preferred Game Format
- Preferred Playing Days

These are optional and may expand in future releases.

---

# Friend Relationships

A Friend may belong to:

- Multiple Groups
- Multiple Trips
- Multiple Rounds

A Friend is never owned by a Group or Trip.

Groups and Trips reference Friends.

---

# Privacy

Each Friend controls their own visibility.

Examples:

- Handicap visibility
- Statistics visibility
- Online status
- Profile visibility

Privacy settings belong to the Profile feature.

---

# Business Rules

- A user cannot add themselves as a Friend.
- Duplicate friendships are not permitted.
- A blocked Friend cannot send invitations.
- Removed Friends retain historical statistics.
- Historical rounds must never be deleted when a friendship ends.
- Favourite Friends appear first throughout the application.

---

# Relationships

Friend

↓

Groups

↓

Trips

↓

Rounds

↓

Statistics

↓

Achievements

↓

Profile

---

# Engineering Decisions

The Friend model contains only relationship information.

It should never duplicate Profile information unnecessarily.

Detailed statistics remain inside the Statistics feature.

Chat history belongs to the Chat feature.

Achievements belong to the Profile feature.

This keeps the model lightweight and avoids duplicated data.

---

# Future Expansion

Future versions of the Friend model may support:

- Live Location
- Availability Status
- Skill Rating
- Playing Preferences
- Match History
- Voice Chat
- Messaging
- Shared Photo Albums
- Equipment Information
- AI Compatibility Score

Future additions should remain backwards compatible whenever possible.

---

# Flutter Implementation Notes

The Friend model should remain platform-independent.

UI widgets should consume the model rather than modifying it.

Shared Friend widgets should live inside:

```
lib/core/widgets/
```

Feature-specific Friend widgets should remain inside:

```
lib/features/friends/
```

The Friend model should be reused throughout the application instead of creating duplicate player objects.