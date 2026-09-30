# Golf Bag Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Golf Bag feature.

Per-document Engineering Decisions sections still apply where they exist (`golf-bag-data-model.md`); this document exists for decisions that span the whole feature rather than belonging to one model.

---

## Feature Folder Is `my_bag`, Not `golf_bag`

`docs/technical-architecture.md`'s own Features folder-structure example explicitly lists this feature's folder as `my_bag/`. The public feature name, per `docs/roadmap/release-1-roadmap.md`, is "Golf Bag."

**Why:** the folder name was already decided before this feature's implementation began, in a document unrelated to this one. Inventing a different folder name (`golf_bag/`) would contradict an existing architecture decision for no reason — the same situation Friends already established with its `community/` folder.

**How to apply:** `lib/features/my_bag/` holds every Golf Bag file. Routes, screen titles and documentation all say "Golf Bag"; only the folder says `my_bag`.

---

## Golf Bag Reuses Profile's Equipment List

Profile's "Equipment" section (Driver/Irons/Wedges/Putter/Ball, with brand and model) already exists and is exactly what `product-specification.md`'s "My Bag" section calls "Equipment notes." Golf Bag reads `profileEquipment` directly rather than restating the same five items as new literals.

**Why:** the same "Single Source of Truth" discipline already applied by Statistics — this is now the third feature in a row (after Profile and Statistics) to compute from an existing feature's placeholder data instead of duplicating it.

**How to apply:** `lib/features/my_bag/models/placeholder_my_bag.dart` imports `package:qaddy/features/profile/models/placeholder_profile.dart` for the Equipment list. It does not redeclare club names or brands.

---

## Distances Apply Only Where Golfing Convention Supports Them

Club Distances covers Driver, Irons and Wedges only. Putter is excluded because a putter's performance isn't measured in carry distance; Ball is excluded because it isn't a club.

**Why:** avoids inventing a nonsensical "putter distance" or "ball distance" figure just to give every Equipment row a matching value. Golfing domain accuracy matters more than section symmetry.

**How to apply:** `ClubDistance` entries exist for exactly three clubs — see `placeholder-golf-bag-data.md`'s "New Placeholder Data."

---

## Bag Analytics Is a Derived Summary, Not a New Dataset

The Sprint 7 goal names "bag analytics." Release 1 satisfies this with two computed values — Total Clubs (a count of Equipment) and Longest Average Distance (the maximum of the three Club Distances) — rather than a new, independently-tracked analytics dataset.

**Why:** this is the same shape of decision Statistics already made for "Trends": introduce the smallest amount of new data genuinely required (three distance figures), then derive everything analytical from it, rather than inventing a second dataset on top.

**How to apply:** Bag Summary's two figures are computed getters in `placeholder_my_bag.dart`, not stored constants.

---

## Golf Bag Is Reached From Profile, Not the Bottom Navigation

`docs/architecture/navigation.md`'s own "Bottom Navigation" Engineering Decision states: *"Five tabs represent the highest-frequency user journeys. Future features should extend existing tabs rather than creating additional bottom navigation destinations."* Golf Bag is equipment/identity-related, and Profile already owns the Equipment section it builds on.

**Why:** matches the same reasoning already applied to Statistics — extend Profile rather than add a sixth tab.

**How to apply:** route `/profile/bag`, nested under the existing Profile branch, opened via a second "View Golf Bag" quick link alongside Statistics' own link on the Profile screen.

---

# Source of Truth

Golf Bag should never duplicate values already owned by another feature.

Whenever possible, Golf Bag derives information from:

- Profile

Only data that cannot be calculated or reused elsewhere — Club Distances — may define its own placeholder data.

---

# Related Documents

- golf-bag-data-model.md
- docs/features/golf-bag-feature-integration.md
- golf-bag-future-roadmap.md
- profile-engineering-decisions.md
- statistics-engineering-decisions.md

---

**End of Document**
