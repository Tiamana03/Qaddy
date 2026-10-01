# Authentication Feature Integration

## Overview

This document defines how the complete Authentication feature (Release 1 Feature 11 / Sprint 12) is integrated within Qaddy.

Authentication is four visual-only screens — Splash, Onboarding, Login and Sign Up — reachable as real, working routes. They are not wired into the app's boot sequence and do not gate access to anything, because there is no real session to gate on yet: `lib/main.dart` already defers real Supabase authentication to a future milestone (`isBackendConfigured` is false until a Supabase project is provisioned; see its own comment, "features that need a live backend simply aren't reachable until M2 wires auth"). These screens will become the real authentication flow during Release 2, when Supabase authentication is implemented — until then, they are fully navigable placeholders.

This document does **not** define real authentication, account creation, or session management. See `docs/architecture/authentication-future-roadmap.md` for what is deferred.

---

# Goals

The Authentication feature should allow users to:

- See a branded Splash screen on direct navigation to `/`, which advances to Onboarding
- See a short, three-page Onboarding introduction to Qaddy's core features, which advances to Login
- See a Login screen with Sign In fields, with a link to Sign Up
- See a separate Sign Up screen with Create Account fields, with a link back to Login
- Reach Dashboard from either Login or Sign Up, regardless of what (if anything) was typed

---

# Scope

This feature includes:

- Four screens: Splash (`/`), Onboarding (`/onboarding`), Login (`/login`), Sign Up (`/signup`)
- A one-way navigation chain from Splash through Onboarding to Login, with a two-way link between Login and Sign Up, both ending at Dashboard
- Reused form fields (`QaddyTextField`, `QaddyPasswordField`) built in Sprint 1.3 specifically for this feature
- A shared `AuthHeader` widget (Qaddy wordmark + subtitle) reused by both Login and Sign Up
- Three new onboarding copy entries (headline + description + icon) — the only new placeholder content this feature introduces

This feature does **not** include:

- Real Supabase authentication, account creation, or session persistence
- Making Splash/Onboarding/Login/Sign Up the app's actual boot sequence — `initialLocation` stays `AppRoutes.home`; this was an explicit product decision (see Engineering Decisions) made to keep this feature's blast radius to zero existing tests, since there is no real session to gate on yet
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

↓ (Skip, or Get Started on the last page)

Login (`/login`) ←→ Sign Up (`/signup`)

↓ (Sign In, or Create Account)

Dashboard (`/home`)

Every step uses `context.go`, not `context.push` — this is a one-way introduction flow with no back stack worth preserving, including the Login/Sign Up link itself (see Engineering Decisions).

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

Displays the shared `AuthHeader`, an Email field, a Password field, a "Sign In" primary button, and a "Don't have an account? Sign Up" link to Sign Up.

---

## Sign Up

Displays the shared `AuthHeader`, a Full Name field, an Email field, a Password field, a "Create Account" primary button, and an "Already have an account? Sign In" link back to Login.

---

# Route Integration

Splash, Onboarding, Login and Sign Up are top-level routes, siblings of the existing bottom-navigation shell — not nested under any tab, per `navigation.md`'s existing "Public Routes" table.

| Route | Screen |
|---------|---------|
| / | Splash |
| /onboarding | Onboarding |
| /login | Login |
| /signup | Sign Up |

`AppRoutes.home` remains the router's `initialLocation`. No existing route, test, or navigation flow changes.

---

# Shared Placeholder Data

Authentication introduces exactly one new piece of placeholder content: three onboarding page entries (headline, description, icon), each describing an existing Release 1 feature rather than an invented one. No user, credential, or account data is introduced — see `authentication-data-model.md`.

---

# Widget Reuse

Existing widgets should always be reused before creating new components.

Reuse:

- `QaddyFullScreenLoader` (Splash)
- `QaddyTextField`, `QaddyPasswordField` (Login, Sign Up)
- `QaddyPrimaryButton`, `QaddyTertiaryButton`
- `QaddyScaffold`

Create new widgets only when functionality does not already exist:

- A small, Onboarding-only page-indicator (dots), since no shared carousel/page-indicator component exists yet anywhere in the app
- `AuthHeader` (`lib/features/authentication/ui/widgets/auth_header.dart`) — the Qaddy wordmark + subtitle treatment shared by Login and Sign Up, extracted so it is written once rather than duplicated across the two screens that need it

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
| Sign In (Login) | Navigate to Dashboard — visual only, no backend |
| Don't have an account? Sign Up (Login) | Navigate to Sign Up |
| Create Account (Sign Up) | Navigate to Dashboard — visual only, no backend |
| Already have an account? Sign In (Sign Up) | Navigate to Login |

---

# Placeholder State

Authentication holds no state beyond the current Onboarding page index, reset on every visit since nothing is persisted.

No backend session, token, or account exists during this feature's implementation.

---

# Acceptance Criteria

The Authentication feature is complete when a user who navigates to `/` can:

- See Splash, then automatically reach Onboarding
- Page through all three Onboarding screens, or skip them
- Reach Login from either path
- Navigate from Login to Sign Up and back
- Reach Dashboard from either Login or Sign Up

Additionally:

- `AppRoutes.home` remains the app's `initialLocation` — no existing test changes
- Existing widgets (especially the Sprint 1.3 form fields built for this feature) are reused, not recreated
- All tests pass
- No placeholder user or cross-feature data is introduced or altered

---

# Future Integration

Future releases will replace placeholder functionality with:

- Real Supabase authentication (sign up, sign in, session persistence) once a project is provisioned — see `lib/core/config/app_config.dart`'s `isBackendConfigured`. This is explicitly planned for Release 2.
- Making this flow the app's actual boot sequence, gated on a real session
- Replacing Profile's "Tiamana" placeholder with the authenticated user's real data
- First-launch-only Onboarding, once local persistence exists
- Forgot Password, social sign-in, biometrics

See `docs/architecture/authentication-future-roadmap.md` for detail on each.

This document should remain focused solely on integrating the existing Authentication functionality into one complete feature.
