# Qaddy

Qaddy is an all-in-one golf platform designed to connect every round. It
combines live scoring, golf trips, groups, statistics, golf bag management,
Golf IQ, achievements and course information into a single premium mobile
experience.

Built with **Flutter**, **Riverpod**, **Supabase** and a **feature-first
architecture**. The product vision and engineering standards live in
[`docs/`](docs/README.md) (start with `docs/CLAUDE.md`).

## Project Vision

**Every Round. Connected.**

Qaddy aims to become the operating system for golfers, bringing rounds, trips,
friends, statistics, golf bag management, live scoring and course information
together in one premium experience.

## Current Status

Qaddy is currently in **Release Candidate** development.

**Completed areas**

- Dashboard / Home
- Live Scoring
- Rounds
- Groups
- Friends
- Trips
- Golf Bag
- Statistics
- Profile
- Search
- Course architecture
- Design system
- Feature-first architecture

**Current focus**

- GolfCore course integration
- Live course data
- Developer tooling ([qaddy-devtools](#related-repository))
- Production hardening
- Launch preparation

Today the app is local-first: golfer data is stored on the device, and a
clearly labelled Sample Clubhouse (sample mates, group, trip and course) lets a
new golfer see what Qaddy does. The course architecture is provider-independent,
and GolfCore integration is the current implementation priority before launch;
until it lands, course details, hole pictures, GPS and weather show an honest
"not available" state rather than invented data. Supabase is initialised when
configured and is the planned home for synced app data. The Golf IQ module
structure is in place and will be built out in future milestones.

## Stack

- **Flutter** (Dart ^3.12.2), targeting iOS and Android
- **Riverpod** for state management and dependency injection
- **go_router** for navigation
- **Supabase** for auth, Postgres, storage, realtime and edge functions
- **Sentry** for crash reporting, **PostHog** for product analytics
  (analytics ships as a no-op binding until a launch-geography decision is made)

## Architecture

Feature-first, per the Technical Architecture Blueprint:

```
lib/
  core/            # design system, services, config, routing, responsive, utils
  features/
    authentication/  community/ (Friends)  dashboard/   groups/
    rounds/          courses/              trips/       my_bag/ (Golf Bag)
    statistics/      achievements/         profile/     search/
    notifications/   settings/             golf_iq/
```

- **Every feature owns its own state**: Riverpod notifiers and providers live
  in the feature, alongside its `ui/`, `models/`, `repositories/`, `services/`
  and `logic/`. Business logic stays out of widgets.
- **External providers are accessed through interfaces**, never a vendor SDK
  directly (course data, crash reporting, analytics, and eventually
  payments, maps and weather), so a provider can be swapped without touching
  feature code.
- **Course data is provider-independent.** `features/courses/` defines Qaddy's
  own course, hole and tee models and four source interfaces (catalogue, hole
  media, GPS distances, weather). Screens read only those; each interface has
  an "unavailable" default. **GolfCore is the initial provider
  implementation** and is wired in by changing the providers in
  `features/courses/state/course_providers.dart`, with no screen changes. See
  [`docs/architecture/course-data.md`](docs/architecture/course-data.md).

Tests mirror `lib/`'s structure under `test/`.

## Related repository

`qaddy-devtools` (a separate repository, kept beside this one at
`C:\Developer\qaddy-devtools` on the team's machines) holds the GolfCore integration, course auditing, the import pipeline and the
rest of the developer tooling. This repository holds everything needed to
build and ship the app; see `CLAUDE.md` for the ownership rules.

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

## Roadmap

Current priorities:

- GolfCore integration
- Live course data
- Complete developer tooling
- Performance optimisation
- Production launch
