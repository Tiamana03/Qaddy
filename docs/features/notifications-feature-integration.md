# Notifications Feature Integration

## Overview

This document defines how the complete Notifications feature is integrated within Qaddy.

Notifications displays the in-app notification feed — the four notifications already documented in `placeholder-data.md`, now classified and given their own screen.

This document does **not** define new functionality.

Instead, it explains how Notifications is reached from Dashboard and how it reuses data that already existed before this feature began.

---

# Goals

The Notifications feature should allow users to:

- View their in-app notifications
- Understand what each notification relates to
- Return to Dashboard

---

# Scope

This feature includes:

- Notifications (single screen)
- Placeholder data
- Feature integration

This feature does **not** include:

- Actual push notification delivery (a future application service — see `notifications-future-roadmap.md`)
- Marking notifications as read or dismissing them
- Real-time notification arrival
- Notification badges or unread counts
- User-configurable preferences (see `settings-feature-integration.md` for the read-only Settings view of notification categories)

All data remains placeholder driven. See `docs/architecture/notifications-future-roadmap.md` for how these are expected to arrive later.

---

# Feature Flow

The complete Notifications journey should follow the workflow below.

Dashboard

↓

Notifications

↓

Dashboard

Notifications is a single destination reached from Dashboard.

---

# Integration Objectives

Notifications should never restate a message that already exists in `placeholder-data.md`.

---

# Navigation Flow

## Dashboard

Displays a notification bell icon in a new app bar (Dashboard previously had none — `QaddyScaffold`'s `appBar` parameter was simply omitted).

Selecting it opens Notifications.

---

## Notifications

Displays, in order:

- Notification Summary — Total Notifications
- The four notifications, each with an icon derived from its category

No section links to another screen — Release 1 has nothing further to open (see Scope).

---

# Route Integration

Notifications is nested under the existing Home route, per `navigation.md`.

| Route | Screen |
|---------|---------|
| /home/notifications | Notifications |

No new bottom-navigation destination is introduced.

---

# Shared Placeholder Data

Notifications displays the same shared placeholder user, **Tiamana**, already used throughout every other Release 1 feature.

The following information must never be duplicated as new literals — it is read from `placeholder-data.md`'s existing "Notifications" section instead:

- The four notification messages

Total Notifications is computed from that same list, not new data.

Future backend integration will replace this placeholder data.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- QaddyCard
- QaddySectionCard
- QaddyStatisticCard — for Notification Summary
- QaddyInfoRow — is not used here since notifications are message-only rows, not label/value pairs; a small local row widget is used instead, matching the precedent already set by `ActivityFeedTile` (Friends) for an icon-plus-message-plus-row layout

Create new widgets only when functionality does not already exist.

---

# Model Reuse

Reuse existing models and placeholder data wherever possible. Notifications must not redefine or restate Dashboard's existing placeholder messages.

New models introduced by this feature only:

- `NotificationItem`, `NotificationCategory` (`notifications-data-model.md`) — `NotificationCategory` is also reused directly by Settings, not redeclared there.

Avoid creating duplicate placeholder models.

---

# Button Behaviour

| Button | Action |
|---------|---------|
| Notification bell (on Dashboard) | Open Notifications |
| Back | Return to Dashboard |

No other interactive buttons exist in Release 1 — every Notifications row is read-only display data (see Scope, "Marking notifications as read or dismissing them").

---

# Placeholder State

All Notifications information remains in memory.

No backend persistence exists during this feature's implementation.

Closing the application resets placeholder data.

Persistent storage will be implemented in a future release.

---

# Acceptance Criteria

The Notifications feature is complete when a user can:

- Open Notifications from Dashboard
- View all four notifications
- Return to Dashboard

Additionally:

- No duplicate placeholder data exists — messages are read from `placeholder-data.md`, not restated
- Existing widgets are reused wherever possible
- Navigation has no dead ends
- All tests pass
- The feature behaves as a natural extension of Dashboard

---

# Future Integration

Future releases will replace placeholder functionality with:

- Supabase
- Push notification delivery
- Marking notifications read/dismissing them
- Real-time arrival
- Notification badges and counts
- User-configurable preferences
- Deep linking from notifications to their related screen

See `docs/architecture/notifications-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Notifications functionality into one complete feature.
