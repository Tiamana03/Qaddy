# Friends Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Friends feature (Friends Home, Friends List, Friend Profile, Activity Feed, Friend Requests, Search Friends, Groups, Group Details, Rivalries).

Per-document Engineering Decisions sections still apply where they exist (`friend-data-model.md`, `friend-relationship-model.md`, `group-data-model.md`); this document exists for decisions that span multiple Friends screens rather than belonging to one model.

---

## Reuse Group and Friend Models Directly

Groups and Friends already have complete architecture documents (`friend-data-model.md`, `friend-relationship-model.md`, `group-data-model.md`, `group-permissions.md`, `group-season-model.md`) and placeholder data (`placeholder-friend-data.md`, `placeholder-group-data.md`).

The Friends feature's screen-level documents (`friend-profile.md`, `groups.md`, `group-details.md`, etc.) intentionally do not redefine these models — they only describe how the existing models are presented on screen.

**Why:** avoids duplicated models and duplicated placeholder data, per the project's engineering standards.

---

## Two New Models Only

The Friends feature introduces exactly two new models, because nothing existing covers their shape:

- `ActivityFeedItem` (see `activity-feed.md`)
- `RivalryRecord` (see `rivalries.md`)

Every other screen displays an existing model (Friend, Group) or a simple derived value.

---

## Shared Placeholder Subjects

Consistent with the Rounds feature (one shared round) and Trips feature (one shared trip, Melbourne Golf Weekend), the Friends feature designates:

- **Tom** as the shared placeholder friend for Friend Profile and Rivalries.
- **Saturday Boys** as the shared placeholder group for Group Details — already documented as the primary placeholder group in `placeholder-group-data.md`.

**Why:** keeps detail screens consistent and avoids inventing a second, redundant "detailed" placeholder subject.

---

## Friends List Shows Confirmed Friends Only

`friend-relationship-model.md` states "Only Confirmed friendships can participate in Qaddy social features." Friends List therefore filters the placeholder Friends table (`placeholder-friend-data.md`) to Confirmed entries only; Pending and Declined entries surface on Friend Requests instead.

**Why:** keeps the two screens' content non-overlapping and consistent with the documented relationship lifecycle.

---

## Visual-Only Actions Are Explicit, Not Silent

Accept, Decline, Cancel and Add Friend are documented as "Visual only" in `docs/features/friends-feature-integration.md`'s Button Behaviour table, rather than being silently non-functional.

**Why:** the Master Feature Implementation workflow requires "Buttons should never remain disabled once the feature is integrated" — these are the explicit, documented exception, because no backend exists yet, not an oversight.

---

## Potential New Widgets

The following widgets do not exist yet and may be required during implementation:

- `FriendCard` (Friends List row)
- `ActivityFeedTile` (Activity Feed row)
- `FriendRequestRow` (Friend Requests row, with Accept/Decline)
- `GroupCard` (Groups row)
- `RivalryStatCard` (or direct reuse of `QaddyStatisticCard`)

Each should be evaluated against existing widgets (`QaddyTripCard`, `PlayerCard`, `LeaderboardRow`) before being built, per the Master Feature Implementation workflow's "Repository Reuse Review" phase.

---

# Related Documents

- friends-overview.md
- docs/features/friends-feature-integration.md
- friends-future-roadmap.md

---

**End of Document**
