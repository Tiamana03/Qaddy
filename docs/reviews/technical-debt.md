## TD-001 — Promote QaddyInfoRow

Priority: Medium

Status: **Resolved** (architecture maintenance pass, 2026-10-01)

Current State

~~Trips, Friends, Groups and Profile each contain a private InfoRow implementation.~~ All four have been migrated to the shared widget. `TripInfoRow` and `FriendInfoRow` have been deleted; Groups' and Profile's private `_InfoRow` classes have been removed and both files now import `lib/core/widgets/rows/qaddy_info_row.dart`. No feature in the app defines its own InfoRow implementation anymore (Rounds' own private `_InfoRow` was out of scope for this pass — it was not one of the four named in Architecture Review #2 Section 5, since it predates `QaddyInfoRow` and wasn't flagged there; it remains a candidate for a future pass).

Action

~~Migrate all remaining features to QaddyInfoRow.~~ Done.

---

## TD-002 — Orphaned `lib/features/golf_bag/` scaffold folder

Priority: Medium

Status: **Resolved** (architecture maintenance pass, 2026-10-01)

Current State

~~`lib/features/golf_bag/{logic,models,repositories,services,ui/screens,ui/widgets}` exists as an empty, `.gitkeep.md`-only folder structure~~ — deleted. The real implementation remains at `lib/features/my_bag/`, per `docs/technical-architecture.md`'s own Features folder-structure example.

Action

~~Delete `lib/features/golf_bag/`.~~ Done. The suggestion to add a guard note to `technical-architecture.md` confirming `my_bag` is correct remains open as a low-priority follow-up — not actioned in this pass since it was a "consider" item, not the core action.

---

## TD-003 — No shared AppBar styling

Priority: Low

Status: **Resolved** (Polish & Launch, 2026-10-01)

Current State

~~22 screens each construct their own `AppBar(title: Text('X'))` inline. No `appBarTheme` is set in `qaddy_theme.dart`.~~ `qaddy_theme.dart` now sets `appBarTheme` (background `colours.background`, `elevation: 0`, `foregroundColor: colours.textPrimary`) on both Light and Dark theme builds, matching what Dashboard's own explicit override already was — Dashboard's now-redundant `backgroundColor`/`elevation` parameters were removed since the theme supplies them. The other 21 screens were visually unaffected (Material 3's default already happened to resemble `colours.background`), but the consistency is now enforced rather than accidental.

Action

~~Add an `appBarTheme` to `qaddy_theme.dart`'s `ThemeData`.~~ Done.

---

## TD-004 — `data-ownership.md` is empty

Priority: Medium

Status: **Resolved** (architecture maintenance pass, 2026-10-01)

Current State

~~`docs/architecture/data-ownership.md` exists and is referenced by name in implementation instructions, but has no content.~~ Populated: the general principle, the per-feature ownership table, the two documented exceptions, and the reconstructed cross-feature dependency graph now live there as the canonical reference. Existing per-feature `*-engineering-decisions.md` "Source of Truth" sections were not rewritten (not required by this pass) — future features should link to `data-ownership.md` instead of restating the principle.

Action

~~Populate data-ownership.md...~~ Done.

---

## TD-005 — Dashboard's round-summary statistics have no public constant

Priority: Low

Status: **Resolved** (Polish & Launch, 2026-10-01)

Current State

~~Dashboard's round-summary values (Rounds Played, Average Score, Best Round, Fairways Hit, Greens in Regulation) are private literals inside `dashboard_screen.dart`'s widget tree — there is no public constant another feature can import.~~ `lib/features/dashboard/models/placeholder_dashboard.dart` (new) exposes `dashboardRoundsPlayed`, `dashboardAverageScore` and `dashboardBestRound` publicly; `dashboard_screen.dart` reads from it instead of inline literals, and Profile's `profileRoundsPlayed`/`profileAverageScore`/`profileBestRound` are now computed from these constants rather than independently declared. Fairways Hit and Greens in Regulation were never shown on Dashboard at all — verified during this pass — so they were never actually duplicated and remain ordinary Profile-only literals.

Action

~~Expose Dashboard's round-summary values as a public constant and have Profile import it instead of redeclaring matching literals.~~ Done.

---

## TD-006 — Orphaned `lib/core/design_system/` scaffold contradicting `folder-structure.md`

Priority: Medium

Status: **Resolved** (Architecture Review #3 maintenance pass, 2026-10-01)

Current State

~~`lib/core/design_system/{widgets,tokens,theme,icons,animations}/` existed as an empty, `.gitkeep.md`-only scaffold, while `docs/architecture/folder-structure.md`'s own Core listing (`theme/ widgets/ services/ models/ utils/ extensions/`) — and the real implementation — both use `lib/core/widgets/` and `lib/core/theme/` instead. Ten separate feature `.gitkeep.md` files (`achievements`, `authentication`, `community`, `dashboard`, `golf_iq`, `profile`, `rounds`, `settings`, `statistics`, `trips`) each pointed contributors at the wrong location: "Anything reusable across features belongs in core/design_system/widgets instead."~~ `lib/core/design_system/` has been deleted and all 10 `.gitkeep.md` files now correctly read "core/widgets". Traced to the original `M0: Foundations & Tooling` commit (`c14f5b2`) — the scaffold predates Sprint 1's real design system and was never reconciled once `core/widgets/`/`core/theme/` were built instead.

Action

~~Delete `lib/core/design_system/` and correct the 10 `.gitkeep.md` comments.~~ Done.

---

## TD-007 — `data-ownership.md` cited a non-existent filename for Authentication

Priority: Low

Status: **Resolved** (Architecture Review #3 maintenance pass, 2026-10-01)

Current State

~~The Authentication row in `docs/architecture/data-ownership.md`'s Ownership Table cited `lib/features/authentication/models/onboarding_pages.dart` (plural); the real file is `onboarding_page.dart` (singular).~~ Corrected.

Action

~~Fix the filename reference.~~ Done.

---

## TD-008 — M0/M1/M2 milestone terms used in code were undefined in the roadmap

Priority: Medium

Status: **Resolved** (Architecture Review #3 maintenance pass, 2026-10-01)

Current State

~~`lib/main.dart` ("running M0 locally", "until M2 wires auth") and `lib/core/config/env/README.md` ("see the Release One roadmap, M0") both referenced milestone terms that `docs/roadmap/release-1-roadmap.md` never defined anywhere, despite the roadmap's own Purpose section listing "milestone progression" as something it covers.~~ `release-1-roadmap.md` now has a "Milestones" section defining M0 (Foundations & Tooling, complete — commit `c14f5b2`), M1 (Release 1, this document's own scope) and M2 (Backend & Authentication, begins Release 2), grounded in the actual commit history and cross-referenced from both code locations above.

Action

~~Add canonical M0/M1/M2 definitions to the roadmap.~~ Done.

---

## TD-009 — Rounds' private `_InfoRow` is the last unmigrated copy in the codebase

Priority: Low

Status: **Resolved** (Polish & Launch, 2026-10-01)

Current State

~~`lib/features/rounds/ui/screens/rounds_screen.dart` still defines its own private `_InfoRow`~~ — migrated to `QaddyInfoRow`, the same two-step fix (replace call sites, delete the private class, add the import) already applied to Trips, Friends, Groups and Profile under TD-001. `grep -rn "class _InfoRow\|class \w*InfoRow" lib` now returns exactly one match: `QaddyInfoRow` itself.

Action

~~Migrate `rounds_screen.dart`'s `_InfoRow` call sites to `QaddyInfoRow` and delete the private class.~~ Done.

Target

Next Rounds-touching feature, or a dedicated cleanup pass.

---

## TD-010 — Trips are not persisted

Priority: Medium

Status: **Resolved** (Trips delight pass, November 2026)

Current State

~~Trips lived in an in-memory store and were lost when the app restarted.~~ `TripsController` now loads the trips on start-up and saves after every change through `TripsStorage`, backed by `shared_preferences` on the device (see `docs/decisions/ADR-002-trips-device-packages.md`). The document is versioned; an unreadable one falls back to the seed trips. This is still on-device only — it does not sync between devices or users, which is Release 2's backend.

Action

~~Back the controller with a repository.~~ Done.

---

## TD-011 — Profile's trip counts are the seed constants, not the live store

Priority: Low

Status: **Open** (logged during the Release Candidate Trips completion, October 2026)

Current State

Profile still reads `upcomingTripsCount`, `pastTripsCount` and `countriesVisitedCount` from `placeholder_trips.dart`. Create or delete a trip and the Trips tab updates but the numbers on Profile do not. Search, by contrast, already reads the live store.

Action

Have Profile derive its counts from `upcomingTripsProvider`, `pastTripsProvider` and the set of countries, then delete the three constants. Do this when Profile is next reviewed, together with TD-012.

Target

Profile Release Candidate review.

---

## TD-012 — Trips and Profile depend on each other

Priority: Low

Status: **Open** (logged during the Release Candidate Trips completion, October 2026)

Current State

Profile reads Trips (counts, TD-011) and Trips reads Profile (the golfer's handicap, via `placeholder_profile.dart`, so a new trip's organiser carries the same handicap Profile shows — the Handicap Consistency rule). That is a feature-level cycle in `docs/architecture/data-ownership.md`'s graph. It is harmless today (no file imports its way back to itself) but it means neither feature can be changed or extracted without the other.

Action

Introduce a small shared current-user provider (name, handicap) outside both features, and have Trips and Profile read from it. Combined with TD-011, Profile then depends on Trips but not the reverse.

Target

Before the backend work, when the current-user model is introduced.

---

## TD-013 — Trips still has a few placeholders

Priority: Low

Status: **Partly resolved** (Trips delight pass, November 2026; the owner approved `shared_preferences`, `url_launcher` and `share_plus`, not the PDF or image packages)

Current State

Resolved: phone numbers call, websites and addresses open (a place or a route in the maps app), and the invite message and itinerary go through the system share sheet; each falls back to copying when nothing can open or share. Photos were removed from the course and stay pages rather than shown as empty boxes. The Download PDF button was removed.

Still placeholders:

- **PDF export** — the itinerary is shared or copied as text. A formatted PDF needs `pdf` + `printing`, not yet approved.
- **Trip cover** — one of six gradient presets; a real photo needs `image_picker` (and storage).
- **Map** — a stylised map tile that opens the real map in a maps app on tap; an embedded map needs a maps package.
- **Weather** — typed in by hand (Edit Trip → Weather); there is no forecast service.
- **Invite links** — there are none: "Share Invite" sends a self-contained message instead of a link to a page that does not exist. Real links need the backend and deep-link handling.
- **Chat** — delivery ticks and the typing indicator are timed simulations; other people's messages need the backend.
- **Seed websites** use the reserved `.example` domain, so tapping one on a device reaches a "can't reach this site" page.

Action

Revisit when the backend (Release 2) lands, or sooner if PDF or photos are judged launch-critical.

Target

Release 2.

---

## TD-014 — The friends store is in memory, and other features read the placeholder constants

Priority: Medium

Status: **Open** (logged during the Friends Home redesign, November 2026)

Current State

Friends Home, Friends List, Friend Requests and Activity Feed share `friendsProvider` (`features/community/state/friends_controller.dart`), so accepting a request is reflected across them. But the store is in memory — an accepted friend or a cheer is lost on restart (Trips, by contrast, persists) — and Search, Trips (the friend picker and handicaps) and Profile (the friends count) still read `placeholder_friends.dart` directly, so they do not see a friend accepted this session.

Action

Persist the store the same way as Trips (a versioned document behind a small storage interface), and move Search, the Trips friend picker and Profile onto `confirmedFriendsProvider`. Do this when those screens are next reviewed, ahead of the Release 2 backend.

Target

Search and Profile Release Candidate reviews.

---

## TD-015 — The Dashboard's round countdown works from a day name, and some of its data is placeholder

Priority: Low

Status: **Open** (partly resolved by the Rounds redesign) (logged during the Dashboard redesign, November 2026)

Current State

`roundCountdown` (`features/dashboard/logic/dashboard_insights.dart`) counts the days to the next round from the round's day name ("Saturday"), because the placeholder round (`placeholder_rounds.dart`) has no calendar date. The notification dot on the bell is always shown (Notifications has no read state). The last round (The Dunes), the highlights and the weather are placeholder text, and the Round Complete screen shows a different round (Richmond), so the last-round card does not link to it. 

Action

Give `UpcomingRound` a real `DateTime` and make `roundCountdown` take it; give Notifications a read state and drive the dot from it; make Rounds a real flow (next screen to review) so "Get ready" and the last-round card have real destinations.

Target

Rounds and Notifications Release Candidate reviews.

---

## TD-016 — Trips has its own copy of the shortcut tiles

Priority: Low

Status: **Open** (logged during the Profile redesign, November 2026)

Current State

`QaddyQuickActions` (`core/widgets/actions`) is now shared by the Dashboard and Profile. Trips still builds its own `TripsQuickActions` with the same job.

Action

Move Trips onto `QaddyQuickActions` the next time the Trips screen is touched (it may need an optional subtitle or badge first). Also note the dependency cycle created on purpose: the results screen (Rounds) shows achievements, which are computed from Statistics, which reads Rounds' history. Every edge is read-only and no file imports its way back, but a change to `CareerStats` or `Round` should be checked against all three.

Target

Next Trips review.

---

## TD-017 — Trips and Rounds each have their own on-device storage class

Priority: Low

Status: **Open** (logged during the Golf Bag redesign, November 2026)

Current State

`core/services/document_storage.dart` is the shared seam for keeping one JSON document on the device (`DocumentStorage`, `NoDocumentStorage`, `SharedPreferencesDocumentStorage`). Golf Bag uses it. `TripsStorage` and `RoundsStorage` are near-identical copies that predate it.

Action

Make `TripsStorage` and `RoundsStorage` use `DocumentStorage` (keeping their provider names and keys, `qaddy.trips.v1` and `qaddy.rounds.v1`) the next time Trips or Rounds is touched. A pure move: no behaviour changes.

Target

Next Trips or Rounds review.

---

## TD-018 — Every golfer gets the same seeded world

Priority: Medium

Status: **Open** (logged during the Identity pass, November 2026)

Current State

The golfer is now their own (name, handicap, home course — `docs/features/identity.md`), but the friends, groups, trips, season table and rivalry around them are the same seeded data for every golfer, and the seeded world is built once per launch around the golfer's id, which is why the name cannot be changed without "Start over".

Action

When the backend arrives, replace the seeded world with real data and let the id be a real account id (then a name can change freely). Until then, keep it clearly labelled and out of the way.

Target

Release 2.
