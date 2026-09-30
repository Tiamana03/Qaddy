# Golf Bag Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Golf Bag feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

---

## AI Club Recommendations

Suggesting which club to use based on distance to target, conditions and past performance.

Explicitly named as "Future" in `product-specification.md`'s "My Bag" section. Part of Qaddy's longer-term Golf IQ / AI direction.

---

## A Full, Realistic Bag

Expanding beyond the current 5-item Equipment list (Driver, Irons, Wedges, Putter, Ball) to a complete, individually-tracked bag (e.g. 3-Wood, Hybrid, individual iron numbers, multiple wedges by loft).

Depends on richer placeholder data than currently exists anywhere in the application.

---

## Editing the Bag

Adding, removing or reordering clubs; editing brand, model or loft.

Depends on a backend — Release 1's Golf Bag is entirely read-only placeholder data, consistent with every other Release 1 feature.

---

## GPS and Shot-Tracked Distances

Measuring real carry and total distance per shot via GPS or a connected device, replacing the placeholder averages with genuine, personal data over time.

---

## Per-Shot Club Selection History

A log of which club was used for each shot across completed rounds, feeding more accurate average distances than a fixed placeholder figure.

Depends on Rounds maintaining shot-level history, which Release 1 does not — see `round-data-model.md`'s HoleScore model, which records a hole's outcome but not per-shot club selection.

---

## Club Fittings and Equipment History

See `placeholder-profile-data.md`'s "Future Placeholder Data" section (Club Fittings, Equipment History) — these were already identified as future Profile extensions and belong equally to Golf Bag once it exists as its own feature.

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `golf-bag-data-model.md` — a Purpose section, a data model table, business rules, and a Do Not Build / Out of Scope section for whatever remains deferred at that time.

---

# Related Documents

- golf-bag-data-model.md
- golf-bag-engineering-decisions.md
- docs/features/golf-bag-feature-integration.md

---

**End of Document**
