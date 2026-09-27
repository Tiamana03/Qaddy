# Profile Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Profile feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

---

## Statistics Screen

A dedicated Statistics destination, per `docs/architecture/navigation.md`'s Profile "Future Expansion" ("Future releases will expand Profile into: Statistics").

Depends on a `statistics-data-model.md` architecture document, which does not yet exist — Release 1's Profile screen displays placeholder statistics directly rather than through a formal Statistics feature.

---

## Achievements Screen

A dedicated Achievements destination, per `navigation.md`'s Profile "Future Expansion".

This is where `profile-achievements.md`'s full Achievement model (category, rarity, progress, target, points, hidden) is intended to be implemented — see `docs/architecture/profile-engineering-decisions.md`'s "Achievements Use a Simplified Preview" for why Release 1 only shows a lightweight preview on the Profile screen itself.

---

## Settings Screen

A dedicated Settings destination, per `navigation.md`'s Profile "Future Expansion".

Would own Profile Visibility changes, notification preferences, and account management — none of which are editable in Release 1 (Profile is read-only placeholder data).

---

## Premium Screen

A dedicated Premium destination, per `navigation.md`'s Profile "Future Expansion".

Depends on a billing/subscription system that does not exist yet.

---

## Editing Profile Information

Editing name, handicap, home course, favourite course, location, bio or avatar.

Depends on a backend — Release 1's Profile screen is entirely read-only placeholder data, consistent with every other Release 1 feature.

---

## Player Levels, Experience Points and AI Golf Coach

See `profile-data-model.md`'s "Future Expansion" section for the full list (Player Levels, Experience Points, AI Golf Coach, Golf Goals, Equipment Tracking, Swing Analysis, Social Feed, Verified Golf Clubs, Custom Themes, Digital Golf Passport, Public Player Cards).

---

## Achievement Collections and Events

See `profile-achievements.md`'s "Future Expansion" section for the full list (Achievement Collections, Monthly Challenges, Limited-Time Events, Seasonal Achievements, Club Achievements, Regional Achievements, AI Challenges, Community Events, Trophy Cabinet, Achievement Sharing).

---

## Extended Placeholder Data

See `placeholder-profile-data.md`'s "Future Placeholder Data" section (Swing Speed, Ball Speed, Club Distances, AI Golf IQ, Equipment History, Golf Goals, Practice Sessions, Fitness Statistics, Walking Distance, Calories Burned, Social Rankings, Club Fittings, Coaching Sessions, Preferred Playing Times, Favourite Golf Brands).

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `profile-data-model.md` and `profile-achievements.md` — a Purpose section, a data model table, business rules, and a Do Not Build section for whatever remains out of scope at that time.

---

# Related Documents

- profile-data-model.md
- profile-achievements.md
- docs/features/profile-feature-integration.md
- profile-engineering-decisions.md

---

**End of Document**
