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