# Notifications Data Model

**Version:** 1.0

**Status:** Architecture Approved

---

# Purpose

This document defines the Notifications feature's data model.

Per `docs/roadmap/release-1-roadmap.md`'s Sprint goal, Notifications covers "push notifications, invitations, reminders and in-app notifications." `docs/technical-architecture.md`'s "Services" section separately lists "Notifications" as a future application service responsible for actually delivering push notifications — that service does not exist yet (no FCM/APNs integration, no Supabase). Release 1 implements the in-app half only: a Notifications screen displaying the notifications that would have been delivered.

No implementation may introduce additional Notifications fields without updating this document.

---

# Overview

Notifications displays a chronological list of in-app notifications, each classified into one of four categories so Settings' Notification Preferences section can reference them without inventing a second list.

---

# Notification Item Model

The one new model this feature introduces.

| Field | Type | Description |
|--------|------|-------------|
| id | String | Unique notification identifier |
| message | String | Display text |
| category | NotificationCategory | Which kind of notification this is |

---

# Notification Category

| Category | Description |
|----------|-------------|
| roundReminder | An upcoming round is starting soon |
| friendActivity | A friend accepted an invitation or request |
| tripUpdate | A trip requires attention (e.g. a payment) |
| systemUpdate | An application-level update or announcement |

No additional categories may be introduced without updating this document.

---

# Model Reuse

Notifications must not redefine or restate placeholder data that already exists. It reads its four placeholder messages from `placeholder-data.md`'s existing "Notifications" section (see `placeholder-notifications-data.md`) rather than inventing new ones.

---

# Business Rules

- Notifications are read-only in Release 1 — there is no backend to mark them read, dismiss them, or receive new ones in real time.
- Every notification belongs to exactly one category.
- The four Release 1 notifications and their categories must never diverge from `placeholder-notifications-data.md`.

---

# Out of Scope (Release 1)

- Actual push notification delivery (requires a notification service — see `technical-architecture.md`'s "Services" section — and Supabase/FCM/APNs integration).
- Marking notifications as read or dismissing them.
- Real-time/new notification arrival.
- Notification badges or counts beyond a simple total.
- User-configurable notification preferences (Settings displays which categories exist, but Release 1 has no toggle to disable them — see `settings-data-model.md`).

See `notifications-future-roadmap.md`.

---

# Engineering Decisions

See `docs/architecture/notifications-engineering-decisions.md` for the full reasoning, including where Notifications is reached from.

---

# Flutter Implementation Notes

Notifications functionality should remain inside:

```
lib/features/notifications/
```

The only new model types are `NotificationItem` and `NotificationCategory`. The four notification messages themselves are reused from `placeholder-data.md`, not duplicated.

---

# Related Documents

- docs/features/notifications-feature-integration.md
- notifications-engineering-decisions.md
- notifications-future-roadmap.md
- settings-data-model.md
- technical-architecture.md

---

**End of Document**
