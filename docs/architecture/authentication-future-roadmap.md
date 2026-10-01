# Authentication Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Authentication feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them, and most explicitly depend on `lib/core/config/app_config.dart`'s `isBackendConfigured` becoming true — i.e. a real Supabase project being provisioned (`lib/core/config/env/README.md` calls this milestone "M0").

---

## Real Supabase Authentication

Actual sign up, sign in, and session management via `supabase_flutter`, already a project dependency (`lib/main.dart` already calls `Supabase.initialize` when configured).

Depends on a provisioned Supabase project.

---

## Authentication as the App's Boot Sequence

Changing `app_router.dart`'s `initialLocation` so every launch is actually gated on a real session — unauthenticated users land on Splash/Onboarding/Login, authenticated users land on Dashboard.

Depends on Real Supabase Authentication existing first — see `authentication-engineering-decisions.md`'s "This Flow Is Not the App's Boot Sequence."

---

## Replacing the Placeholder User

Profile's "Tiamana," used as the shared placeholder subject throughout every Release 1 feature, is replaced by the authenticated user's real profile data.

This is the largest single change any future release will make — every feature that reads Profile's placeholder constants (see `docs/architecture/data-ownership.md`'s dependency graph) is affected.

---

## First-Launch-Only Onboarding

Showing Onboarding exactly once per install, using local persistence (e.g. `shared_preferences`) to remember it has been seen.

Depends on a persistence package being added — not yet a project dependency.

---

## Forgot Password

A password-reset flow, depending on Supabase Auth's own reset-email mechanism.

---

## Social Sign-In

Google and Apple sign-in, depending on platform-specific OAuth configuration.

---

## Biometric Sign-In

Face ID / fingerprint unlock for returning users, depending on a real session existing to unlock.

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `authentication-data-model.md` — a Purpose section, a data model table (a real `User`/`Account` model, at that point), business rules, and a Do Not Build / Out of Scope section for whatever remains deferred at that time.

---

# Related Documents

- authentication-data-model.md
- authentication-engineering-decisions.md
- docs/features/authentication-feature-integration.md
- lib/core/config/app_config.dart
- lib/core/config/env/README.md

---

**End of Document**
