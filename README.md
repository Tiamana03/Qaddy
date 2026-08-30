# Qaddy

Qaddy is the golfer's ecosystem — rounds, golf bag, trips, Golf IQ,
achievements and memories, in one place. See the Qaddy Build Package
(Founder's Blueprint, Design System, Technical Architecture Blueprint,
Claude Build Package, Visual Design Library) for the product vision and
engineering standards this repo is built against.

## Status

Milestone 0 (Foundations & Tooling) of the Release One roadmap — the
feature-first scaffold, CI, lint standards, and crash/analytics wiring.
No feature screens exist yet; those land starting Milestone 2.

## Stack

- **Flutter** (Dart ^3.12.2), targeting iOS and Android
- **Supabase** — auth, Postgres, storage, realtime, edge functions
- **Riverpod** for state management and dependency injection
- **go_router** for navigation
- **Sentry** for crash reporting, **PostHog** for product analytics
  (analytics ships as a no-op binding until a launch-geography decision is made)

## Architecture

Feature-first, per the Technical Architecture Blueprint:

```
lib/
  core/            # shared design system, services, config, routing, utils
  features/
    authentication/
    dashboard/
    rounds/
    golf_bag/
    trips/
    statistics/
    achievements/
    golf_iq/
    community/
    profile/
    settings/
```

Each feature owns its own `ui/`, `models/`, `repositories/`, `services/`,
and `logic/` (Riverpod notifiers). External providers (course data, crash
reporting, analytics, and eventually payments/maps/weather) are always
accessed through an interface in `repositories/` or `core/services/` —
never a vendor SDK directly — so any provider can be swapped without
touching feature code. `core/design_system/` is intentionally near-empty
right now; it's built out in Milestone 1.

Tests mirror `lib/`'s structure under `test/`.

## Getting started

```
flutter pub get
cp lib/core/config/env/dev.json.example lib/core/config/env/dev.json
# fill in real values in dev.json once a Supabase project + Sentry/PostHog
# projects exist — the app boots fine with them left empty in the meantime
flutter run --dart-define-from-file=lib/core/config/env/dev.json
```

## Checks

```
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

All three run in CI (`.github/workflows/ci.yaml`) on every pull request.
