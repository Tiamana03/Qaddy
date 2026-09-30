# Notifications Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Notifications feature.

Per-document Engineering Decisions sections still apply where they exist (`notifications-data-model.md`); this document exists for decisions that span the whole feature rather than belonging to one model.

---

## Notifications Reuses Placeholder-Data.md's Existing Notifications

`placeholder-data.md` already had a "Notifications" section (four messages) before this feature existed, written for the Dashboard sprint. Rather than inventing a new, independent notification list, this feature classifies those same four messages into categories and gives them a screen.

**Why:** the same "Single Source of Truth" discipline already applied by Profile, Statistics and Golf Bag — read from where the data already lives instead of duplicating it.

**How to apply:** `lib/features/notifications/models/placeholder_notifications.dart` contains the four `NotificationItem` entries with text matching `placeholder-data.md` verbatim; it does not invent a fifth or alter the wording of the existing four.

---

## In-App Display Only — Push Delivery Is a Future Service

`docs/technical-architecture.md`'s "Services" section lists "Notifications" as an application service (alongside Authentication, AI, Analytics) — that service is responsible for actually delivering push notifications via FCM/APNs, and does not exist yet. This feature is the in-app screen that would display what such a service delivers, not the service itself.

**Why:** avoids conflating a UI screen with a backend service that has a completely different implementation (platform push integration, permissions, tokens) and is explicitly out of scope until Supabase/Authentication exists.

**How to apply:** Notifications has no delivery mechanism, no permission prompts and no real-time updates in Release 1 — see Scope in `docs/features/notifications-feature-integration.md`.

---

## Notifications Is Reached From Dashboard, Not the Bottom Navigation

`docs/architecture/navigation.md`'s "Bottom Navigation" Engineering Decision states: *"Five tabs represent the highest-frequency user journeys. Future features should extend existing tabs rather than creating additional bottom navigation destinations."* Dashboard is the application's home screen and already owns "Recent Activity" — the closest existing concept to a notification feed.

**Why:** matches the same reasoning already applied to Statistics and Golf Bag (both extend Profile) — Notifications extends Home instead of adding a sixth tab.

**How to apply:** route `/home/notifications`, nested under the existing Home branch, opened via a notification bell icon added to Dashboard's app bar (Dashboard did not have an app bar before this feature — see `docs/features/notifications-feature-integration.md`'s Navigation Flow for why adding one here is the minimal necessary change).

---

## Categories Exist So Settings Can Reference Them Without a Second List

`NotificationCategory` exists specifically so Settings' Notification Preferences section (see `settings-data-model.md`) can list "which kinds of notifications exist" by reading Notifications' own categories, rather than Settings inventing its own parallel category list.

**Why:** the two features would otherwise need to independently agree on the same four category names — defining them once, in Notifications, and having Settings reuse them removes that risk entirely.

**How to apply:** `lib/features/settings/models/placeholder_settings.dart` imports `NotificationCategory` from `package:qaddy/features/notifications/models/notification_item.dart` rather than declaring its own enum.

---

# Source of Truth

Notifications should never duplicate values already owned by another feature.

Whenever possible, Notifications derives information from:

- Placeholder-data.md's existing Notifications section

Only the category classification — which cannot be calculated or reused from elsewhere — is new to this feature.

---

# Related Documents

- notifications-data-model.md
- docs/features/notifications-feature-integration.md
- notifications-future-roadmap.md
- settings-engineering-decisions.md

---

**End of Document**
