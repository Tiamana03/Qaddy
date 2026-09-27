# Friend Profile

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the Friend Profile screen.

Friend Profile displays a single friend's details and shared history with the current user.

This document does not redefine the Friend model — see `friend-data-model.md` for every field. It only defines how that model is presented on screen.

Friend Profile is distinct from the user's own Profile feature (`profile-data-model.md`), which is a separate, future feature covering the current user's own settings and achievements.

---

# Screen Contents

Friend Profile displays:

- Avatar (initials placeholder)
- Display name
- Home club
- Location
- Handicap
- Friendship status badge
- Member since
- Rounds played together
- Last played together
- Quick actions

---

# Quick Actions

| Action | Result |
|---------|---------|
| View Activity | Opens Activity Feed |
| View Rivalry | Opens Rivalries |

---

# Shared Placeholder Friend

Release 1 displays one shared placeholder friend on this screen, per `docs/features/friends-feature-integration.md`'s "Shared Placeholder Data" section.

**Tom** is the shared placeholder friend — see `docs/standards/placeholder-friend-data.md`.

---

# Status Badge

Reuse `QaddyStatusBadge`.

Friendship status values are defined in `friend-data-model.md`'s Friend Status section (Pending, Confirmed, Declined, Blocked, Removed). Only Confirmed friends can be opened from Friends List, so Friend Profile only ever displays the Confirmed state.

---

# Do Not Build

Do not build:

- Editing a friend's details
- Messaging
- Blocking or removing a friend
- Mutual friends
- Achievements
- Photos

These belong to future releases — see `friends-future-roadmap.md`.

---

# Related Documents

- friend-data-model.md
- friend-relationship-model.md
- docs/standards/placeholder-friend-data.md
- rivalries.md
- activity-feed.md

---

**End of Document**
