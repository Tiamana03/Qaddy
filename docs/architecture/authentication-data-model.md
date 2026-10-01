# Authentication Data Model

**Version:** 1.0

**Status:** Architecture Approved

---

# Purpose

This document defines the Authentication feature's data model.

Per `docs/roadmap/release-1-roadmap.md`'s Sprint 12 goal, Authentication would eventually "replace placeholder users with secure authentication, user accounts and onboarding." Release 1 implements only the Onboarding/Login UI shell — no real user account model exists yet, because `lib/main.dart`'s `isBackendConfigured` check confirms no Supabase project is provisioned. See `authentication-engineering-decisions.md`.

No implementation may introduce a real `User`/`Account` model, or persist any credential, without updating this document first.

---

# Overview

Authentication displays:

- Splash — no data, a fixed loading message
- Onboarding — three `OnboardingPage` entries (the only new content this feature introduces)
- Login — a fixed set of empty form fields (Email, Password) with no backing model
- Sign Up — a fixed set of empty form fields (Full Name, Email, Password) with no backing model

---

# OnboardingPage Model

The one new model this feature introduces — a presentation-only record, not user/account data.

| Field | Type | Description |
|--------|------|-------------|
| icon | IconData | The feature being introduced |
| title | String | Short headline |
| description | String | One-sentence supporting copy |

```dart
const onboardingPages = <OnboardingPage>[
  OnboardingPage(
    icon: Icons.sports_golf,
    title: 'Track Every Round',
    description: 'Log your scores, stats and personal bests in one place.',
  ),
  OnboardingPage(
    icon: Icons.groups_outlined,
    title: 'Play With Friends',
    description: 'Organise rounds, trips and rivalries with your golf crew.',
  ),
  OnboardingPage(
    icon: Icons.flight_takeoff,
    title: 'Plan Your Next Trip',
    description: 'Itineraries, accommodation and expenses, all in Qaddy.',
  ),
];
```

These three entries are the only new placeholder content Authentication introduces — see "New Placeholder Content" below for why three, and why these three.

---

# Model Reuse

Authentication reads no other feature's placeholder data, and no other feature reads from it. It is the one Release 1 feature with zero cross-feature dependency — see `docs/architecture/data-ownership.md`.

It does reuse existing shared widgets, not models:

| Source | Reused for |
|---------|-----------|
| `QaddyFullScreenLoader` (`lib/core/widgets/loaders/`) | Splash's logo/loading treatment |
| `QaddyTextField`, `QaddyPasswordField` (`lib/core/widgets/forms/`) | Login's and Sign Up's fields — built in Sprint 1.3 "for future authentication screens" |

---

# New Placeholder Content

Three `OnboardingPage` entries, one per page. Per `docs/ai/project-rules.md`'s "only introduce new placeholder data where genuinely required," this is new because nothing in the app already has three-feature-introduction marketing copy to reuse — it did not exist before this feature, and no other feature owns anything equivalent.

Each entry introduces an existing, already-implemented Release 1 feature (Rounds, Friends, Trips), not an invented or future one — see `authentication-engineering-decisions.md` for why these three specifically.

---

# Business Rules

- Login's and Sign Up's fields hold no backing model — `TextEditingController`s only, read by nothing, validated by nothing, submitted nowhere.
- Login and Sign Up are two separate screens/routes, not one screen with a mode toggle — each is a complete `StatelessWidget` with no local state of its own.
- Onboarding's current page index is local UI state, reset every time Onboarding is (re)opened.
- Tapping Login's or Sign Up's primary button always navigates to Dashboard. Neither reads field contents, checks for emptiness, nor shows an error state.

---

# Out of Scope (Release 1)

- A real `User`/`Account` model.
- Supabase Auth integration (sign up, sign in, sessions, tokens).
- Persisted Onboarding "seen" state.
- Any validation, error state, or loading state on Login's or Sign Up's submit action.

See `authentication-future-roadmap.md`.

---

# Engineering Decisions

See `docs/architecture/authentication-engineering-decisions.md` for the full reasoning, including why this flow is not the app's boot sequence and why Rounds/Friends/Trips were chosen for Onboarding.

---

# Flutter Implementation Notes

Authentication functionality should remain inside:

```
lib/features/authentication/
```

The only new model type is `OnboardingPage`. No other model, placeholder data, or cross-feature import exists in this feature. `AuthHeader` (`lib/features/authentication/ui/widgets/auth_header.dart`) is a shared widget, not a model — the Qaddy wordmark + subtitle treatment reused by both Login and Sign Up.

---

# Related Documents

- docs/features/authentication-feature-integration.md
- authentication-engineering-decisions.md
- authentication-future-roadmap.md
- navigation.md
- docs/architecture/data-ownership.md
- technical-architecture.md

---

**End of Document**
