# Settings Feature Integration

## Overview

This document defines how the complete Settings feature is integrated within Qaddy.

Settings is a read-only view of preferences that already exist elsewhere — Profile Visibility, notification categories, the current theme and the app version.

This document does **not** define new functionality.

Instead, it explains how Settings is reached from Profile and how it reuses data already established by Profile and Notifications.

---

# Goals

The Settings feature should allow users to:

- View their Privacy setting (Profile Visibility)
- View which notification categories exist
- View the current appearance (theme)
- View the application version
- Return to Profile

---

# Scope

This feature includes:

- Settings (single screen)
- Placeholder data
- Feature integration

This feature does **not** include:

- Editing Profile Visibility or any other preference
- A light theme or theme toggle
- Account management (sign-out, password, deletion)
- Language or region settings
- Notification preference toggles

All data remains placeholder driven. See `docs/architecture/settings-future-roadmap.md` for how these are expected to arrive later.

---

# Feature Flow

The complete Settings journey should follow the workflow below.

Dashboard

↓

Profile

↓

Settings

↓

Profile

Settings is a single destination reached from Profile, matching the "Release 1 Is One Aggregated Screen" pattern already used for Profile, Statistics and Golf Bag.

---

# Integration Objectives

Settings should never restate a value that already has a canonical source in Profile or Notifications.

---

# Navigation Flow

## Profile

Displays a "View Settings" quick link, alongside the existing "View Statistics" and "View Golf Bag" links.

Selecting it opens Settings.

---

## Settings

Displays, in order:

- Privacy — Profile Visibility
- Notification Preferences — every notification category, shown as Enabled
- Appearance — Theme
- Application — App Version

No section links to another screen — Release 1 has nothing further to open (see Scope).

---

# Route Integration

Settings is nested under the existing Profile route, per `navigation.md`.

| Route | Screen |
|---------|---------|
| /profile/settings | Settings |

No new top-level route or bottom-navigation destination is introduced.

---

# Shared Placeholder Data

Settings displays the same shared placeholder user, **Tiamana**, already used throughout every other Release 1 feature.

The following information must never be duplicated as new literals — it is read from its existing source instead:

- Profile Visibility (`Profile.profileVisibility`, via the new `profileVisibilityLabel()` helper — also now used by Profile's own Details card, replacing a previously hardcoded duplicate string)
- Notification categories (`NotificationCategory.values`)

The only new value is the App Version string, sourced from `pubspec.yaml`.

Future backend integration will replace this placeholder data.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- QaddyCard
- QaddySectionCard
- QaddyStatusBadge — for each Notification Preference's "Enabled" status
- QaddyInfoRow — for Privacy, Appearance and Application rows

Create new widgets only when functionality does not already exist.

---

# Model Reuse

Reuse existing models and placeholder data wherever possible. Settings must not redefine or restate Profile or Notifications data — see `settings-data-model.md`, which introduces no new model at all.

Reuse:

- `Profile`, `profileVisibilityLabel()` (`profile.dart`)
- `NotificationCategory`, `notificationCategoryLabel()` (`notification_item.dart`)

---

# Button Behaviour

| Button | Action |
|---------|---------|
| View Settings (on Profile) | Open Settings |
| Back | Return to Profile |

No other interactive buttons exist in Release 1 — every Settings row is read-only display data (see Scope, "Editing Profile Visibility or any other preference").

---

# Placeholder State

All Settings information remains in memory.

No backend persistence exists during this feature's implementation.

Closing the application resets placeholder data.

Persistent storage will be implemented in a future release.

---

# Acceptance Criteria

The Settings feature is complete when a user can:

- Open Settings from Profile
- View their Privacy, Notification Preferences, Appearance and Application information
- Return to Profile

Additionally:

- No duplicate placeholder data exists — every value is read from Profile or Notifications, not restated
- Existing widgets are reused wherever possible
- Navigation has no dead ends
- All tests pass
- The feature behaves as a natural extension of Profile

---

# Future Integration

Future releases will replace placeholder functionality with:

- Supabase
- Editable Profile Visibility
- A light theme and theme toggle
- Editable notification preferences
- Account management
- Language and region settings

See `docs/architecture/settings-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Settings functionality into one complete feature.
