# Friends Feature Integration

## Overview

This document defines how the complete Friends feature is integrated within Qaddy.

Friends is the social hub of Qaddy. It connects golfers through friendships, groups, activity, rivalries and search, bringing every social touchpoint into one connected experience.

This document does **not** define new functionality.

Instead, it explains how every Friends screen combines into one seamless feature and how users move naturally through the entire experience.

---

# Goals

The Friends feature should allow users to:

- View their friends
- View a friend's profile
- See what friends have been doing
- Send, accept and decline friend requests
- Search for other golfers
- View and open groups
- View group details, members and season standings
- View rivalries with other golfers
- Return to the Dashboard

The experience should feel like a natural social layer sitting on top of Rounds and Trips.

---

# Scope

This feature includes:

- Friends Home
- Friends List
- Friend Profile
- Activity Feed
- Friend Requests
- Search Friends
- Groups
- Group Details
- Rivalries
- Navigation
- Placeholder data
- Feature integration

This feature does **not** include:

- Realtime messaging
- Push notifications
- Nearby golfers
- QR friend requests
- Club integrations
- Mutual friends
- Achievements
- Live presence
- Supabase
- Authentication

All data remains placeholder driven. See `docs/architecture/friends-future-roadmap.md` for how these are expected to arrive later.

---

# Feature Flow

The complete Friends journey should follow the workflow below.

Dashboard

↓

Friends

↓

Friends Home

↓

Friends List

↓

Friend Profile

↓

Activity Feed

↓

Friend Requests

↓

Search Friends

↓

Groups

↓

Group Details

↓

Rivalries

↓

Dashboard

Every screen should naturally continue into the next stage of the social experience.

---

# Integration Objectives

The Friends feature should feel like one continuous experience.

Users should never feel like they are opening unrelated screens.

Each section should contribute toward understanding or growing the user's golf social circle.

---

# Navigation Flow

## Dashboard

Displays the Friends quick action.

Selecting it opens Friends Home.

---

## Friends Home

Displays:

- Friend Summary (Total, Confirmed, Pending)
- Quick Actions (View Friends, Search Friends, Requests, Groups, View Activity, View Rivalries)
- Activity Preview
- Pending Requests Preview

Acts as the central hub for the Friends feature. Activity Feed and Rivalries are reachable directly from here — not only through Friend Profile — so both stay within the Three Click Rule.

---

## Friends List

Displays:

- Every Confirmed friend
- Avatar, name, handicap
- Favourite indicator

Selecting a friend opens Friend Profile.

---

## Friend Profile

Displays:

- Avatar, name, home club, location
- Handicap
- Friendship status
- Shared history (rounds played together)
- Quick actions (View Activity, View Rivalry)

---

## Activity Feed

Displays:

- Chronological list of friend activity
- Actor, action, related entity, timestamp

---

## Friend Requests

Displays:

- Incoming requests (Accept / Decline)
- Outgoing requests (Cancel)

---

## Search Friends

Displays:

- Search field
- Matching results
- Add Friend action (placeholder only)

---

## Groups

Displays:

- Every group the user belongs to
- Member count, season, status

Selecting a group opens Group Details.

---

## Group Details

Displays:

- Group overview
- Members
- Season summary and leaderboard
- Upcoming group round

---

## Rivalries

Displays:

- Head-to-head record against a friend
- Wins, losses, draws
- Recent results

---

# Route Integration

The Friends feature should use the following routes.

| Route | Screen |
|---------|---------|
| /friends | Friends Home |
| /friends/list | Friends List |
| /friends/profile | Friend Profile |
| /friends/activity | Activity Feed |
| /friends/requests | Friend Requests |
| /friends/search | Search Friends |
| /friends/groups | Groups |
| /friends/groups/details | Group Details |
| /friends/rivalries | Rivalries |

No unnecessary routes should be introduced.

---

# Shared Placeholder Data

All Friends screens should reference the shared placeholder data defined in `docs/standards/placeholder-friend-data.md` and `docs/standards/placeholder-group-data.md`.

Per those documents' own conventions:

- **Tom** is the shared placeholder friend used throughout Friend Profile and Rivalries.
- **Saturday Boys** is the shared placeholder group used throughout Group Details (already documented as "the primary placeholder group used throughout development" in `placeholder-group-data.md`).

The following information should never be duplicated:

- Friends
- Friend Requests
- Activity
- Groups
- Group Members
- Season Standings
- Rivalries

Future backend integration will replace this placeholder data.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse where appropriate:

- QaddyAvatar
- QaddyCard
- QaddySectionCard
- QaddyStatusBadge
- QaddyPrimaryButton
- QaddySecondaryButton
- QaddyTripCard (as a pattern reference for list-row cards)
- ResponsivePadding
- ResponsiveMaxWidth
- ResponsiveBuilder

Create new widgets only when functionality does not already exist. See `docs/architecture/friends-engineering-decisions.md` for the widgets this feature is expected to introduce.

---

# Model Reuse

Reuse existing models wherever possible. The Friend and Group data models already exist and are the single source of truth — this feature must not redefine them.

Reuse:

- Friend (`friend-data-model.md`)
- FriendStatus, friendship lifecycle (`friend-relationship-model.md`)
- Group (`group-data-model.md`)
- Group permissions (`group-permissions.md`)
- Group seasons (`group-season-model.md`)

New models introduced by this feature only (see `docs/architecture/activity-feed.md` and `docs/architecture/rivalries.md`):

- ActivityFeedItem
- RivalryRecord

Avoid creating duplicate placeholder models.

---

# Button Behaviour

Buttons should perform the following actions.

| Button | Action |
|---------|---------|
| View Friends | Open Friends List |
| Search Friends | Open Search Friends |
| View Requests | Open Friend Requests |
| View Groups | Open Groups |
| Open Friend | Open Friend Profile |
| Open Group | Open Group Details |
| View Activity | Open Activity Feed |
| View Rivalry | Open Rivalries |
| Accept / Decline | Visual only (no backend) |
| Add Friend | Visual only (no backend) |
| Return Home | Open Dashboard |

Buttons should never remain disabled once the feature is integrated, except where explicitly marked "Visual only" above — those remain placeholder actions because no backend exists yet (see Scope).

---

# Placeholder State

All Friends information remains in memory.

No backend persistence exists during this feature's implementation.

Closing the application resets placeholder data.

Persistent storage will be implemented in a future release.

---

# Acceptance Criteria

The Friends feature is complete when a user can:

- View their friends
- Open a friend's profile
- View friend activity
- View, accept and decline friend requests (visually)
- Search for a friend
- View groups and open a group's details
- View a rivalry
- Return to the Dashboard

Additionally:

- No duplicate placeholder data exists
- Existing widgets are reused wherever possible
- Navigation has no dead ends
- All tests pass
- The feature behaves as one continuous workflow

---

# Future Integration

Future releases will replace placeholder functionality with:

- Supabase
- Realtime messaging
- Push notifications
- Nearby golfers
- QR friend requests
- Club integrations
- Mutual friends
- Achievements
- Live presence

See `docs/architecture/friends-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Friends functionality into one complete feature.
