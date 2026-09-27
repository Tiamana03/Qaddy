# Friends Overview

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the product vision for the Friends feature.

Friends is the social hub of Qaddy.

It connects golfers through:

- Friends
- Friend Profiles
- Activity Feed
- Groups
- Friend Requests
- Search
- Rivalries

This document does not define data models, placeholder data or navigation in detail — those live in their own documents (see Related Documents). It exists to describe what the feature is and why it matters before those documents are read.

---

# Design Principles

Friends should feel effortless.

A user should always know:

- Who their friends are
- What their friends have been doing
- Who they are playing against most often
- How to find someone new

Friends is the connective tissue between Rounds, Trips and Groups — it does not duplicate their data, it links to it.

---

# Release 1 Screens

| Screen | Purpose |
|---------|---------|
| Friends Home | Central hub for the Friends feature |
| Friends List | Every confirmed friend |
| Friend Profile | One friend's details and shared history |
| Activity Feed | Chronological friend activity |
| Friend Requests | Incoming and outgoing requests |
| Search Friends | Find another golfer |
| Groups | Every group the user belongs to |
| Group Details | One group's members, season and standings |
| Rivalries | Head-to-head record against a friend |

Full navigation and routing for each of these screens is defined in `docs/architecture/navigation.md` and `docs/features/friends-feature-integration.md`.

---

# Release 1 Scope

Messaging exists only as a placeholder for Release 1.

Notifications are placeholder only.

No live APIs.

No Supabase.

Placeholder data only.

---

# Out of Scope

The following are documented as future work but not implemented in Release 1:

- Realtime messaging
- Notifications
- Nearby golfers
- QR friend requests
- Club integrations
- Mutual friends
- Achievements
- Live presence

See `docs/architecture/friends-future-roadmap.md`.

---

# Related Documents

- friend-data-model.md
- friend-relationship-model.md
- friend-profile.md
- activity-feed.md
- friend-requests.md
- search.md
- groups.md
- group-details.md
- rivalries.md
- group-data-model.md
- group-permissions.md
- group-season-model.md
- friends-engineering-decisions.md
- friends-future-roadmap.md
- docs/standards/placeholder-friend-data.md
- docs/standards/placeholder-group-data.md
- docs/features/friends-feature-integration.md

---

**End of Document**
