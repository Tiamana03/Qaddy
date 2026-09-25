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

---

## Home

| Route | Screen |
|--------|--------|
| /home | Dashboard |

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

Future releases will expand Friends into:

- Groups
- Clubhouse
- Rivalries
- Community Feed

---

## Profile

| Route | Screen |
|--------|--------|
| /profile | Profile |

Future releases will expand Profile into:

- Statistics
- Achievements
- Settings
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

Developers must not rename feature folders solely to match navigation routes.

---

# Future Expansion

Future routes may include:

- Statistics
- Golf IQ
- Practice
- Clubhouse
- Marketplace
- Notifications
- Booking
- Premium
- Referral System

These should extend the existing navigation hierarchy rather than replacing it.

---

# Related Documents

- round-data-model.md
- trip-data-model.md
- trips-feature-integration.md
- rounds-feature-integration.md

---

**End of Document**