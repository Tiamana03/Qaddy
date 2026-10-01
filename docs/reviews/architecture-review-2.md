# Architecture Review #2

Review after Feature 9 (Notifications, Settings). Covers repository structure, routing, navigation hierarchy, reusable widgets, design consistency, documentation hierarchy, data ownership, placeholder data, technical debt, feature boundaries, bottom navigation, and Profile as a navigation hub.

This is a review only. No Flutter code or documentation outside this review and `technical-debt.md` was modified to produce it.

---

## 1. Repository Structure

**Finding — an orphaned, empty `lib/features/golf_bag/` folder sits next to the real `lib/features/my_bag/` implementation.**

Someone pre-scaffolded `lib/features/golf_bag/{logic,models,repositories,services,ui/screens,ui/widgets}` with `.gitkeep.md` files before Golf Bag was implemented. `docs/technical-architecture.md`'s own Features folder-structure example names the folder `my_bag/`, so the actual implementation went there instead — correctly, per that document — but the empty `golf_bag/` scaffold was never removed. Two folders now exist for one feature: one real, one dead.

This is the clearest concrete artifact in the repo of a documentation/scaffold disagreement. `my_bag` is correct per the written architecture doc; `golf_bag` is what a future contributor would instinctively look for first, given it matches the public feature name and the route segment (`/profile/bag` notwithstanding).

**Recommendation:** delete `lib/features/golf_bag/` (Flutter code change, so out of scope for this review to action) and consider whether `technical-architecture.md` should also state explicitly "do not create a `golf_bag/` folder — see `my_bag`'s own Engineering Decision" to stop it from being recreated by a future scaffolding pass.

**Finding — pre-scaffolded folders exist for features not yet in Feature Order.** `achievements/` and `golf_iq/` are empty `.gitkeep`-only scaffolds. Neither is in `release-1-roadmap.md`'s 12-item Feature Order (Achievements is explicitly deferred per `profile-future-roadmap.md`; Golf IQ is a `product-specification.md` pillar with no roadmap slot at all yet). `authentication/` is scaffolded and *is* Feature 12 in the canonical order — correctly prepared ahead of time.

Not a problem by itself, but worth noting: there is no document that says "these scaffold folders exist, here's why, don't build inside them until the roadmap says so." A contributor encountering `achievements/` with a full folder skeleton could reasonably assume it's ready for work.

**Recommendation:** a one-line note in `release-1-roadmap.md` or `technical-architecture.md` acknowledging pre-scaffolded-but-not-yet-scheduled folders would close this gap cheaply.

**Finding — folder structure depth is otherwise consistent.** Every implemented feature follows `models/ui/{screens,widgets}` at minimum; `community`, `dashboard`, `profile`, `rounds`, `trips`, `statistics`, `settings`, `golf_iq`(scaffold), `achievements`(scaffold), `authentication`(scaffold) additionally carry `logic/`, `repositories/`, `services/` (mostly empty `.gitkeep` placeholders for repositories/services, since no backend exists yet). `groups`, `my_bag` and `notifications` are leaner — just `models/ui` — because neither needed ranking/formatting logic or future repository seams yet. This is a reasonable, not-yet-problematic inconsistency: the leaner features simply haven't needed the extra folders, not a sign of divergent structure.

---

## 2. Routing & Navigation Hierarchy

Routing is in good shape. Every nested route lives under the branch it conceptually belongs to, and nesting depth is shallow and consistent:

- `/friends/groups/details` — 3 levels, the deepest in the app
- `/profile/{statistics,bag,settings}` — 2 levels, three siblings
- `/home/notifications` — 2 levels
- `/trips/*` — 2 levels, 8 siblings

No route invents navigation `navigation.md` doesn't document; no orphaned routes exist. `AppRoutes`/`RouteNames` stay in lockstep with `app_router.dart` across all 9 features — I found no drift between the three when cross-checking this review.

**Finding — `navigation.md`'s "Route Names vs Feature Folders" table is incomplete.** It documents `/friends → community` and `/profile/bag → my_bag` (the two folder-name divergences), but Notifications and Settings' folders (`notifications`, `settings`) match their route segments exactly, so they were correctly left out — the table is accurate, just worth confirming it stays that way as a convention (only list genuine divergences, not every route).

---

## 3. Bottom Navigation

Still exactly 5 tabs (Home, Rounds, Trips, Friends, Profile), unchanged since Sprint 1.2. Four features in a row now (Statistics, Golf Bag, Settings, Notifications) extended an existing tab rather than requesting a sixth — the "Bottom Navigation" Engineering Decision in `navigation.md` has held under real pressure, not just in theory. This is a genuine strength worth calling out, not just a non-finding.

---

## 4. Profile as a Navigation Hub

**This is the most consequential finding in this review.**

Profile now carries:
- 12 of its own aggregated sections (Header, Details, Quick Actions, Profile Summary, Playing Statistics, Current Season, Personal Bests, Achievement Showcase, Favourite Courses, Favourite Playing Partners, Equipment, Recent Activity)
- 3 nested destinations reached from its Quick Actions card (Statistics, Golf Bag, Settings)
- 2 more already promised to join it (Achievements, Premium — per `profile-future-roadmap.md` and `navigation.md`'s Profile "Future Expansion")

Profile is no longer "the identity page with a couple of links out" the original design intended — it has organically become a second navigation hub, structurally comparable to Friends Home (which was *designed* as a hub from the start, with lighter per-section content). Two consequences follow directly from this:

**a) Content overlap between Profile and its own children is real, not just a data-layer concern.** Playing Statistics appears on Profile *and* (in more depth) on Statistics. Personal Bests appears on Profile *and* on Statistics. Current Season (Profile) and Season Performance (Statistics) are different cuts of the same `saturdayBoysLeaderboard`/`saturdayBoysSeasonSummary` data. Equipment (Profile) and Golf Bag's own Equipment section are the same five items. None of this duplicates *data* — every engineering-decisions doc for Statistics and Golf Bag is explicit that these are computed from Profile's own constants — but it does mean a user taps "View Statistics" and sees several numbers they just saw on the screen they came from. Each individual decision was locally justified at the time (documented as "Profile is a quick summary, X is the detailed view"), but the cumulative effect across three children is a information-architecture question nobody has stepped back to answer: *should Profile keep showing full detail sections for things that now have their own dedicated screen, or should it shrink to a lighter summary once a feature "graduates" off it?*

**b) The Quick Actions card will keep growing.** It's 3 items now; Achievements and Premium are already slated to make it 5. At some point a card titled "Quick Actions" stops being quick. Friends Home faced an analogous problem and solved it by making its hub the *first* thing a user sees, with lightweight previews rather than full sections. Profile's Quick Actions currently sits second (after Details), with 12 sections of actual content both above and below it in different places.

**Recommendation:** before adding a 4th or 5th Quick Actions entry, make a deliberate decision — documented, not organic — about whether Profile should (i) stay a full aggregation page and let Quick Actions grow, (ii) trim its own sections as each one graduates to a dedicated screen (e.g., once Statistics exists, Profile's own Playing Statistics/Personal Bests could shrink to 2-3 headline numbers with a "View Statistics" link, rather than the full table), or (iii) cap Quick Actions and move further expansions to a different entry point. This doesn't need to happen now, but it should happen before Achievements lands, not after.

---

## 5. Reusable Widgets

**Confirmed, tracked in `technical-debt.md` (TD-001): `QaddyInfoRow` exists in `lib/core/widgets/rows/` and is used by Statistics, Golf Bag and Settings. Trips (`TripInfoRow`), Friends (`FriendInfoRow`), Groups (private `_InfoRow`) and Profile (private `_InfoRow`) still carry their own independent copies — four of them, functionally identical to the shared one.**

My recommendation on TD-001 specifically: migrate now, not later. All four private copies are structurally identical to `QaddyInfoRow` (same fields, same layout, same token usage) — this isn't a judgment call about whether they *could* converge, they already have, they just haven't been pointed at the same class. The migration touches four files' imports and deletes four small private classes; it carries very low risk (each screen's visual output is unchanged, since the implementations are identical) and the longer it's deferred, the more call sites there are to update, and the more likely a fifth or sixth independent copy appears before the first four are consolidated.

**New finding — no shared `QaddyAppBar`, and no `appBarTheme` set in `qaddy_theme.dart`.** 21 screens across 9 features each construct their own `AppBar(title: Text('X'))` inline. Dashboard's is the only one with an explicit style override (`backgroundColor: colours.background, elevation: 0`, added for the Notifications bell); the other 20 rely on Material 3's default AppBar styling, which derives its background from `colorScheme.surface` rather than the scaffold's own `colours.background`. In practice these two values appear close enough that no visible seam shows up in any screenshot taken this session — but that consistency is accidental (two separate colour tokens that happen to be close), not enforced by any shared component or theme setting. A future palette adjustment to either token independently could introduce a visible inconsistency with no single place to fix it.

**Recommendation:** either add an `appBarTheme` to `qaddy_theme.dart` (cheapest fix, makes every unstyled `AppBar` consistent automatically) or introduce a `QaddyAppBar` wrapping widget (more consistent with how every other repeated pattern in this app — cards, buttons, badges, rows — already has a shared wrapper). Given 21 existing call sites, the `appBarTheme` route is far less disruptive.

**No new instance of the `_ResponsiveGrid` duplication (flagged in the Profile review) was introduced by Statistics, Golf Bag, Notifications or Settings** — none of them needed a multi-item responsive grid, so the existing two copies (Dashboard, Profile) didn't gain a third. Worth keeping on the backlog but not urgent.

---

## 6. Design Consistency

No hardcoded colours, spacing, typography or radius values were found in any of the four most recent features (Statistics, Golf Bag, Notifications, Settings) — every value traces to a `QaddyX` theme extension. `QaddyStatisticCard`'s `trend`/`isPositiveTrend` fields, documented since Sprint 2.1 but unused until Statistics, are now exercised correctly. Status badges, section cards and info rows are used the same way across every feature. This dimension is healthy; the AppBar gap above is the one concrete inconsistency risk.

---

## 7. Documentation Hierarchy / Document Precedence

**Finding — no document currently states precedence explicitly, and it's needed.** Across this project, when two documents have disagreed, resolution has happened ad hoc, reasoned out fresh each time (e.g., determining `release-1-roadmap.md`'s Feature Order outranked its own Release Status table; determining `technical-architecture.md`'s folder-naming example outranked whatever produced the `golf_bag` scaffold). There is no written rule saying "when document A and document B disagree, A wins," so each conflict currently requires the same reasoning from scratch.

A reasonable precedence order, based on how conflicts have actually been resolved so far:
1. `docs/roadmap/release-1-roadmap.md` — feature order and scope (explicitly self-declared as canonical for "Feature X")
2. `docs/ai/project-rules.md` / `docs/ai/architecture-principles.md` / `docs/ai/implementation-workflow.md` / `docs/ai/ui-philosophy.md` — process and engineering standards
3. Per-feature `*-data-model.md` / `*-feature-integration.md` — the feature's own authoritative scope and data shape
4. `*-engineering-decisions.md` / `*-future-roadmap.md` — supporting rationale, should never contradict #3
5. `technical-architecture.md`, `product-specification.md`, `founder-blueprint.md`, `qaddy-design-bible.md`, `ui-component-library.md` — foundational vision/standards documents, authoritative where a feature hasn't yet been built out, but superseded by a feature's own docs once one exists (e.g., Golf Bag's data model and engineering-decisions docs are now more specific than `product-specification.md`'s "My Bag" paragraph that originally justified it)

**Recommendation:** write this down somewhere — `data-ownership.md` (see below) or a new short `docs/architecture/document-precedence.md` — so the next conflict doesn't need re-deriving from first principles.

**Finding — documentation volume is now substantial.** 42 files in `docs/architecture/`, 8 in `docs/features/`. Every feature's doc set is internally well cross-referenced (I verified this during each feature's own validation pass), but there is no single index page listing "here are all 9 implemented features' docs, here's what's deferred." `release-1-roadmap.md` partially serves this role for feature order, but not for documentation discoverability.

**Recommendation:** low priority, but a `docs/architecture/README.md` or index would help as the doc count keeps growing linearly with feature count.

---

## 8. Data Ownership

**Finding — `docs/architecture/data-ownership.md` exists and is referenced (requirement 4 of the Notifications/Settings task cited it directly) but is empty.** Every feature since Profile has independently written its own "Source of Truth" section in its `*-engineering-decisions.md` restating a version of the same principle: *"X should never duplicate values already owned by another feature."* Profile, Statistics, Golf Bag, Notifications and Settings all have one. That's five near-identical restatements of one idea, with no central document any of them point back to.

In practice the principle has been applied *correctly* every time — this review found no actual data duplication across any of the 9 features — but the documentation itself is now duplicated in spirit, which is a mild irony worth fixing.

**Recommendation:** populate `data-ownership.md` with the general principle once (ownership table: which feature owns Friends/Groups/Trips/Rounds/Profile/Notifications data; the rule that reuse happens via direct read, never restatement; the two-tier exception for Trend/derived values that need a second data point). Future features' engineering-decisions docs should then link to it rather than re-explain it. Existing docs don't need rewriting — this is about stopping the pattern from continuing, not correcting the past.

**Finding — the cross-feature dependency graph is deeper than any single document shows.** Reconstructing it from imports:

```
Rounds ← Groups (GroupLeaderboardRow reuses PositionBadge)
Community, Groups, Trips ← Profile (Friends/Groups/Trips counts, Season standing, Equipment)
Profile ← Statistics (Career Totals, Scoring Statistics, Personal Records)
Groups ← Statistics (Season Performance, full leaderboard)
Community ← Statistics (Rivalry Performance)
Profile ← Golf Bag (Equipment)
Profile ← Settings (Profile Visibility)
Notifications ← Settings (NotificationCategory)
```

No cycles exist — the graph is a clean DAG — but Settings now transitively depends on Profile, which transitively depends on Community/Groups/Trips, which depends on Rounds. A breaking change to `PositionBadge` (Rounds) could in principle ripple five features deep before reaching Settings. This has not caused a problem yet, and every individual edge was the correct call to avoid literal duplication, but no document currently draws this graph, so nobody can see the ripple radius of a change without reconstructing it by hand (as this review just did).

**Recommendation:** the ownership table recommended above for `data-ownership.md` should include this dependency graph, or a reference to one, so future features can see what they'd be coupling to before adding another edge.

---

## 9. Placeholder Data

No invented placeholder data was found anywhere in Features 6-9 beyond what each feature's own documentation explicitly authorized as "genuinely required" (Statistics' two Trend deltas; Golf Bag's three Club Distances). Every other value traces to an existing source. This remains one of the strongest-held disciplines in the project.

---

## 10. Technical Debt

See `docs/reviews/technical-debt.md`, updated alongside this review with:
- **TD-001** (QaddyInfoRow migration) — recommendation: address now, not deferred further (see Section 5).
- **TD-002** (new) — orphaned `lib/features/golf_bag/` scaffold folder (see Section 1).
- **TD-003** (new) — no shared AppBar styling / `appBarTheme` (see Section 5).
- **TD-004** (new) — `data-ownership.md` is empty while five features' docs restate its intended content independently (see Section 8).

---

## 11. Feature Boundaries

Feature boundaries are respected in the sense that no feature *owns* another's data or duplicates it — every cross-feature read goes through the owning feature's own public constants/getters, never a copy. But "boundary" in the stricter sense (a feature's internals are opaque to others) has loosened steadily: Statistics alone imports from three other features' model files directly. This is a deliberate, well-documented trade-off each time (favouring Single Source of Truth over strict isolation), not an accident, and this review isn't recommending it be undone — the alternative (duplicated literals) has already caused one real bug (the Handicap Consistency incident before Profile existed). The recommendation is the dependency-graph documentation in Section 8, not a structural change.

---

## Summary of Recommendations (priority order)

1. **Decide Profile's long-term shape** before Achievements/Premium add a 4th/5th Quick Actions entry (Section 4). Highest-impact, least urgent deadline-wise, hardest to reverse once more features are bolted on.
2. **Migrate the four remaining InfoRow copies to `QaddyInfoRow`** (TD-001) — low risk, already-identical implementations, purely postponed work.
3. **Delete the orphaned `lib/features/golf_bag/` scaffold** (TD-002) and add a guard note to `technical-architecture.md` so it isn't recreated.
4. **Populate `data-ownership.md`** (TD-004) with the ownership table and dependency graph, and have future features link to it instead of restating the principle.
5. **Add an `appBarTheme` to `qaddy_theme.dart`** (TD-003) — cheap, removes an accidental-not-enforced consistency.
6. **Write down document precedence** (Section 7) — even a short, explicit list prevents re-deriving it from scratch at the next conflict.

Nothing above is urgent enough to block Feature 10. All are either documentation-only or small, low-risk, well-isolated code changes whenever they're scheduled.
