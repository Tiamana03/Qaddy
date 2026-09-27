# Groups (Screen)

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the Groups screen within the Friends feature.

Groups displays every group the current user belongs to.

This document does not redefine the Group model — see `group-data-model.md` for every field, `group-permissions.md` for membership permissions, and `group-season-model.md` for season behaviour. It only defines how groups are listed on screen.

---

# Screen Contents

Each group card displays:

- Group name
- Member count
- Current season
- Status badge

Selecting a group opens Group Details.

---

# Status Badge

Reuse `QaddyStatusBadge`.

Group status values are defined in `group-data-model.md`'s Group Status section (Active, Archived, Hidden, Deleted). Release 1 only displays Active groups.

---

# Placeholder Data

Group list data is defined in `docs/standards/placeholder-group-data.md`'s "Groups" table.

---

# Do Not Build

Do not build:

- Creating a group
- Editing a group
- Leaving a group
- Group chat
- Group photos

These belong to future releases — see `friends-future-roadmap.md`.

---

# Related Documents

- group-data-model.md
- group-permissions.md
- group-season-model.md
- docs/standards/placeholder-group-data.md
- group-details.md
- docs/features/friends-feature-integration.md

---

**End of Document**
