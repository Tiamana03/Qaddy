# Profile Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Profile feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

The Statistics and Settings destinations named in `navigation.md`'s Profile "Future Expansion" are no longer future work — both are implemented as their own features. See `docs/features/statistics-feature-integration.md` and `docs/features/settings-feature-integration.md`, plus each feature's own data model, engineering decisions and future roadmap documents.

---

## Achievements Screen

A dedicated Achievements destination, per `navigation.md`'s Profile "Future Expansion".

This is where `profile-achievements.md`'s full Achievement model (category, rarity, progress, target, points, hidden) is intended to be implemented — see `docs/architecture/profile-engineering-decisions.md`'s "Achievements Use a Simplified Preview" for why Release 1 only shows a lightweight preview on the Profile screen itself.

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
- docs/features/statistics-feature-integration.md
- statistics-data-model.md
- docs/features/settings-feature-integration.md
- settings-data-model.md

---

**End of Document**
