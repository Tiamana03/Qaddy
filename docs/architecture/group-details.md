# Group Details

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the Group Details screen within the Friends feature.

Group Details displays one group's overview, members, season standings and upcoming round.

This document does not redefine the Group model — see `group-data-model.md`, `group-permissions.md` and `group-season-model.md`. It only defines how that data is presented on screen.

---

# Screen Contents

Group Details displays:

## Group Overview

- Name
- Owner
- Member count
- Status
- Home course
- Competition format
- Created date

## Members

- Avatar, name, handicap per member

Group membership has no per-member status — see `group-data-model.md`, which defines status only at the group level.

## Season Summary

- Season name
- Rounds completed
- Rounds remaining
- Current leader
- Average attendance

## Leaderboard

- Season standings (rank, player, points)

## Upcoming Group Round

- Course, date, tee time, competition, players, side games

---

# Shared Placeholder Group

Release 1 displays one shared placeholder group on this screen, per `docs/features/friends-feature-integration.md`'s "Shared Placeholder Data" section.

**Saturday Boys** is the shared placeholder group — already documented in `docs/standards/placeholder-group-data.md` as "the primary placeholder group used throughout development."

---

# Widget Reuse

Reuse `QaddyAvatar`, `QaddyStatusBadge`, `QaddySectionCard`, and the same position/leaderboard-row pattern established for Rounds (`PositionBadge`, `LeaderboardRow`) as a reference for the season leaderboard's layout — see `docs/architecture/friends-engineering-decisions.md` for whether a new widget is required or the Rounds pattern is directly reusable.

---

# Do Not Build

Do not build:

- Editing group details
- Managing members (add/remove/promote)
- Creating a new season
- Group chat
- Group photos

These belong to future releases — see `friends-future-roadmap.md`.

---

# Related Documents

- group-data-model.md
- group-permissions.md
- group-season-model.md
- docs/standards/placeholder-group-data.md
- groups.md
- docs/features/friends-feature-integration.md

---

**End of Document**
