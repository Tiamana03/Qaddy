# Search Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Search feature.

Per-document Engineering Decisions sections still apply where they exist (`search-data-model.md`); this document exists for decisions that span the whole feature rather than belonging to one model.

---

## Search Is Reached From Dashboard, Not the Bottom Navigation

`docs/architecture/navigation.md`'s own "Bottom Navigation" Engineering Decision states: *"Five tabs represent the highest-frequency user journeys. Future features should extend existing tabs rather than creating additional bottom navigation destinations."* Architecture Review #2 (Section 3) confirmed this has held across four features in a row (Statistics, Golf Bag, Settings, Notifications) and should keep holding. Search is inherently cross-feature, which makes it a natural fit for Dashboard — already documented as "the application's primary landing screen and navigation hub" (Sprint 2 goal) — rather than any one existing tab.

**Why:** the same reasoning already applied to Notifications: extend Dashboard's app bar rather than add a sixth tab or grow Profile's already-flagged-as-crowded Quick Actions card (Architecture Review #2, Section 4 — "before adding a 4th or 5th Quick Actions entry, make a deliberate decision"). Search is not an identity-related concern, so it does not belong on Profile at all.

**How to apply:** route `/home/search`, nested under the existing Home branch exactly like `/home/notifications`. A search icon is added to Dashboard's app bar `actions`, to the left of the existing notification bell.

---

## Rounds Gets a Minimal Public Constant So Search Can Read It

Rounds' single upcoming round (course, date, tee time, players, weather, format, holes) existed only as private literals, duplicated across two of `rounds_screen.dart`'s own widgets. No other feature has ever needed to read Rounds' data before, so this gap was never exposed — it is the same class of gap already logged as TD-005 for Dashboard's round-summary statistics.

Search genuinely cannot implement its "rounds" category (explicitly named in Sprint 11's goal) without either duplicating this literal as a second hardcoded copy, or reading a real public source. Duplicating it would be a direct Single-Source-of-Truth violation for the one piece of data Search is actually supposed to search.

**Why:** unlike TD-005 (where Profile mirrors Dashboard's literals by documented convention because nothing forces an exact-match comparison), Search performs live substring matching against this value — a drifted duplicate would silently break search results, not just look slightly inconsistent in two places. The fix is small and mechanical: extract, don't rewrite.

**How to apply:** `lib/features/rounds/models/placeholder_rounds.dart` (new) defines `UpcomingRound` and the `upcomingRound` constant with the exact literals `rounds_screen.dart` already displayed. `rounds_screen.dart`'s `_UpcomingRoundCard` and `_RoundInformationCard` are updated to read from it, which also removes their own pre-existing internal duplication of `'Richmond Golf Club'` and `'8:20 AM'` as a side effect. No value changes; this is a within-scope fix per this task's instruction to "fix architecture improvements discovered during implementation if they are within scope," not a deferred technical-debt item.

---

## Courses Reads Profile's Favourite Courses and the Current Trip's Golf Schedule — Nothing Else

Release 1 has no dedicated Courses feature or model. "Courses" in Sprint 11's goal is satisfied by reading two lists that already exist for an unrelated reason: `profileFavouriteCourses` (Profile's own "Favourite Courses" section, 5 entries) and `melbourneGolfWeekendCourses` (the current trip's golf schedule, 3 entries).

Two other candidate sources were considered and rejected:

- **Each Friend's individual `favouriteCourse` field** (all 8 friends have one). Rejected: Release 1 only has one "detailed" friend (Tom), so 7 of the 8 resulting Course rows would have nowhere to navigate — `onTap: null` on 7 out of 8 results contradicts the spirit of a useful Courses list far more than it would add value, and risks looking like a bug rather than a documented limitation.
- **Rounds' and Groups' course fields** (`upcomingRound.course` and `saturdayBoys.homeCourse` are both `'Richmond Golf Club'` — the same literal, read from two different places). Rejected: showing the identical course name as two or three separate, non-deduplicated Courses rows would look like a defect, not a feature of "reading from multiple sources." Deduplicating them would require inventing a merge rule Search has no documented need for. Simplest correct option: don't source Courses from Rounds or Groups at all — Rounds and Groups still appear in the Rounds and Groups categories respectively, where their course is shown as supporting detail, not as a separate indexed entity.

**Why:** both rejected sources would have added rows to the Courses category that are either dead-ended (no tap target) or redundant (duplicate names with ambiguous destinations) — a strictly worse result than a smaller, fully-functional category.

**How to apply:** `search_screen.dart` builds Courses results only from `profileFavouriteCourses` (→ `AppRoutes.profile`) and `melbourneGolfWeekendCourses` (→ `AppRoutes.tripGolf`). Every Courses result is tappable, because both sources are always reachable.

---

## Non-Detailed Results Are Shown but Not Tappable, Matching Existing List Screens

Friends, Groups and Trips each have exactly one item with a real detail screen; every other item is summary-only, already handled on their own list screens by setting `onTap: null` for every row except the one matching `tom.id` / `saturdayBoys.id` / `melbourneGolfWeekend.id`.

**Why:** Search surfaces the same underlying lists those screens already render. Inventing a different rule for Search — e.g. hiding non-detailed results entirely, or fabricating a destination for them — would contradict those screens' own documented behaviour and this project's "never invent navigation" rule.

**How to apply:** `SearchResult.onTap` is built using the exact same `item.id == <canonical>.id` check each list screen already performs (see `search-data-model.md`'s "Model Reuse" table), not a new comparison.

---

# Source of Truth

Search should never duplicate values already owned by another feature.

Whenever possible, Search derives information from:

- Friends
- Groups
- Trips
- Rounds
- Profile

No category introduces new placeholder *values* — only one new public constant (`upcomingRound`) that re-exposes an existing literal so it can be read instead of duplicated.

---

# Related Documents

- search-data-model.md
- docs/features/search-feature-integration.md
- search-future-roadmap.md
- navigation.md
- docs/architecture/data-ownership.md
- docs/reviews/technical-debt.md (TD-005, the related Dashboard gap)

---

**End of Document**
