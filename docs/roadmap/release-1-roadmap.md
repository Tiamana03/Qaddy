# Qaddy Release 1 Roadmap

# Release 1 Roadmap

## Purpose

This document is the canonical roadmap for Release 1.

It defines:

- the feature implementation order
- release goals
- milestone progression
- launch criteria

Whenever implementation prompts reference **Feature X**, this document is the single source of truth.

---

# Milestones

This roadmap's "milestone progression" (see Purpose above) is tracked at a broader level than its own 12 features / 13 sprints, using a milestone sequence referenced directly in code (`lib/main.dart`, `lib/core/config/env/README.md`). Those references point here; this section is their canonical definition.

- **M0 — Foundations & Tooling.** Project scaffolding, CI pipeline, environment configuration (`lib/core/config/`), analytics/crash-reporting service stubs, and platform (Android/iOS) project setup. Predates Sprint 1 and this roadmap's Feature Order entirely. **Complete** — commit `c14f5b2`, "M0: Foundations & Tooling". `lib/main.dart`'s "e.g. running M0 locally" and `lib/core/config/env/README.md`'s "Until a real Supabase project exists (see the Release One roadmap, M0)" both refer to this milestone: `AppConfig.isBackendConfigured` is false throughout it, by design, because no Supabase project had been provisioned yet.
- **M1 — Release 1.** This roadmap's entire scope — all 12 features in the Feature Order below, built against placeholder data with no backend. `AppConfig.isBackendConfigured` remains false throughout M1 as well; nothing in Release 1 requires a real backend to function (see `docs/architecture/authentication-engineering-decisions.md`'s "This Flow Is Not the App's Boot Sequence").
- **M2 — Backend & Authentication.** Provisioning a real Supabase project and wiring real authentication, replacing Authentication's placeholder Splash/Onboarding/Login/Sign Up screens with a working sign-up/sign-in flow and making it the app's actual boot sequence — see `docs/architecture/authentication-future-roadmap.md`. `lib/main.dart`'s "aren't reachable until M2 wires auth" refers to this milestone. M2 begins Release 2 and is out of scope for this document.

---

# Release 1 Feature Order

1. Dashboard ✅
2. Rounds ✅
3. Trips ✅
4. Friends ✅
5. Profile ✅
6. Statistics ✅
7. Golf Bag ✅
8. Notifications ✅
9. Settings ✅
10. Search ✅
11. Authentication ✅
12. Polish & Launch ✅

---

# Current Progress

Completed:
- ✅ Dashboard
- ✅ Rounds
- ✅ Trips
- ✅ Friends
- ✅ Profile
- ✅ Statistics
- ✅ Golf Bag
- ✅ Notifications
- ✅ Settings
- ✅ Search
- ✅ Authentication
- ✅ Polish & Launch

Current Feature:
- (none — Release 1 is complete)

Remaining:
- (none)

---

# Release Goal

*(existing roadmap content continues here...)*

...

## Purpose

This document is the single source of truth for the Release 1 implementation order.

All implementation work must follow this roadmap.

Claude must never infer the next feature from architecture documents, future roadmap documents, TODO comments or placeholder references.

If the roadmap and another document disagree, this roadmap takes precedence until updated.

---

# Release Status

Renumbered to match "Release 1 Feature Order" above exactly — Sprint N corresponds to Feature (N-1), since Sprint 1 (Foundation) precedes the numbered Feature list and is not itself one of the 12 features. This table previously listed Courses, Handicap, Calendar, Offline Mode, AI Features, Performance Optimisation and Beta Polish as separate sprints that appear nowhere in Feature Order, and never marked Trips complete at all despite it being the third feature built. Both are corrected below.

| Sprint | Feature | Status |
|---------|----------|--------|
| Sprint 1 | Foundation | ✅ Complete |
| Sprint 2 | Dashboard | ✅ Complete |
| Sprint 3 | Rounds | ✅ Complete |
| Sprint 4 | Trips | ✅ Complete |
| Sprint 5 | Friends | ✅ Complete |
| Sprint 6 | Profile | ✅ Complete |
| Sprint 7 | Statistics | ✅ Complete |
| Sprint 8 | Golf Bag | ✅ Complete |
| Sprint 9 | Notifications | ✅ Complete |
| Sprint 10 | Settings | ✅ Complete |
| Sprint 11 | Search | ✅ Complete |
| Sprint 12 | Authentication | ✅ Complete |
| Sprint 13 | Polish & Launch | ✅ Complete |

---

# Sprint Goals

## Sprint 1 — Foundation

Establish the project architecture, design system, routing, theming, reusable components and development workflow.

---

## Sprint 2 — Dashboard

Build the application's primary landing screen and navigation hub.

---

## Sprint 3 — Rounds

Implement round management, scoring, leaderboards and round lifecycle.

---

## Sprint 4 — Trips

Implement golf trip planning, itineraries, accommodation, transport and expenses.

---

## Sprint 5 — Friends

Implement social features including friends, groups, rivalries and community.

---

## Sprint 6 — Profile

Implement player profiles, statistics summary, achievements preview and personal information.

---

## Sprint 7 — Statistics

Implement detailed player statistics, trends, charts, records and performance analysis.

---

## Sprint 8 — Golf Bag

Implement golf clubs, equipment management, club distances and bag analytics.

---

## Sprint 9 — Notifications

Implement push notifications, invitations, reminders and in-app notifications.

---

## Sprint 10 — Settings

Implement user preferences, appearance, privacy and application settings.

---

## Sprint 11 — Search

Implement global search across friends, rounds, trips, groups and courses.

---

## Sprint 12 — Authentication

Replace placeholder users with secure authentication, user accounts and onboarding.

---

## Sprint 13 — Polish & Launch

Complete performance optimisation, accessibility improvements, UX refinements, final QA, production configuration, release validation and deployment preparation.

---

# Implementation Rules

Before every implementation Claude must:

1. Read this roadmap.
2. Determine the next incomplete sprint.
3. Follow the implementation workflow.
4. Complete documentation until zero blockers remain.
5. Only then begin implementation.
6. Update this roadmap when the sprint has been completed.

---

# Success Criteria

Release 1 is considered complete when:

- All 13 sprints are marked Complete.
- Documentation contains zero blockers.
- Flutter Analyze passes.
- All automated tests pass.
- Manual QA has been completed.
- The application is production ready.

**Status as of Polish & Launch (2026-10-01):** all 13 sprints marked Complete above; `flutter analyze --fatal-infos` and `flutter test` (123/123) pass; documentation inconsistencies found during Architecture Review #3 and Polish & Launch were corrected (see `docs/reviews/technical-debt.md`). "Manual QA" here means a representative in-browser spot check of key flows (Dashboard, navigation, Search, Authentication, the Rounds/AppBar polish changes) — not an exhaustive pass over all 33 screens on every platform/breakpoint, which remains appropriate for a dedicated QA pass before a real launch.