# App Architecture

---

# Purpose

This document defines the overall architecture of the Qaddy application.

It serves as the single source of truth for how the application is structured, how features interact, and how new functionality should be implemented.

Every feature, sprint, and engineering decision should align with this architecture.

---

# Architecture Philosophy

Qaddy follows a feature-first architecture.

Each feature is isolated into its own module while sharing a common design system, reusable widgets, services, and utilities.

The architecture prioritises:

- Scalability
- Maintainability
- Reusability
- Testability
- Consistency
- Clean separation of concerns

The goal is to allow the application to continue growing without becoming difficult to maintain.

---

# High Level Structure

```
lib/

core/
    theme/
    widgets/
    services/
    models/
    utils/
    extensions/

features/

    authentication/

    dashboard/

    rounds/

    trips/

    friends/

    groups/

    statistics/

    profile/

main.dart
```

---

# Core Layer

The Core layer contains reusable functionality shared across the entire application.

Examples include:

- Theme
- Colours
- Typography
- Shared Widgets
- Buttons
- Cards
- Dialogs
- Utilities
- Extensions
- Services

Nothing inside Core should depend on an individual feature.

Features depend on Core.

Core never depends on Features.

---

# Feature Modules

Each major area of Qaddy is built as an independent feature.

Examples:

- Dashboard
- Rounds
- Trips
- Friends
- Groups
- Statistics
- Profile

Each feature owns:

- Screens
- Widgets
- Models
- Controllers
- State
- Tests

Feature code should remain inside its own folder whenever possible.

---

# Design System

Every screen must use the shared Qaddy Design System.

This includes:

- Colours
- Typography
- Spacing
- Radius
- Shadows
- Icons
- Shared Cards
- Shared Buttons
- Shared Layout Components

No feature should create duplicate design components.

---

# Data Architecture

The application uses dedicated data models for each major domain.

Current models include:

- Round Data Model
- Trip Data Model
- Friend Data Model
- Group Data Model
- Profile Data Model

Each model is documented separately inside:

docs/architecture/

No sprint may introduce new data structures without first updating the relevant architecture document.

---

# Navigation

Navigation follows the documented application flow defined in:

navigation.md

Screens should never invent new navigation routes without first updating the navigation documentation.

---

# Responsive Design

Every screen must support:

- Mobile
- Tablet
- Desktop

Layouts should adapt using the documented responsive design rules.

No screen should be designed solely for one device size.

---

# State Management

Application state should remain local whenever possible.

Shared state should only be introduced when genuinely required.

Features should avoid unnecessary coupling.

Business logic should remain separate from UI components.

---

# Shared Components

Reusable widgets should live inside:

```
lib/core/widgets/
```

Examples:

- Buttons
- Cards
- Avatars
- Badges
- Dialogs
- Loading Indicators
- Empty States
- Statistics Cards

A widget should only become feature-specific when it cannot reasonably be reused elsewhere.

---

# Feature Independence

Every feature should be capable of evolving independently.

For example:

Dashboard should not directly depend on Trips.

Trips should not directly depend on Friends.

Instead, features communicate through shared models and services.

This keeps the architecture modular and easier to maintain.

---

# Testing Strategy

Every feature should include:

- Widget Tests
- Unit Tests (where appropriate)

Shared widgets should have their own dedicated tests.

Regression testing should accompany new functionality.

---

# Documentation Rules

Before implementation:

- Architecture must exist.
- Standards must exist.
- Sprint documentation must exist.

Implementation follows documentation.

Documentation does not follow implementation.

---

# Engineering Principles

Qaddy follows these principles:

- Build once, reuse everywhere.
- Keep features modular.
- Prefer composition over duplication.
- Never invent undocumented behaviour.
- Maintain consistent UI patterns.
- Prioritise readability over cleverness.
- Optimise for long-term maintainability.

---

# Future Architecture

As Qaddy grows, additional architectural areas may include:

- Offline Support
- Cloud Synchronisation
- Notifications
- AI Services
- Analytics
- Booking Integrations
- Payment Services
- Wearables
- Watch Applications
- Desktop Optimisations

This document should evolve as the application grows while remaining the highest-level architectural reference for the entire project.