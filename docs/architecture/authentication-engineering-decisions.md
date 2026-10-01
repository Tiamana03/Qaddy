# Authentication Engineering Decisions

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates the engineering decisions specific to the Authentication feature.

Per-document Engineering Decisions sections still apply where they exist (`authentication-data-model.md`); this document exists for decisions that span the whole feature rather than belonging to one model.

---

## This Flow Is Not the App's Boot Sequence

`navigation.md` has always named `/`, `/onboarding` and `/login` as "Public Routes," and `app_routes.dart`'s own header comment confirms they were deliberately deferred past Sprint 1.2 rather than built then. Building them now raises an immediate question with no existing precedent to resolve it: should the app's `initialLocation` change from `AppRoutes.home` to `AppRoutes.splash`, making every launch go through this flow first?

This was escalated to the product owner rather than decided silently, because it is a genuinely ambiguous, high-blast-radius call with no prior art in this codebase (every other Release 1 feature was additive and changed zero existing tests) — exactly the class of decision `docs/ai/implementation-workflow.md`'s Phase 5 reserves for explicit sign-off rather than automatic resolution.

**Decision (confirmed by the product owner):** keep `initialLocation: AppRoutes.home` for all of Release 1. Splash, Onboarding, Login and Sign Up are built as real, working, fully navigable routes, but nothing currently shipped links to them and the app continues to boot straight to Dashboard, exactly as it does today. These screens become the real authentication flow — and only then a real boot gate — in Release 2, once Supabase authentication is implemented.

**Why:** there is no real session to gate on yet — `lib/main.dart`'s `isBackendConfigured` is false until a Supabase project is provisioned, so a "real" auth gate is not actually possible in Release 1 regardless of this decision. Forcing every launch through four placeholder screens with no functional purpose would only add friction to every future manual QA pass and to the ~15 existing tests that currently `pumpWidget(QaddyApp())` and assert Dashboard content immediately, for a gate that doesn't gate anything real.

**How to apply:** `app_router.dart` adds `/`, `/onboarding`, `/login` and `/signup` as top-level `GoRoute`s, siblings of the existing `StatefulShellRoute`, not nested inside it and not referenced by `initialLocation`. Zero existing routes, screens, or tests change.

---

## Navigation Uses `go`, Not `push`

Every transition in this feature — Splash → Onboarding, Onboarding → Login, Login ↔ Sign Up, either → Dashboard — uses `context.go`, replacing the current route rather than stacking on top of it.

**Why:** this is a one-way introduction sequence, and the Login/Sign Up link is a lateral swap, not a drill-down worth preserving in a back stack either. A user who reaches Login should never be able to press back into Onboarding, a user on Sign Up should never press back into a half-filled Login (and vice versa), and a user who reaches Dashboard should never be able to press back into either — there is nothing to return to, and every other Release 1 "back" gesture is documented to return somewhere meaningful (`navigation.md`'s per-feature "Users may return to X from any child screen" pattern). Nothing meaningful exists to return to here.

**How to apply:** no screen in this feature uses `context.push` or renders a back button; `AppBar`s are omitted entirely on all four screens.

---

## Onboarding Introduces Rounds, Friends and Trips — Not a Generic Pitch

Three pages were chosen, each describing one already-implemented Release 1 feature (Rounds, Friends, Trips), rather than generic marketing copy or a pitch for unbuilt future features (Golf IQ, Ask Qaddy, etc.).

**Why:** `docs/ai/project-rules.md`'s "never invent placeholder data" principle extends naturally to onboarding copy — describing a feature that doesn't exist yet would be a false promise the app can't back up. Rounds, Friends and Trips are three of the four non-Home, non-Profile bottom-navigation tabs (`navigation.md`'s Bottom Navigation table) — Profile was excluded because it is identity-focused, not a feature to "pitch" to a new user, and three pages is a conventional, unremarkable onboarding length (not two, not five).

**How to apply:** `onboardingPages` (`authentication-data-model.md`) has exactly three entries, each naming an icon and copy that matches that feature's own established identity (e.g. Rounds' page uses `Icons.sports_golf`, matching Search's own choice of icon for its Rounds category).

---

## Login and Sign Up Reuse Sprint 1.3's Form Fields Exactly

`QaddyTextField` and `QaddyPasswordField` (`lib/core/widgets/forms/`) already exist. `QaddyPasswordField`'s own doc comment states Sprint 1.3 built it "for future authentication screens" before this feature existed.

**Why:** this is the clearest "Reuse Before Creation" case in the project so far — the components were built in anticipation of exactly these screens, by name, two Sprints ago. Building new fields instead would directly contradict that stated intent.

**How to apply:** Login's Email field and Sign Up's Full Name/Email fields use `QaddyTextField`; both screens' Password fields use `QaddyPasswordField`. Neither component is modified.

---

## Login and Sign Up Are Two Screens, Not One Screen With a Toggle

An earlier pass built a single Login screen with a local "Sign In / Create Account" mode toggle. The product owner's restated scope explicitly names "Login and Sign Up" as separate items in the four-screen list, so this was split into two screens/routes (`/login`, `/signup`), each linking to the other.

**Why:** two separate, independently-reachable screens is the more conventional auth pattern, and matches what Release 2's real Supabase integration will need regardless (a distinct sign-up screen, not a mode flag) — splitting now avoids a second rework later. The shared "Qaddy wordmark + subtitle" header the toggle version used is extracted into `AuthHeader` so it is still written once, not duplicated across the two new screens.

**How to apply:** `login_screen.dart` and `sign_up_screen.dart` are both stateless; each links to the other via `context.go`, not a `setState` toggle. `AuthHeader` (`lib/features/authentication/ui/widgets/auth_header.dart`) takes a `subtitle` parameter and is used by both.

---

## Sign In / Create Account Submit Is a Pure Navigation, Not a Validated Action

Tapping Login's or Sign Up's primary button always navigates to Dashboard, regardless of field contents — no emptiness check, no format check, no error state.

**Why:** matches the same "visual only" simplification used everywhere else in Release 1 (Search Friends' "Add Friend," Settings' read-only rows, every feature's own "Primary Actions are visual only" test) — anything more would be inventing business logic `docs/ai/implementation-workflow.md`'s Phase 6 explicitly forbids ("Never invent... business logic"), since there is no backend to validate against.

**How to apply:** each primary button's `onPressed` is `() => context.go(AppRoutes.home)` unconditionally; field controllers are read by nothing.

---

# Source of Truth

Authentication introduces no data owned by another feature, and nothing else in the app reads from it. It is the one Release 1 feature with no cross-feature dependency in either direction — see `docs/architecture/data-ownership.md`.

---

# Related Documents

- authentication-data-model.md
- docs/features/authentication-feature-integration.md
- authentication-future-roadmap.md
- navigation.md
- docs/architecture/data-ownership.md
- docs/ai/implementation-workflow.md

---

**End of Document**
