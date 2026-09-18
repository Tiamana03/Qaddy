# Sprint 1.3 – Shared Components

**Version:** 1.0

**Status:** Draft

**Last Updated:** September 2026

---

# Sprint Goal

Implement the reusable UI components that form the foundation of every Qaddy feature screen.

These components must consume the Theme Extensions and Design Tokens created during Sprint 1.1.

No business logic, API integration, feature functionality or screen-specific behaviour should be implemented during this sprint.

---

# Objectives

Build the reusable component library that every future feature will share.

Every component must:

- consume Qaddy Theme Extensions
- consume Design Tokens
- be reusable
- remain stateless unless absolutely required
- never hardcode values
- support Light and Dark themes

---

# Documentation References

Implementation must follow:

- docs/project-rules.md
- docs/engineering-principles.md
- design/design-tokens/*
- design/ui-components/*
- README.md

No implementation may contradict these documents.

---

# Components In Scope

Create the following reusable components.

## Buttons

- Primary Button
- Secondary Button
- Tertiary Button
- Icon Button

Follow:

- buttons-library-v1.png

Use:

- QaddyColours
- QaddySpacing
- QaddyRadius
- QaddyTypography
- QaddyElevation
- QaddyMotion

---

## Cards

Create:

- Base Card
- Section Card
- Statistic Card

Follow:

- cards-library-v1.png

---

## Input Fields

Create:

- Text Field
- Search Field
- Password Field

Follow:

- forms-library-v1.png
- Engineering Decision — Password Field

---

## Loading

Create reusable loading widgets:

- Circular Loader
- Linear Loader
- One reusable, generic `FullScreenLoader` component

Follow:

- loaders-library-v1.png

### `FullScreenLoader`

The Loaders Library's "Loading Screen" panel shows the Qaddy logo, a progress indicator, and a message ("Getting your round ready…"). That message is an **illustrative example only** — it belongs to a future Rounds feature and must not be hardcoded into the component.

`FullScreenLoader` must:

- be a single, generic component (not one widget per feature)
- always display the Qaddy logo and a loading/progress indicator
- accept its loading message as a required parameter rather than hardcoding any copy
- contain no feature-specific logic or feature-specific default message

Future features (e.g. Rounds) will supply their own message (such as "Getting your round ready…") while reusing this same component — that message is not implemented during Sprint 1.3.

---

## Empty States

Create exactly one reusable, generic, configurable `EmptyState` component.

The component must:

- be a single component (not one widget per feature)
- accept its icon, title, message and optional action as configurable parameters
- contain no feature-specific logic or feature-specific defaults

Empty Rounds, Empty Trips, Empty Friends, Empty Statistics and Empty Golf Bag are **illustrative future uses only** — examples of screens that will later configure the `EmptyState` component with their own icon/title/message/action, not separate widgets. **No feature-specific Empty State widgets are created during Sprint 1.3.**

---

## Error States

Create reusable:

- Error Card
- Retry Widget

No networking logic.

Visual components only.

---

# Component Rules

Components must:

- never contain business logic
- never call Supabase
- never call repositories
- never call providers directly
- expose configurable parameters only
- be reusable

---

# Out of Scope

Do NOT build:

- Dashboard UI
- Statistics
- Golf IQ
- Authentication
- User Profiles
- Trips
- Rounds
- Scorecards
- API calls
- Supabase
- Riverpod logic

Only reusable components.

---

# Deliverables

Create reusable components under:

```
lib/core/widgets/
```

Suggested structure:

```
buttons/
cards/
forms/
loaders/
states/
```

Component filenames should clearly describe their purpose.

---

# Acceptance Criteria

Sprint 1.3 is complete when:

- every component compiles
- all components use Theme Extensions
- no hardcoded design values exist
- Light Mode works
- Dark Mode works
- flutter analyze passes
- flutter test passes
- dart format passes

---

# Verification

Run:

```bash
dart format .
flutter analyze
flutter test
```

All commands must complete successfully before Sprint 1.3 is considered complete.

---

# Stop Conditions

Stop implementation immediately if:

- documentation conflicts
- missing design values
- undocumented engineering decisions
- component behaviour requires guessing
- implementation would violate project-rules.md

Report the blocker before continuing.

---

# Completion Report

Provide:

1. Summary

2. Files Created

3. Files Modified

4. Engineering Decisions

5. Verification Results

6. Recommendations for Sprint 1.4

Do not begin Sprint 1.4.
## Engineering Decision — Password Field

The current Forms Library does not include a dedicated Password Field component.

Sprint 1.3 requires a reusable password input for future authentication screens, therefore the Password Field is defined as an Engineering Decision until a future design asset supersedes it.

The Password Field shall reuse the standard Text Field component with the following behaviour:

- identical spacing
- identical typography
- identical border radius
- identical colours
- identical validation styling

Additional behaviour:

- obscure text enabled by default
- trailing visibility toggle icon
- tap icon toggles obscure/reveal
- icon uses standard Material visibility icons
- no additional styling differences

No other behaviour should differ from the standard Text Field.

Future design assets may replace this implementation.