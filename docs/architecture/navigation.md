# Qaddy Navigation Architecture

**Version:** 1.1  
**Status:** Active  
**Source:** Product Architecture & Engineering Decisions  
**Last Updated:** September 2026

---

# Purpose

This document defines the navigation architecture for Qaddy.

It is the single source of truth for:

- Application routes
- Navigation hierarchy
- Bottom navigation
- Navigation behaviour
- Future expansion

No developer or AI may invent routes or navigation behaviour outside this document.

---

# Navigation Principles

## Simple

Navigation should always be predictable.

Users should always know where they are.

---

## Consistent

Every feature should behave the same way.

Navigation patterns must remain consistent throughout the application.

---

## Fast

The most commonly used features should always be immediately accessible.

---

## Scalable

The navigation system must support future Qaddy features without requiring major restructuring.

---

# Three Click Rule

Qaddy follows the Three Click Rule.

Any core feature must be reachable from the Home Dashboard in **three taps or fewer** (excluding authentication).

If a feature requires more than three interactions to reach, the navigation architecture should be reviewed before implementation.

This principle guides every future feature added to Qaddy.

---

# Release 1 Navigation

Bottom Navigation contains five primary destinations.

| Tab | Route | Purpose |
|------|-------|---------|
| Home | /home | Dashboard |
| Rounds | /rounds | Current & Previous Rounds |
| Trips | /trips | Golf Trips |
| Friends | /friends | Groups & Social |
| Profile | /profile | User Profile & Settings |

---

# Route Map

## Public Routes

| Route | Purpose |
|--------|----------|
| / | Splash Screen |
| /onboarding | First Launch |
| /login | Authentication |

---

## Authenticated Routes

| Route | Purpose |
|--------|----------|
| /home | Dashboard |
| /rounds | Rounds |
| /trips | Trips |
| /friends | Friends |
| /profile | Profile |

---

# Future Routes

The following destinations are intentionally reserved for future releases.

These are **not** part of Sprint 1.

- Statistics
- Golf IQ
- Practice
- Clubhouse
- Booking
- Marketplace
- Notifications
- Settings
- Premium
- Referral System

Future routes should extend this architecture rather than replace it.

---

# Navigation Shell

Sprint 1 uses a persistent Bottom Navigation Bar.

Each destination owns its own navigation stack.

Navigation state must be preserved when switching between tabs.

---

# Routing

Routing will use:

- GoRouter
- ShellRoute
- Named Routes
- Centralised Route Definitions

Route strings must never be hardcoded outside the router.

---

# Deep Linking

Deep linking is supported by the architecture but is **not** implemented during Sprint 1.

---

# Engineering Decisions

## Bottom Navigation

Five primary tabs were selected because they represent the five highest-frequency user journeys within Qaddy.

Future features should be accessed from these destinations rather than increasing the number of Bottom Navigation items.

---

## Navigation State

Each Bottom Navigation destination maintains its own navigation history.

Switching between tabs must never reset that tab's navigation stack.

---

## Engineering Decision — Bottom Navigation Naming

Early navigation mockups used a **Play** tab.

As Qaddy's product vision evolved, this destination was replaced with **Friends** to better represent the application's long-term social ecosystem.

The Friends destination encompasses:

- Friends
- Groups
- Community
- Clubhouse
- Rivalries
- Social Activity

This Engineering Decision supersedes earlier navigation mockups and becomes the official Release 1 navigation standard.

Future implementations must use **Friends** as the primary destination unless this document is updated.

---

# Flutter Implementation

Navigation will be implemented using:

- GoRouter
- ShellRoute
- BottomNavigationBar
- Named Routes
- Route Constants

The router is responsible only for navigation.

Business logic must never exist inside routing configuration.

---

# Token References

Navigation UI must use the following design tokens:

- colours.md
- typography.md
- spacing.md
- radius.md
- animations.md

Navigation styling must never be hardcoded.

---

# Future Expansion

Future features should extend this architecture rather than replacing it.

Any change to the navigation hierarchy must be documented and approved before implementation begins.
## Engineering Decision — Route Names vs Feature Folders

Navigation route names are part of the public application interface.

Feature folder names are internal implementation details.

The two do not need to match.

| Route | Feature Folder |
|--------|----------------|
| /home | dashboard |
| /rounds | rounds |
| /trips | trips |
| /friends | community |
| /profile | profile |

This allows the public navigation structure to evolve without unnecessary refactoring of the underlying project architecture.

Developers must not rename or duplicate feature folders solely to match route names.

The existing project scaffold remains the source of truth for feature folder names unless this document is updated.