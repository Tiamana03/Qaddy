# Settings Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Settings feature.

Per-document Engineering Decisions sections still apply where they exist (`settings-data-model.md`); this document exists for decisions that span the whole feature rather than belonging to one model.

---

## Settings Introduces No New Model

Every value Settings displays — Profile Visibility, notification categories, the current theme, the app version — already exists somewhere else. Release 1 has no editable preference anywhere in the application, so there is no state for a Settings-owned model to hold.

**Why:** creating a model purely to wrap read-only pass-through values would be exactly the kind of unnecessary complexity `docs/ai/project-rules.md`'s "Code Quality" section warns against ("Prefer... simple solutions... Avoid unnecessary complexity").

**How to apply:** `lib/features/settings/ui/screens/settings_screen.dart` reads `Profile.profileVisibility`, `NotificationCategory.values` and a hardcoded version string directly — there is no `lib/features/settings/models/` directory.

---

## Profile Visibility Is Derived, Not Restated as a Second Literal

Profile's own Details card previously hardcoded the string `'Friends Only'` rather than deriving it from `profile.profileVisibility`. Settings needed the same label, which would have meant either duplicating that hardcoded string a second time or fixing the underlying gap once.

**Why:** `docs/ai/project-rules.md`'s "Cross-Feature Consistency" section is explicit: *"If a safe improvement benefits previously completed features, apply it consistently across all affected features. Do not leave similar implementations inconsistent."* Two independent hardcoded copies of the same derived value is exactly the drift risk that has already caused real bugs earlier in this project (see the Handicap Consistency fix applied across Dashboard, Rounds, Trips, Friends and Groups before Profile existed).

**How to apply:** `profile.dart` gains a `profileVisibilityLabel(ProfileVisibility)` function. Profile's `_DetailsCard` was updated to call it instead of its old hardcoded string, and Settings calls the same function — this is the only change to already-shipped Profile code this feature makes.

---

## Notification Categories Are Read From Notifications, Not Redeclared

Settings' Notification Preferences section lists the same four categories `NotificationCategory` already defines.

**Why:** the same "Categories Exist So Settings Can Reference Them Without a Second List" decision already documented in `notifications-engineering-decisions.md` — defining the enum once, in the feature that owns it, and having Settings reuse it removes any risk of the two lists disagreeing.

**How to apply:** `settings_screen.dart` imports `NotificationCategory` from `package:qaddy/features/notifications/models/notification_item.dart` and iterates `NotificationCategory.values` directly.

---

## Settings Is Reached From Profile, Not the Bottom Navigation

`docs/architecture/navigation.md`'s Profile section already named Settings as a future Profile expansion, and its "Bottom Navigation" Engineering Decision says to extend existing tabs rather than add new ones.

**Why:** this decision was already made, in `navigation.md`, before this feature began — there is nothing to decide here, only to implement.

**How to apply:** route `/profile/settings`, nested under the existing Profile branch, opened via a third quick link on the Profile screen, alongside Statistics and Golf Bag.

---

# Source of Truth

Settings should never duplicate values already owned by another feature.

Whenever possible, Settings derives information from:

- Profile
- Notifications

No data in this feature is new — everything is read from an existing source.

---

# Related Documents

- settings-data-model.md
- docs/features/settings-feature-integration.md
- settings-future-roadmap.md
- profile-engineering-decisions.md
- notifications-engineering-decisions.md

---

**End of Document**
