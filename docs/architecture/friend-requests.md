# Friend Requests

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the Friend Requests screen.

Friend Requests displays every Pending friendship, split by direction, and lets the user respond to them visually.

This document does not redefine friendship rules — see `friend-relationship-model.md` for the full lifecycle. It only defines how Pending friendships are presented on screen.

---

# Screen Contents

Friend Requests displays two sections:

## Incoming Requests

Requests sent to the current user by another golfer.

Each row displays:

- Avatar
- Name
- Handicap
- Accept action
- Decline action

## Outgoing Requests

Requests the current user has sent to another golfer.

Each row displays:

- Avatar
- Name
- Handicap
- Cancel action

---

# Button Behaviour

| Button | Result |
|---------|---------|
| Accept | Visual only — no backend |
| Decline | Visual only — no backend |
| Cancel | Visual only — no backend |

Per `friend-relationship-model.md`, only Confirmed friendships participate in the rest of the Friends feature — accepting or declining here does not move a placeholder request into the Friends List, since no backend exists yet.

---

# Placeholder Data

Incoming and outgoing request examples are defined in `docs/standards/placeholder-friend-data.md`'s "Friend Requests" section.

---

# Business Rules

Inherited directly from `friend-relationship-model.md`:

- Users cannot add themselves.
- Duplicate requests are not permitted.
- Existing friends cannot receive another request.
- Blocked users cannot send requests.

---

# Do Not Build

Do not build:

- Actually accepting/declining a request (no backend)
- Push notifications for new requests
- Request messages or notes

These belong to future releases — see `friends-future-roadmap.md`.

---

# Related Documents

- friend-relationship-model.md
- friend-data-model.md
- docs/standards/placeholder-friend-data.md
- docs/features/friends-feature-integration.md

---

**End of Document**
