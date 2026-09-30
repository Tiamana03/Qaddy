# Settings Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Settings feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

---

## Editable Profile Visibility

Actually changing who can see the user's profile, persisted to a backend.

Depends on Supabase and Authentication.

---

## A Light Theme and Theme Toggle

Introducing a second theme and letting the user switch between them.

Depends on a light theme actually being designed — `docs/qaddy-design-bible.md` currently defines dark-theme tokens only.

---

## Editable Notification Preferences

Turning individual notification categories on or off, with the change actually affecting which notifications arrive. See `notifications-future-roadmap.md`'s "User-Configurable Notification Preferences."

---

## Account Management

Sign-out, password change, account deletion.

Depends on Authentication existing.

---

## Language and Region

Localisation and regional formatting preferences.

---

## Data and Privacy Controls

Exporting or deleting personal data, consistent with future privacy regulations compliance.

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `settings-data-model.md` — a Purpose section, a data model table (once one is needed), business rules, and a Do Not Build / Out of Scope section for whatever remains deferred at that time.

---

# Related Documents

- settings-data-model.md
- settings-engineering-decisions.md
- docs/features/settings-feature-integration.md

---

**End of Document**
