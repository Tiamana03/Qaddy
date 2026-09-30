# Golf Bag Feature Integration

## Overview

This document defines how the complete Golf Bag feature is integrated within Qaddy.

Golf Bag manages the golfer's equipment — clubs, brands and average distances — per `docs/product-specification.md`'s "My Bag" section.

This document does **not** define new functionality.

Instead, it explains how Golf Bag's sections combine into one seamless screen and how it reuses data already established by Profile.

---

# Goals

The Golf Bag feature should allow users to:

- View the clubs in their bag and their brand/model
- View average carry distance for clubs where that concept applies
- View a quick bag summary (total clubs, longest average distance)
- Return to Profile

The experience should feel like "Profile's Equipment section, in more depth" rather than a disconnected screen.

---

# Scope

This feature includes:

- Golf Bag (single screen)
- Placeholder data
- Feature integration

This feature does **not** include:

- AI club recommendations
- A full, realistic multi-club bag beyond the existing 5-item Equipment list
- Editing, adding or removing clubs
- GPS or shot-tracked real distances
- Per-shot club selection history

All data remains placeholder driven. See `docs/architecture/golf-bag-future-roadmap.md` for how these are expected to arrive later.

---

# Feature Flow

The complete Golf Bag journey should follow the workflow below.

Dashboard

↓

Profile

↓

Golf Bag

↓

Profile

Golf Bag is a single destination reached from Profile — every section below renders on the same screen, matching the "Release 1 Is One Aggregated Screen" pattern already used for Profile and Statistics.

---

# Integration Objectives

Golf Bag should never restate a figure that already has a canonical source in Profile.

Every club name and brand shown must match Profile's existing Equipment section exactly — never a new, independent list for the same concept.

---

# Navigation Flow

## Profile

Displays a "View Golf Bag" quick link, alongside the existing "View Statistics" link.

Selecting it opens Golf Bag.

---

## Golf Bag

Displays, in order:

- Bag Summary — Total Clubs, Longest Average Distance
- Equipment — Driver, Irons, Wedges, Putter, Ball, with brand and model
- Club Distances — average carry distance for Driver, Irons and Wedges

No section links to another screen — Release 1 has nothing further to open (see Scope).

---

# Route Integration

Golf Bag is nested under the existing Profile route, per `navigation.md`.

| Route | Screen |
|---------|---------|
| /profile/bag | Golf Bag |

No new top-level route or bottom-navigation destination is introduced.

---

# Shared Placeholder Data

Golf Bag displays the same shared placeholder user, **Tiamana**, already used throughout Rounds, Trips, Friends, Groups, Profile and Statistics.

The following information must never be duplicated as new literals — it is read from Profile's existing placeholder data instead:

- Equipment — club category, brand and model (`placeholder_profile.dart`'s `profileEquipment`)

The only new placeholder values this feature introduces are the three Club Distance figures — see `placeholder-golf-bag-data.md`'s "New Placeholder Data" section. Total Clubs and Longest Average Distance are computed, not new data.

Future backend integration will replace this placeholder data.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- QaddyCard
- QaddySectionCard
- QaddyStatisticCard — for Bag Summary
- QaddyInfoRow — for Equipment and Club Distances rows, exactly as Statistics already uses it

Create new widgets only when functionality does not already exist.

---

# Model Reuse

Reuse existing models and placeholder data wherever possible. Golf Bag must not redefine or restate Profile's Equipment data.

Reuse:

- `ProfileEquipmentItem`, `profileEquipment` (`placeholder_profile.dart`)

New model introduced by this feature only:

- `ClubDistance` (`golf-bag-data-model.md`)

Avoid creating duplicate placeholder models.

---

# Button Behaviour

| Button | Action |
|---------|---------|
| View Golf Bag (on Profile) | Open Golf Bag |
| Back | Return to Profile |

No other interactive buttons exist in Release 1 — every Golf Bag section is read-only display data (see Scope, "Editing, adding or removing clubs").

---

# Placeholder State

All Golf Bag information remains in memory.

No backend persistence exists during this feature's implementation.

Closing the application resets placeholder data.

Persistent storage will be implemented in a future release.

---

# Acceptance Criteria

The Golf Bag feature is complete when a user can:

- Open Golf Bag from Profile
- View their equipment (clubs, brands and models)
- View average club distances where applicable
- View the bag summary
- Return to Profile

Additionally:

- No duplicate placeholder data exists — Equipment is read from Profile, not restated
- Existing widgets are reused wherever possible, including `QaddyInfoRow`
- Navigation has no dead ends
- All tests pass
- The feature behaves as a natural extension of Profile

---

# Future Integration

Future releases will replace placeholder functionality with:

- Supabase
- AI club recommendations
- A full, realistic multi-club bag
- Editing, adding and removing clubs
- GPS and shot-tracked distances
- Per-shot club selection history

See `docs/architecture/golf-bag-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Golf Bag functionality into one complete feature.
