# Search Friends

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the Search Friends screen.

Search Friends lets a user find another golfer by name.

---

# Screen Contents

Search Friends displays:

- A search field (reuse `QaddySearchField`, see `design/ui-components/forms`)
- Matching results as the user types
- An Add Friend action per result

---

# Matching Rules

Search matches against the placeholder golfer directory defined in `docs/standards/placeholder-friend-data.md`'s "Search Examples" section.

Matching is case-insensitive and matches on any part of the name.

No backend search exists yet — matching happens against the placeholder list only.

---

# Button Behaviour

| Button | Result |
|---------|---------|
| Add Friend | Visual only — no backend |

---

# Empty State

If no results match, reuse `QaddyEmptyState` (see `docs/sprints/sprint-01-3-shared-components.md`).

---

# Do Not Build

Do not build:

- Real search against a user database
- QR code search
- Nearby golfers
- Filtering by handicap, club or location

These belong to future releases — see `friends-future-roadmap.md`.

---

# Related Documents

- friend-data-model.md
- docs/standards/placeholder-friend-data.md
- docs/features/friends-feature-integration.md

---

**End of Document**
