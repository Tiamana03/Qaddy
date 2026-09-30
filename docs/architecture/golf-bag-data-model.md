# Golf Bag Data Model

**Version:** 1.0

**Status:** Architecture Approved

---

# Purpose

This document defines the Golf Bag feature's data model.

Per `docs/product-specification.md`'s "My Bag" section, Golf Bag manages the golfer's equipment: clubs, distances, equipment notes, wedges, driver settings and favourite balls. Future versions add AI club recommendations.

No implementation may introduce additional Golf Bag fields without updating this document.

---

# Overview

Golf Bag displays:

- Equipment — the golfer's clubs by category and brand
- Club Distances — average carry distance for the clubs where that concept applies
- Bag Summary — a small derived summary of the bag (total clubs, longest average distance)

Golf Bag does not own equipment brand/model data — that already exists on Profile (see "Model Reuse" below). It introduces only club distances, which exist nowhere else in the application.

---

# Club Distance Model

The one new model this feature introduces.

| Field | Type | Description |
|--------|------|-------------|
| clubName | String | The club category, matching an existing Equipment entry (e.g. "Driver") |
| averageDistanceMetres | double | Average carry distance for this club |

Derived, not stored:

- **formattedDistance** — `averageDistanceMetres` rendered via the existing `formatDistance()` utility (e.g. "235m"), not a new formatting rule.

---

# Model Reuse

Golf Bag must not redefine or restate any of the following. It reads them directly.

| Source | Reused for |
|---------|-----------|
| `placeholder-profile-data.md` / `placeholder_profile.dart` (`ProfileEquipmentItem`, `profileEquipment`) | The Equipment section — club category and brand/model, unchanged |

---

# Business Rules

- Club Distances apply only to clubs where a carry distance is a meaningful golfing concept: Driver, Irons and Wedges. Putter and Ball are deliberately excluded — a putter is not measured by carry distance, and a ball is not a club at all.
- Club Distances are averages, not personal bests. They are a distinct concept from `profile-data-model.md`'s Personal Records "Longest Drive" (312m), which records one exceptional shot rather than a typical distance — the two must never be conflated or shown as contradicting each other.
- Bag Summary figures (total clubs, longest average distance) are always derived from Equipment and Club Distances at display time, never stored as separate literals.

---

# Out of Scope (Release 1)

- A full, realistic multi-club bag (14 clubs) — Release 1 reuses Profile's existing 5-item Equipment list.
- AI club recommendations — explicitly named as "Future" in `product-specification.md`'s "My Bag" section.
- Editing, adding or removing clubs from the bag.
- GPS-based or shot-tracked real distance measurement.
- Per-shot club selection history.

See `golf-bag-future-roadmap.md`.

---

# Engineering Decisions

See `docs/architecture/golf-bag-engineering-decisions.md` for the full reasoning, including why the feature folder is `my_bag`, not `golf_bag`.

---

# Flutter Implementation Notes

Golf Bag functionality should remain inside:

```
lib/features/my_bag/
```

Per `docs/technical-architecture.md`'s own Features folder-structure example, which names this feature's folder `my_bag/` — the public feature name ("Golf Bag", per `docs/roadmap/release-1-roadmap.md`) and the folder name are allowed to differ, exactly as Friends already differs from its `community/` folder.

The only new model type is `ClubDistance`. Equipment is read from Profile's existing model rather than duplicated.

---

# Related Documents

- profile-data-model.md
- docs/features/golf-bag-feature-integration.md
- golf-bag-engineering-decisions.md
- golf-bag-future-roadmap.md
- technical-architecture.md
- product-specification.md

---

**End of Document**
