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

Current State

21 screens across 9 features each construct their own `AppBar(title: Text('X'))` inline. No `appBarTheme` is set in `qaddy_theme.dart`. Dashboard is the only screen with an explicit AppBar style override (`backgroundColor: colours.background, elevation: 0`, added for the Notifications bell icon); the other 20 rely on Material 3's default AppBar background (`colorScheme.surface`), which currently happens to look consistent with the scaffold background but isn't enforced to.

Risk

A future palette change to either `colours.background` or `colours.surface1` independently could introduce a visible seam at the top of 20 screens with no single place to fix it.

Action

Add an `appBarTheme` to `qaddy_theme.dart`'s `ThemeData` (lower-disruption option given 21 existing call sites), or introduce a `QaddyAppBar` wrapping widget consistent with every other shared UI pattern in the app.

Target

Next design-system maintenance pass.

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

Status: Open (new, identified while populating `data-ownership.md`)

Current State

Dashboard's round-summary values (Rounds Played, Average Score, Best Round, Fairways Hit, Greens in Regulation) are private literals inside `dashboard_screen.dart`'s widget tree — there is no public constant another feature can import. Profile needs the same values (its own Playing Statistics section) and currently matches them by documentation convention — both must independently equal `docs/placeholder-data.md`'s "Statistics" section — rather than by a code-level import, per `profile-engineering-decisions.md`'s "Friends, Groups and Rounds-Played Counts Are Computed, Not Duplicated".

Risk

This is the one place in the app where the Single-Source-of-Truth principle is enforced by convention rather than by import. If either Dashboard's or Profile's literal is edited without updating the other, they will silently drift — the exact class of bug the Handicap Consistency incident (before Profile existed) was caused by.

Action

Expose Dashboard's round-summary values as a public constant (e.g. `lib/features/dashboard/models/placeholder_dashboard.dart`) and have Profile import it instead of redeclaring matching literals.

Target

Next Dashboard- or Profile-touching feature, or a dedicated cleanup pass.