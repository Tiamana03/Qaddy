# Placeholder Notifications Data

**Version:** 1.0

**Status:** Approved Placeholder Data

---

# Purpose

This document defines the official placeholder data for the Notifications feature.

The four notification messages already exist in `placeholder-data.md`'s "Notifications" section, written before Notifications existed as its own feature. This document reuses them verbatim and adds only the classification each one needs to become a `NotificationItem` (see `docs/architecture/notifications-data-model.md`).

No AI or developer may invent additional notification messages without updating `placeholder-data.md` first.

---

# Notifications

Reused verbatim from `placeholder-data.md`'s "Notifications" section, in the same order, each classified into one of the four documented categories.

| Message | Category | Source |
|---------|----------|--------|
| Your round starts in 2 days. | roundReminder | `placeholder-data.md` |
| Josh accepted your invitation. | friendActivity | `placeholder-data.md` |
| Trip payment due this Friday. | tripUpdate | `placeholder-data.md` |
| New version of Qaddy available. | systemUpdate | `placeholder-data.md` |

---

# Notification Summary

Derived at display time — not new placeholder data.

| Statistic | Value | Derived From |
|-----------|------:|---------------|
| Total Notifications | 4 | The list above |

---

# Engineering Notes

This document contains placeholder Notifications information only.

Business rules belong in:

- notifications-data-model.md
- notifications-engineering-decisions.md

Implementation belongs in `docs/features/notifications-feature-integration.md`.

---

# Related Documents

- notifications-data-model.md
- notifications-engineering-decisions.md
- notifications-future-roadmap.md
- docs/features/notifications-feature-integration.md
- placeholder-data.md
- placeholder-settings-data.md

---

**End of Document**
