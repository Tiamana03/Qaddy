# Placeholder Settings Data

**Version:** 1.0

**Status:** Approved Placeholder Data

---

# Purpose

This document defines the official placeholder data for the Settings feature.

Almost none of it is new — per `docs/architecture/settings-data-model.md`, Settings reuses Profile and Notifications data directly. The only genuinely new value is the application version string, which is sourced from `pubspec.yaml` rather than invented.

No AI or developer may invent additional Settings values without updating this document.

---

# Privacy

Reused from `placeholder-profile-data.md`'s "Player Profile" section.

| Field | Value | Source |
|-------|-------|--------|
| Profile Visibility | Friends Only | `profile.profileVisibility` |

---

# Notification Preferences

Reused from `placeholder-notifications-data.md`'s categories — every category is shown as enabled (see `settings-data-model.md`'s Business Rules).

| Category | Label | Status |
|----------|-------|--------|
| roundReminder | Round Reminders | Enabled |
| friendActivity | Friend Activity | Enabled |
| tripUpdate | Trip Updates | Enabled |
| systemUpdate | System Updates | Enabled |

---

# Appearance

| Field | Value |
|-------|-------|
| Theme | Dark |

Dark is the only theme that exists in the codebase (`QaddyTheme.dark`) — there is nothing to choose between yet.

---

# Application

Sourced from `pubspec.yaml`, not invented.

| Field | Value |
|-------|-------|
| App Version | 0.1.0 |

---

# Engineering Notes

This document contains placeholder Settings information only.

Business rules belong in:

- settings-data-model.md
- settings-engineering-decisions.md

Implementation belongs in `docs/features/settings-feature-integration.md`.

---

# Related Documents

- settings-data-model.md
- settings-engineering-decisions.md
- settings-future-roadmap.md
- docs/features/settings-feature-integration.md
- placeholder-profile-data.md
- placeholder-notifications-data.md

---

**End of Document**
