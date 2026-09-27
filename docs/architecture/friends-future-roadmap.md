# Friends Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Friends feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

---

## Realtime Messaging

Direct and group messaging between friends.

Depends on a backend (Supabase) and a message delivery service.

Release 1 shows a placeholder Trip Chat pattern only within the Trips feature (`docs/features/trips-feature-integration.md`); Friends has no chat surface at all in Release 1.

---

## Notifications

Push and in-app notifications for friend requests, activity, and rivalry results.

Depends on a notifications service and platform permissions.

---

## Nearby Golfers

Suggests other golfers physically nearby using location services.

Depends on location permissions and a discovery backend.

---

## QR Friend Requests

Scan a QR code to send a friend request instantly.

Depends on a camera/QR scanning package and a backend request handler.

---

## Club Integrations

Linking a user's home club membership to their Qaddy profile, enabling club-verified friend suggestions.

Depends on third-party club membership systems.

---

## Mutual Friends

Displaying friends in common on a Friend Profile.

Depends on a backend capable of querying the full social graph — not derivable from placeholder data.

---

## Achievements

Friend-facing achievement badges (e.g. "First Round Together", "Rivalry Champion").

Depends on the Profile feature's `profile-achievements.md`, which defines the achievement system this would extend.

---

## Live Presence

Showing whether a friend is currently online, in a round, or available to play — matching the "Online / In Game / Busy / Offline" status pills already documented in the Badges Library asset.

Depends on a realtime presence backend.

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `friend-data-model.md` and `activity-feed.md` — a Purpose section, a data model table, business rules, and a Do Not Build section for whatever remains out of scope at that time.

---

# Related Documents

- friends-overview.md
- docs/features/friends-feature-integration.md
- friends-engineering-decisions.md

---

**End of Document**
