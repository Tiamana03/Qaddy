# Notifications Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Notifications feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

---

## Push Notification Delivery

Actual delivery via FCM (Android) and APNs (iOS), including permission prompts and device token management.

Depends on the Notifications application service named in `technical-architecture.md`'s "Services" section, and on Supabase/Authentication existing to associate tokens with a real user.

---

## Marking Notifications Read or Dismissing Them

Any interaction that changes a notification's state.

Depends on a backend — Release 1's Notifications screen is entirely read-only placeholder data, consistent with every other Release 1 feature.

---

## Real-Time Notification Arrival

New notifications appearing live while the app is open, via Supabase Realtime.

---

## User-Configurable Notification Preferences

Turning individual notification categories on or off. Release 1's Settings screen displays which categories exist (see `settings-data-model.md`) but has no functioning toggle.

---

## Notification Badges and Counts

A badge on the Home tab or app icon showing an unread count.

---

## Deep Linking From Notifications

Tapping a notification (e.g. "Trip payment due this Friday") navigating directly to the relevant screen (Trip Expenses).

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `notifications-data-model.md` — a Purpose section, a data model table, business rules, and a Do Not Build / Out of Scope section for whatever remains deferred at that time.

---

# Related Documents

- notifications-data-model.md
- notifications-engineering-decisions.md
- docs/features/notifications-feature-integration.md

---

**End of Document**
