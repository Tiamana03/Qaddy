# Qaddy Navigation Architecture

**Version:** 2.0

**Status:** Active

**Source:** Product Architecture

**Last Updated:** September 2026

---

# Purpose

This document defines the complete navigation architecture for Qaddy.

It is the single source of truth for:

- Application routes
- Navigation hierarchy
- Bottom navigation
- Feature navigation
- Route ownership
- Future expansion

No implementation may invent routes or navigation behaviour outside this document.

---

# Navigation Principles

## Simple

Navigation should always be predictable.

Users should always know where they are.

---

## Consistent

Every feature should behave consistently throughout the application.

---

## Fast

Core features should always be accessible within three taps.

---

## Scalable

Every feature should support future expansion without requiring major restructuring.

---

# Three Click Rule

Any major feature must be reachable within three user interactions from the Home Dashboard (excluding authentication).

---

# Bottom Navigation

Release 1 contains five primary destinations.

| Tab | Route | Purpose |
|------|-------|----------|
| Home | /home | Dashboard |
| Rounds | /rounds | Rounds & Live Scoring |
| Trips | /trips | Golf Trips |
| Friends | /friends | Friends & Community |
| Profile | /profile | User Profile |

Each destination owns its own independent navigation stack.

Navigation history must be preserved when switching tabs.

---

# Route Hierarchy

## Public Routes

| Route | Purpose |
|--------|----------|
| / | Splash Screen |
| /onboarding | First Launch |
| /login | Authentication |
| /signup | Create Account |

### Navigation Flow

```
Splash
    │ (automatic, after a short delay)
    ▼
Onboarding
    │ (Skip, or Get Started on the last page)
    ▼
Login ───────── Sign Up
    │  (Sign Up)   │  (Sign In, back to Login)
    ▼              ▼
         Dashboard
```

Every step uses `go`, not `push` — see `docs/architecture/authentication-engineering-decisions.md`'s "Navigation Uses `go`, Not `push`." These four screens are real, working routes, but — unlike every other destination in this document — nothing currently shipped links to them, and `AppRoutes.home` remains the router's `initialLocation`; seeing them requires navigating to `/` directly. See `docs/features/authentication-feature-integration.md` and `authentication-engineering-decisions.md`'s "This Flow Is Not the App's Boot Sequence" for why.

---

## Home

| Route | Screen |
|--------|--------|
| /home | Dashboard |
| /home/notifications | Notifications |
| /home/search | Search |

Selecting the notification bell on Dashboard's app bar opens Notifications — see `docs/features/notifications-feature-integration.md`. Selecting the search icon, to the bell's left, opens Search — see `docs/features/search-feature-integration.md`.

---

## Rounds

| Route | Screen |
|--------|--------|
| /rounds | Rounds Home |
| /rounds/setup | Round Setup |
| /rounds/live | Live Scorecard |
| /rounds/leaderboard | Leaderboard |
| /rounds/complete | Round Complete |

### Navigation Flow

```
Rounds
    │
    ▼
Round Setup
    │
    ▼
Live Scorecard
    │
    ▼
Leaderboard
    │
    ▼
Round Complete
```

---

## Trips

| Route | Screen |
|--------|--------|
| /trips | Trips Home |
| /trips/details | Trip Details |
| /trips/planning | Trip Planning |
| /trips/travel | Travel |
| /trips/accommodation | Accommodation |
| /trips/golf | Golf Schedule |
| /trips/expenses | Expenses |
| /trips/chat | Trip Chat |
| /trips/complete | Trip Complete |

### Navigation Structure

```
Trips
    │
    ▼
Trip Details
    ├── Planning
    ├── Travel
    ├── Accommodation
    ├── Golf Schedule
    ├── Expenses
    ├── Chat
    └── Trip Complete
```

Trip Details is the central hub for every trip.

Users may return to Trip Details from any child screen.

Buttons linking to implemented screens must never remain disabled.

---

## Friends

| Route | Screen |
|--------|--------|
| /friends | Friends Home |
| /friends/list | Friends List |
| /friends/profile | Friend Profile |
| /friends/activity | Activity Feed |
| /friends/requests | Friend Requests |
| /friends/search | Search Friends |
| /friends/groups | Groups |
| /friends/groups/details | Group Details |
| /friends/rivalries | Rivalries |

### Navigation Structure

```
Friends
    │
    ▼
Friends Home
    ├── Friends List
    │       └── Friend Profile
    ├── Activity Feed
    ├── Friend Requests
    ├── Search Friends
    ├── Groups
    │       └── Group Details
    └── Rivalries
```

Activity Feed and Rivalries are reachable directly from Friends Home, satisfying the Three Click Rule (Dashboard → Friends tab → Friends Home → Activity Feed/Rivalries is 2 taps). Friend Profile also links to both as a convenience, since they are contextually about one friend, but that is a secondary path — not the only one.

Friends Home is the central hub for the feature.

Users may return to Friends Home from any child screen.

Buttons linking to implemented screens must never remain disabled.

Future releases will expand Friends further into:

- Clubhouse
- Community Feed

---

## Profile

| Route | Screen |
|--------|--------|
| /profile | Profile |
| /profile/statistics | Statistics |
| /profile/bag | Golf Bag |
| /profile/settings | Settings |

Release 1's Profile is a single, aggregated screen with three nested destinations — see `docs/features/profile-feature-integration.md`, `docs/features/statistics-feature-integration.md`, `docs/features/golf-bag-feature-integration.md` and `docs/features/settings-feature-integration.md`. Selecting "View Statistics," "View Golf Bag" or "View Settings" on Profile opens the respective screen; there is no further Profile sub-navigation yet.

Future releases will expand Profile into:

- Achievements
- Premium

---

# Navigation Shell

Qaddy uses a persistent Bottom Navigation Bar.

Each primary destination owns its own navigation stack.

Navigation state must be preserved while switching tabs.

---

# Routing

Routing uses:

- GoRouter
- StatefulShellRoute
- Named Routes
- Route Constants

Route strings must never be hardcoded outside the router.

Business logic must never exist inside routing configuration.

---

# Deep Linking

The architecture supports deep linking.

Deep linking is not implemented during Release 1.

---

# Flutter Implementation Notes

Navigation should be implemented using:

- GoRouter
- StatefulShellRoute
- BottomNavigationBar
- Named Routes
- Route Constants

Every feature owns its own nested routes beneath its root route.

Example:

```
/trips
    /details
    /planning
    /travel
```

---

# Engineering Decisions

## Bottom Navigation

Five tabs represent the highest-frequency user journeys.

Future features should extend existing tabs rather than creating additional bottom navigation destinations.

---

## Navigation State

Each feature maintains its own navigation history.

Changing tabs must never reset another feature's navigation stack.

---

## Route Names vs Feature Folders

Navigation route names are part of the public interface.

Feature folders are internal implementation details.

| Route | Feature Folder |
|--------|----------------|
| /home | dashboard |
| /rounds | rounds |
| /trips | trips |
| /friends | community |
| /profile | profile |
| /profile/bag | my_bag |

Developers must not rename feature folders solely to match navigation routes.

---

# Future Expansion

Future routes may include:

- Golf IQ
- Practice
- Clubhouse
- Marketplace
- Booking
- Premium
- Referral System

Statistics and Notifications were both in this list previously and are now implemented — see `docs/features/statistics-feature-integration.md` and `docs/features/notifications-feature-integration.md`. Golf Bag, Settings and Search were never in this list; each was added directly to its own route table above — see `docs/features/golf-bag-feature-integration.md`, `docs/features/settings-feature-integration.md` and `docs/features/search-feature-integration.md`.

These should extend the existing navigation hierarchy rather than replacing it.

---

# Related Documents

- round-data-model.md
- trip-data-model.md
- friend-data-model.md
- group-data-model.md
- profile-data-model.md
- statistics-data-model.md
- golf-bag-data-model.md
- notifications-data-model.md
- settings-data-model.md
- search-data-model.md
- authentication-data-model.md
- trips-feature-integration.md
- rounds-feature-integration.md
- friends-feature-integration.md
- profile-feature-integration.md
- statistics-feature-integration.md
- golf-bag-feature-integration.md
- notifications-feature-integration.md
- settings-feature-integration.md
- search-feature-integration.md
- authentication-feature-integration.md

---

**End of Document**