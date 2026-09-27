# Rivalries

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the Rivalries screen and the Rivalry Record model.

Rivalries displays the current user's head-to-head record against a single friend.

No implementation may introduce additional Rivalry Record fields without first updating this document.

---

# Rivalry Record Model

| Field | Type | Description |
|--------|------|--------------|
| friendName | String | The rival friend's name |
| roundsPlayed | int | Total rounds played together |
| wins | int | Rounds the current user won |
| losses | int | Rounds the current user lost |
| draws | int | Rounds that ended level |
| lastResult | String | Description of the most recent result |

These fields are the same "Relationship Metrics" already documented in `friend-relationship-model.md` — this model exists only to give that data a concrete shape for the Rivalries screen. It does not introduce a new source of truth.

---

# Screen Contents

Rivalries displays:

- The rival's avatar and name
- Rounds Played, Wins, Losses, Draws (reuse `QaddyStatisticCard`)
- Last Result

---

# Shared Placeholder Rivalry

Release 1 displays one shared placeholder rivalry: the current user (Tiamana) against **Tom**, the shared placeholder friend used throughout Friend Profile.

Placeholder values are defined in `docs/standards/placeholder-friend-data.md`'s "Rivalries" section.

---

# Business Rules

- A Rivalry Record is derived from completed rounds, never manually entered — consistent with `friend-relationship-model.md`'s "Relationship Metrics" section.
- Rivalries only exist between Confirmed friends.

---

# Do Not Build

Do not build:

- Rivalries against more than one friend at a time
- Head-to-head hole-by-hole comparison
- Rivalry notifications or challenges
- Group rivalries

These belong to future releases — see `friends-future-roadmap.md`.

---

# Related Documents

- friend-relationship-model.md
- friend-profile.md
- docs/standards/placeholder-friend-data.md
- docs/features/friends-feature-integration.md

---

**End of Document**
