# Settings Data Model

**Version:** 1.0

**Status:** Architecture Approved

---

# Purpose

This document defines the Settings feature's data model.

Per `docs/roadmap/release-1-roadmap.md`'s Sprint goal, Settings covers "user preferences, appearance, privacy and application settings." `docs/architecture/navigation.md`'s Profile section already named Settings as one of Profile's own future expansions before this feature existed.

No implementation may introduce additional Settings fields without updating this document.

---

# Overview

Settings displays four read-only sections:

- Privacy — the user's Profile Visibility
- Notification Preferences — which notification categories exist
- Appearance — the current theme
- Application — the app version

Settings introduces **no new data model**. Every value it shows already exists somewhere else in the application; Settings is purely a presentation surface over Profile, Notifications and the application itself. This is a deliberate consequence of Release 1 being entirely read-only (see Business Rules) — there is no setting a user can actually change yet, so there is nothing new to model.

---

# Model Reuse

Settings must not redefine or restate any of the following. It reads them directly.

| Source | Reused for |
|---------|-----------|
| `profile-data-model.md` (`Profile.profileVisibility`) | Privacy section |
| `notifications-data-model.md` (`NotificationCategory`) | Notification Preferences section |
| `pubspec.yaml` (`version`) | Application section's App Version |

---

# Business Rules

- Every Settings row is read-only in Release 1 — there is no backend to persist a changed preference.
- Notification Preferences displays every `NotificationCategory` as enabled; Release 1 has no mechanism to disable one (see `notifications-future-roadmap.md`'s "User-Configurable Notification Preferences").
- Appearance displays exactly one theme (Dark) because exactly one theme (`QaddyTheme.dark`) exists in the codebase — a theme toggle must never be shown until a second theme actually exists.

---

# Out of Scope (Release 1)

- Editing Profile Visibility, or any other preference.
- A light theme, or any theme toggle.
- Account management, password changes or sign-out (no authentication exists yet).
- Language or region settings.
- Notification preference toggles.

See `settings-future-roadmap.md`.

---

# Engineering Decisions

See `docs/architecture/settings-engineering-decisions.md` for the full reasoning, including why this document introduces no new model.

---

# Flutter Implementation Notes

Settings functionality should remain inside:

```
lib/features/settings/
```

No new model file is required — Settings reads `Profile`, `NotificationCategory` and a single hardcoded version string sourced from `pubspec.yaml` directly.

---

# Related Documents

- profile-data-model.md
- notifications-data-model.md
- docs/features/settings-feature-integration.md
- settings-engineering-decisions.md
- settings-future-roadmap.md

---

**End of Document**
