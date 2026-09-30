# Placeholder Golf Bag Data

**Version:** 1.0

**Status:** Approved Placeholder Data

---

# Purpose

This document defines the official placeholder data for the Golf Bag feature.

Almost none of it is new. Per `docs/architecture/golf-bag-data-model.md`, Golf Bag reuses the Equipment list already established by Profile. This document states exactly which value comes from where, and separately calls out the only new values (see "New Placeholder Data" below).

No AI or developer may invent additional Golf Bag values without updating this document.

---

# Equipment

Reused in full from `placeholder-profile-data.md`'s "Equipment" section.

| Club | Value | Source |
|------|-------|--------|
| Driver | TaylorMade Qi35 | `profileEquipment` |
| Irons | TaylorMade P790 | `profileEquipment` |
| Wedges | Cleveland RTX | `profileEquipment` |
| Putter | Odyssey White Hot | `profileEquipment` |
| Ball | Titleist Pro V1 | `profileEquipment` |

---

# New Placeholder Data

The only values this feature introduces that do not already exist anywhere else — average carry distances for the three clubs where that concept applies (see `golf-bag-data-model.md`'s Business Rules for why Putter and Ball are excluded).

| Club | Average Distance |
|------|------------------:|
| Driver | 235m |
| Irons | 145m |
| Wedges | 95m |

These are averages, not personal bests — they are deliberately lower than `placeholder-profile-data.md`'s Personal Bests "Longest Drive" (312m), which is one exceptional shot, not a typical one.

---

# Bag Summary

Derived at display time — not new placeholder data.

| Statistic | Value | Derived From |
|-----------|------:|---------------|
| Total Clubs | 5 | `profileEquipment.length` |
| Longest Average Distance | Driver — 235m | The highest value among the three Club Distances above |

---

# Engineering Notes

This document contains placeholder Golf Bag information only.

Business rules belong in:

- golf-bag-data-model.md
- golf-bag-engineering-decisions.md

Implementation belongs in `docs/features/golf-bag-feature-integration.md`.

---

# Related Documents

- golf-bag-data-model.md
- golf-bag-engineering-decisions.md
- golf-bag-future-roadmap.md
- docs/features/golf-bag-feature-integration.md
- placeholder-profile-data.md

---

**End of Document**
