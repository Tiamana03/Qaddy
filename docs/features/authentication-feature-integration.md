# Authentication Feature Integration

## Overview

This document defines how the complete Authentication feature (Release 1 Feature 11 / Sprint 12) is integrated within Qaddy.

Authentication is three visual-only screens — Splash, Onboarding and Login — reachable as real, working routes. They are not wired into the app's boot sequence and do not gate access to anything, because there is no real session to gate on yet: `lib/main.dart` already defers real Supabase authentication to a future milestone (`isBackendConfigured` is false until a Supabase project is provisioned; see its own comment, "features that need a live backend simply aren't reachable until M2 wires auth").

This document does **not** define real authentication, account creation, or session management. See `docs/architecture/authentication-future-roadmap.md` for what is deferred.

---

# Goals

The Authentication feature should allow users to:

- See a branded Splash screen on direct navigation to `/`, which advances to Onboarding
- See a short, three-page Onboarding introduction to Qaddy's core features, which advances to Login
- See a Login screen that can switch between "Sign In" and "Create Account" modes
- Reach Dashboard from Login, regardless of what (if anything) was typed

---

# Scope

This feature includes:

- Three screens: Splash (`/`), Onboarding (`/onboarding`), Login (`/login`)
- A one-way navigation chain between them, ending at Dashboard
- Reused form fields (`QaddyTextField`, `QaddyPasswordField`) built in Sprint 1.3 specifically for this feature
- Three new onboarding copy entries (headline + description + icon) — the only new placeholder content this feature introduces

This feature does **not** include:

- Real Supabase authentication, account creation, or session persistence
- Making Splash/Onboarding/Login the app's actual boot sequence — `initialLocation` stays `AppRoutes.home`; this was an explicit product decision (see Engineering Decisions) made to keep this feature's blast radius to zero existing tests, since there is no real session to gate on yet
- Field validation beyond what `QaddyTextField`/`QaddyPasswordField` already render visually (no real email-format checking, no password-strength rules)
- "Forgot Password," social sign-in (Google/Apple), biometrics, or "remember me"
- First-launch-only logic for Onboarding (no persistence exists yet to know what "first launch" means) — Onboarding is simply a reachable route, not a one-time gate
- Any change to the placeholder user — Profile's "Tiamana" remains the shared placeholder subject regardless of what is "signed in" with

See `docs/architecture/authentication-future-roadmap.md` for what is deferred.

---

# Feature Flow

Splash (`/`)

↓ (after a short delay)

Onboarding (`/onboarding`)

↓ (Skip, or Next on the last page)

Login (`/login`)

↓ (Sign In or Create Account)

Dashboard (`/home`)

Every step uses `context.go`, not `context.push` — this is a one-way introduction flow, not a stack the user is expected to navigate back through (see Engineering Decisions).

---

# Integration Objectives

Authentication introduces no new identity data and must never restate or replace Profile's placeholder user. It reuses the exact `QaddyFullScreenLoader` wordmark treatment Sprint 1.3 built for this purpose, and the exact `QaddyTextField`/`QaddyPasswordField` components Sprint 1.3 built "for future authentication screens" (per `sprint-01-3-shared-components.md`'s own Engineering Decision).

---

# Navigation Flow

## Splash

Displays `QaddyFullScreenLoader` with a generic loading message. After a short, fixed delay, navigates to Onboarding automatically. No user interaction is required or possible.

---

## Onboarding

Displays three pages in a `PageView`, each introducing one existing Release 1 feature (Rounds, Friends, Trips — see Engineering Decisions for why these three), with a dot page indicator.

A "Skip" action (top-right, `QaddyTertiaryButton`) is available on every page and goes straight to Login. The last page's primary button reads "Get Started" instead of "Next" and also goes to Login.

---

## Login

Displays the Qaddy wordmark, a Sign In / Create Account mode toggle, and the fields for the current mode:

- Sign In: Email, Password
- Create Account: Full Name, Email, Password

Selecting the primary button (its label matches the current mode) navigates straight to Dashboard. No credentials are validated or stored.

---

# Route Integration

Splash, Onboarding and Login are top-level routes, siblings of the existing bottom-navigation shell — not nested under any tab, per `navigation.md`'s existing "Public Routes" table.

| Route | Screen |
|---------|---------|
| / | Splash |
| /onboarding | Onboarding |
| /login | Login |

`AppRoutes.home` remains the router's `initialLocation`. No existing route, test, or navigation flow changes.

---

# Shared Placeholder Data

Authentication introduces exactly one new piece of placeholder content: three onboarding page entries (headline, description, icon), each describing an existing Release 1 feature rather than an invented one. No user, credential, or account data is introduced — see `authentication-data-model.md`.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- `QaddyFullScreenLoader` (Splash)
- `QaddyTextField`, `QaddyPasswordField` (Login)
- `QaddyPrimaryButton`, `QaddySecondaryButton`, `QaddyTertiaryButton`
- `QaddyScaffold`

Create new widgets only when functionality does not already exist — a small, Onboarding-only page-indicator (dots) and a `_OnboardingPage` presentation record are added locally, since no shared carousel/page-indicator component exists yet anywhere in the app.

---

# Model Reuse

Authentication adds no model that any other feature could need. It does not read from, or need to read from, any other feature's placeholder data — it is the one Release 1 feature with no cross-feature dependency in either direction, because it sits entirely outside the identity model it will eventually replace.

---

# Button Behaviour

| Button | Action |
|---------|---------|
| (automatic, Splash) | Navigate to Onboarding after a short delay |
| Skip (Onboarding) | Navigate to Login |
| Next (Onboarding, pages 1–2) | Advance to the next page |
| Get Started (Onboarding, page 3) | Navigate to Login |
| Sign In / Create Account (Login) | Navigate to Dashboard — visual only, no backend |
| Mode toggle (Login) | Switch between Sign In and Create Account fields |

---

# Placeholder State

Authentication holds no state beyond the current Onboarding page index and the current Login mode, both reset on every visit since nothing is persisted.

No backend session, token, or account exists during this feature's implementation.

---

# Acceptance Criteria

The Authentication feature is complete when a user who navigates to `/` can:

- See Splash, then automatically reach Onboarding
- Page through all three Onboarding screens, or skip them
- Reach Login from either path
- Switch between Sign In and Create Account, seeing the correct fields for each
- Reach Dashboard from Login

Additionally:

- `AppRoutes.home` remains the app's `initialLocation` — no existing test changes
- Existing widgets (especially the Sprint 1.3 form fields built for this feature) are reused, not recreated
- All tests pass
- No placeholder user or cross-feature data is introduced or altered

---

# Future Integration

Future releases will replace placeholder functionality with:

- Real Supabase authentication (sign up, sign in, session persistence) once a project is provisioned — see `lib/core/config/app_config.dart`'s `isBackendConfigured`
- Making this flow the app's actual boot sequence, gated on a real session
- Replacing Profile's "Tiamana" placeholder with the authenticated user's real data
- First-launch-only Onboarding, once local persistence exists
- Forgot Password, social sign-in, biometrics

See `docs/architecture/authentication-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Authentication functionality into one complete feature.
