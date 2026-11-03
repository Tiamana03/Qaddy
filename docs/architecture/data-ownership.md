# Data Ownership

Status: Canonical
Last Updated: 2026-10-01

---

# Purpose

This document is the single canonical reference for **which feature owns which data**, and **which features are allowed to read it**.

Every engineering-decisions document written since Profile (Profile, Statistics, Golf Bag, Notifications, Settings) has independently restated the same "Single Source of Truth" principle in its own words. That restatement stops here. From this point forward:

- A feature's own `*-engineering-decisions.md` should **link to this document** instead of re-explaining the principle.
- This document is updated whenever a new feature introduces, reuses, or exposes ownership-relevant data — not the other feature's own doc in isolation.
- If a feature's doc and this document ever disagree about who owns a value, this document wins (see `docs/ai/architecture-principles.md`'s Documentation Precedence section).

---

# The Principle

A feature **owns** a value if it is the first feature to define it as placeholder data or application state.

Every other feature that needs the same value must **read it directly** — importing the owning feature's public constant, model, or a computed getter derived from it — never by **restating** the literal as a new constant of its own.

This has been applied correctly in every Release 1 feature built so far (confirmed in Architecture Review #2, Section 8/9: no actual data duplication exists across any of the 9 implemented features). The purpose of this document is to keep that record intact as more features are added, by giving every future feature one place to check before adding a tenth near-identical "Source of Truth" section.

**Two narrow exceptions exist**, and only these:

1. **Genuinely new data a feature introduces because no other feature could supply it** — e.g. Statistics' two Trend deltas (Handicap, Average Score — "previous value" over a named period), Golf Bag's three Club Distances (Driver, Irons, Wedges). These are documented in each feature's own `placeholder-*-data.md` "New Placeholder Data" section and are not duplicates of anything, because nothing else owns them.
2. ~~**Dashboard's round-summary literals** had no public constant to import.~~ **Resolved during Polish & Launch (TD-005).** `lib/features/dashboard/models/placeholder_dashboard.dart` now publicly exposes `dashboardRoundsPlayed`, `dashboardAverageScore` and `dashboardBestRound`; Profile's `profileRoundsPlayed`/`profileAverageScore`/`profileBestRound` are computed from them directly, not duplicated. Dashboard never displays Fairways Hit or Greens in Regulation at all, so those two remain Profile-only literals — there was never a Dashboard value for them to drift from.

---

# Ownership Table

| Feature (folder) | Owns | Public source | Known readers |
|---|---|---|---|
| Dashboard (`dashboard`) | Round-summary values (Rounds Played, Average Score, Best Round) | `lib/features/dashboard/models/placeholder_dashboard.dart` | Profile (`profileRoundsPlayed`/`profileAverageScore`/`profileBestRound`) |
| Rounds (`rounds`) | Current/upcoming round data (`UpcomingRound`), round leaderboard, `PositionBadge` widget | `lib/features/rounds/models/placeholder_rounds.dart`, `lib/features/rounds/ui/widgets/position_badge.dart` | Groups (`GroupLeaderboardRow` reuses `PositionBadge`), Search (Rounds category) |
| Trips (`trips`) | Every trip and its plan (players, courses, flights, accommodation, transport, activities, expenses, checklist, packing, weather, chat, notes). Seeds live in `placeholder_trips.dart`; the *live* trips (created, edited, archived, deleted) live in the `tripsProvider` store, the single source of truth for the app run. | `lib/features/trips/models/placeholder_trips.dart` (seeds, `currentUserName`, count constants), `lib/features/trips/state/trips_controller.dart` (live store) | Profile (Trips count, still the seed constants — see TD-011), Search (Trips and Courses categories, read from the live store) |
| Community (`community`) | Friends list, friend profiles, Rivalry Performance; the live friends store (requests, accepted friends, cheers) | `lib/features/community/models/placeholder_friends.dart` (seeds), `lib/features/community/state/friends_controller.dart` (live store) | Profile (Friends count), Statistics (Rivalry Performance), Search (Friends category) |
| Groups (`groups`) | Group data, Season Summary, full leaderboard, season standing | `lib/features/groups/models/placeholder_groups.dart` | Profile (Groups count, season standing), Statistics (Season Performance, full leaderboard), Search (Groups category) |
| Profile (`profile`) | Who the golfer is: name, handicap index, home course and location, favourite courses and the equipment list. Everything about their game is derived from rounds, not stored here | `lib/features/profile/models/placeholder_profile.dart` | Statistics and Dashboard (handicap index), Golf Bag (Equipment), Search (Courses category), Trips (organiser identity) |
| Statistics (`statistics`) | Nothing of its own: it is derived from the finished rounds in the rounds store (`logic/career_stats.dart`) and reads the handicap index from Profile | — (no placeholder file) | Dashboard ("Your game") |
| Golf Bag (`my_bag`) | Club Distances only (Driver, Irons, Wedges — see Exception 1) | `lib/features/my_bag/models/placeholder_my_bag.dart` | None yet |
| Notifications (`notifications`) | `NotificationItem` entries, `NotificationCategory` classification | `lib/features/notifications/models/placeholder_notifications.dart` | Settings (`NotificationCategory`) |
| Settings (`settings`) | User-facing preference toggles (no new data of its own — reads Profile and Notifications) | — (consumer only) | — |
| Search (`search`) | `SearchResult`/`SearchCategory` (presentation-only; no placeholder data of its own) | — (consumer only) | — |
| Authentication (`authentication`) | `OnboardingPage` entries (new onboarding copy; no user/account data) | `lib/features/authentication/models/onboarding_page.dart` | — (no other feature reads from or is read by Authentication) |

Note on folder naming: the Golf Bag feature's folder is `my_bag`, not `golf_bag` — see `technical-architecture.md`'s Features folder-structure example. Do not create a `golf_bag/` folder; the empty scaffold that once existed there was removed (TD-002).

---

# Cross-Feature Dependency Graph

Read each line as **Owner → reused by Dependent**:

```
Rounds        → Groups          (PositionBadge widget)
Community     → Profile         (Friends count)
Groups        → Profile         (Groups count, season standing)
Trips         → Profile         (Trips count)
Rounds        → Statistics      (every finished round: the story is worked out from them)
Rounds        → Achievements    (earned from the finished rounds; shown on Profile and the results screen)
Achievements  → Statistics      (CareerStats is what achievements are measured on)
Statistics    → Profile         (handicap index only)
Profile       → Golf Bag        (Equipment)
Profile       → Settings        (Profile Visibility)
Notifications → Settings        (NotificationCategory)
Dashboard     → Profile         (Rounds Played, Average Score, Best Round)
Dashboard     → Rounds, Statistics, Trips, Friends   (next round, your game from real rounds, next trip, friends' moments — read only)
Community     → Search          (Friends category)
Groups        → Search          (Groups category)
Trips         → Search          (Trips and Courses categories)
Profile       → Trips           (golfer's name and handicap for a new trip's organiser)
Community     → Trips           (friends' handicaps and the invite list)
Groups        → Friends Home    (club previews: name, size, season, next round)
Rounds        → Search          (Rounds category)
Profile       → Search          (Courses category — profileFavouriteCourses)
```

This was a clean DAG until the Trips completion (Release Candidate), which added the `Profile → Trips` and `Community → Trips` edges. `Profile → Trips` closes a two-feature cycle (**Trips ⇄ Profile**: Profile reads Trips' counts; Trips reads the golfer's name and handicap from Profile). There are no import cycles at the file level — `placeholder_trips.dart` imports nothing from Profile — but the feature-level cycle is recorded as **TD-012** with its fix (a shared current-user provider). The longest chain is five features deep:

```
Rounds → Groups → Profile → Statistics
                → Golf Bag
                → Settings → Notifications (reversed: Settings reads Notifications, not the other way — shown separately above)
```

**Implication for future features:** before importing another feature's placeholder data, check this graph for the chain you would be joining. Statistics already reads from three features directly (Community, Groups, Profile); Search reads from five (Community, Groups, Trips, Rounds, Profile) directly, more than any other feature — but all five edges terminate at Search, which nothing else reads from, so Search adds breadth, not depth, to the graph. Settings transitively depends on Profile, which transitively depends on Community/Groups/Trips, which depends on Rounds. A breaking change to `PositionBadge` (Rounds) could in principle ripple five features deep before reaching Settings. This has not caused a problem yet — every edge above was the correct call to avoid literal duplication, and the alternative (duplicated literals) already caused one real bug before Profile existed (the Handicap Consistency incident) — but a new feature adding another edge should consult this graph first, not reconstruct it by hand.

**Authentication is the one node with no edges at all**, in either direction — it introduces no data another feature could read, and (unlike every other feature) deliberately reads nothing from Profile or anywhere else, since it does not yet touch the identity model it will eventually replace. See `docs/architecture/authentication-engineering-decisions.md`.

---

# How to Use This Document

**When building a new feature:** before writing a placeholder constant, check the Ownership Table above. If the value already has an owner, import it (directly, or via a computed getter) — do not redeclare it. Add your feature's own row to the table once it's implemented, and add any new edges to the dependency graph.

**When writing a feature's `*-engineering-decisions.md`:** its "Source of Truth" section should state which rows of this table it reads from and link here, rather than re-explaining the general principle from scratch.

**When two documents disagree about who owns a value:** this document is canonical for ownership specifically (see `docs/ai/architecture-principles.md`'s Documentation Precedence section for how it ranks against other document types).

---

# Related Documents

- `docs/ai/architecture-principles.md` — Documentation Precedence section; general engineering principles
- `docs/ai/project-rules.md` — "Never invent placeholder data" rule that Exception 1 above exists under
- `docs/reviews/architecture-review-2.md` — Section 8, the review that identified this document was empty (TD-004) and reconstructed the dependency graph by hand
- `docs/reviews/technical-debt.md` — TD-004 (this document being empty), TD-005 (Dashboard's missing public constant, Exception 2)
- `docs/architecture/search-data-model.md`, `docs/architecture/search-engineering-decisions.md` — Search (Feature 10), the first feature to read from five other features directly
- `docs/architecture/authentication-data-model.md`, `docs/architecture/authentication-engineering-decisions.md` — Authentication (Feature 11), the only feature with zero cross-feature edges
