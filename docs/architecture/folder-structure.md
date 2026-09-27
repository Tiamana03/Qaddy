# Folder Structure

---

# Purpose

This document defines the official folder structure for the Qaddy application.

It exists to ensure the project remains organised, scalable, and easy to navigate as new features are added.

Every contributor should follow this structure.

No feature should introduce new folders unless the architecture requires it.

---

# Repository Structure

```
Qaddy/

android/
assets/
design/
docs/
ios/
lib/
linux/
macos/
test/
web/
windows/

pubspec.yaml
README.md
CLAUDE.md
```

---

# Assets

```
assets/

fonts/
icons/
images/
logos/
animations/
```

Assets should only contain files used by the application.

No documentation belongs here.

---

# Design

```
design/

assets/
design-tokens/
mockups/
ui-components/
```

Purpose:

- UI mockups
- Design references
- Colour system
- Typography
- Spacing
- Radius
- Icons
- Component library

The design folder is not used by Flutter directly.

It exists for designers and AI implementation.

---

# Documentation

```
docs/

ai/
architecture/
decisions/
prompts/
roadmap/
sprints/
standards/
```

---

## AI

Contains prompts and implementation workflows.

Examples:

- implementation-workflow.md
- project-rules.md

---

## Architecture

Defines how the application is built.

Examples:

- app-architecture.md
- navigation.md
- round-data-model.md
- trip-data-model.md

No implementation should contradict these documents.

---

## Decisions

Records important engineering and product decisions.

Purpose:

- Why something changed.
- Alternatives considered.
- Future reference.

---

## Prompts

Contains reusable prompts for AI-assisted development.

Examples:

- Sprint implementation prompts.
- Review prompts.
- Planning prompts.

---

## Roadmap

High-level planning documentation.

Examples:

- Milestones
- Future features
- Release plans

---

## Sprints

Detailed sprint specifications.

Each sprint should contain:

- Objectives
- Scope
- Requirements
- Acceptance Criteria
- References
- Do Not Build section

---

## Standards

Defines placeholder data, coding standards, naming conventions, and reusable project standards.

Examples:

- Placeholder data
- Flutter style guide
- Development principles
- Git workflow

---

# Flutter Source Code

```
lib/

core/
features/

main.dart
```

---

# Core

The Core directory contains reusable functionality shared across the application.

```
core/

theme/
widgets/
services/
models/
utils/
extensions/
```

Core must never depend on a feature.

---

## Theme

Contains:

- Colours
- Typography
- Radius
- Spacing
- ThemeData
- Shadows

---

## Widgets

Contains reusable widgets.

Examples:

```
buttons/
cards/
badges/
avatars/
dialogs/
navigation/
loading/
```

If a widget can be reused by multiple features, it belongs here.

---

## Services

Contains shared services.

Examples:

- Authentication
- Storage
- API
- Analytics
- Notifications

---

## Models

Contains shared models used across multiple features.

Feature-specific models should remain inside their own feature folder.

---

## Utilities

General helper functions.

Examples:

- Date formatting
- Number formatting
- String helpers

---

## Extensions

Contains Dart extension methods.

Examples:

- BuildContext extensions
- DateTime extensions
- String extensions

---

# Features

```
features/

authentication/
dashboard/
rounds/
trips/
friends/
groups/
statistics/
profile/
settings/
```

Each feature owns its own code.

---

## Standard Feature Layout

```
feature/

ui/
    screens/
    widgets/

models/

controllers/

services/

repositories/

state/

tests/
```

Not every feature requires every folder.

Folders should only be created when needed.

---

# Tests

```
test/

core/
features/
```

Tests should mirror the structure inside lib/.

Example:

```
lib/features/trips/ui/widgets/trip_card.dart

↓

test/features/trips/ui/widgets/trip_card_test.dart
```

---

# Naming Conventions

Folders

snake_case

Example

```
trip_details
player_card
```

Files

snake_case

Example

```
trip_card.dart
trip_details_screen.dart
round_service.dart
```

Classes

PascalCase

```
TripCard
RoundsScreen
FriendProfile
```

Variables

camelCase

```
tripName
playerCount
roundStatus
```

Constants

camelCase or static const depending on context.

---

# Where New Files Should Go

Before creating a file ask:

1. Is it reusable?

→ Core

2. Is it feature-specific?

→ Feature folder

3. Is it documentation?

→ Docs

4. Is it design?

→ Design

Avoid creating duplicate functionality.

---

# Folder Rules

- Keep related files together.
- Avoid deep nesting where unnecessary.
- Prefer feature ownership.
- Reuse before creating.
- Follow existing patterns.
- Keep documentation alongside architecture.

---

# Future Growth

As Qaddy expands, new feature folders may include:

- Shop
- Marketplace
- Coaching
- AI
- Events
- Clubs
- Courses
- Social Feed
- Tournaments

The folder structure should evolve carefully while preserving consistency and discoverability across the project.