# Sprint 1.5 — Foundation Integration

**Version:** 1.0

**Status:** Active

---

# Sprint Goal

Complete the integration of all Sprint 1 foundation work into a single, production-ready application foundation.

Sprint 1.5 focuses on connecting and validating the work completed in Sprints 1.1–1.4.

No new architecture should be introduced.

No feature-specific business logic should be created.

---

# References

Required reading before implementation:

- docs/ai/implementation-workflow.md
- docs/project-rules.md
- docs/engineering-principles.md
- docs/architecture/navigation.md
- docs/architecture/responsive-layout.md

Design Tokens

- colours.md
- typography.md
- spacing.md
- radius.md
- breakpoints.md

---

# In Scope

## Foundation Integration

Integrate the existing foundation into a consistent application.

This includes:

- ensuring all placeholder screens use the shared design system
- applying responsive helpers where appropriate
- applying shared spacing
- applying shared typography
- applying shared colours
- applying shared radius values
- ensuring all screens follow the same layout conventions

---

## Shared Scaffold

Complete the reusable application scaffold.

The scaffold should provide:

- SafeArea
- ResponsivePadding
- ResponsiveMaxWidth
- consistent page layout
- optional AppBar support
- optional Bottom Navigation support

The scaffold must consume the existing responsive helpers created during Sprint 1.4.

No responsive calculations may exist inside feature screens.

---

## Application Integration

Verify that the existing application foundation works together correctly.

This includes verifying:

- application startup
- navigation
- theme
- responsive layout
- shared widgets
- placeholder screens

Only integration work should occur.

---

## Placeholder Screens

Existing placeholder screens should be reviewed for consistency.

Each screen should:

- use the shared scaffold
- use shared typography
- use shared spacing
- consume design tokens
- remain intentionally lightweight

Do not add feature functionality.

---

## Loading & Empty States

Where appropriate, integrate the existing shared components for:

- loading states
- empty states
- error states

Reuse existing components wherever possible.

---

# Existing Foundation

The following infrastructure already exists and must be reused:

- App Router
- GoRouter configuration
- ShellRoute
- Bottom Navigation
- Route definitions
- Placeholder screens
- Theme
- Design tokens
- Shared components
- Responsive helpers
- Utilities

Sprint 1.5 must extend and integrate these implementations.

It must not recreate or replace them.

---

# Do Not Build

Do not create:

- new routing systems
- duplicate navigation
- duplicate placeholder screens
- dashboard functionality
- rounds functionality
- trips functionality
- friends functionality
- profile functionality
- Supabase integration
- repositories
- API services
- authentication
- business logic
- feature-specific UI

These belong to future sprints.

---

# Requirements

The application foundation must:

- reuse existing architecture
- consume design tokens
- consume responsive helpers
- consume shared widgets
- contain no duplicated navigation logic
- contain no duplicated responsive calculations
- remain production ready

---

# Acceptance Criteria

Implementation is complete when:

- all placeholder screens use the shared scaffold
- responsive helpers are integrated
- navigation functions correctly
- shared widgets are reused
- theme is applied consistently
- design tokens are used throughout
- no duplicated architecture exists
- flutter analyze passes
- flutter test passes
- dart format passes

---

# Verification

Run exactly:

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test
```

If verification fails:

- fix the issue
- rerun verification
- repeat until every command succeeds

---

# Stop Conditions

Stop immediately if:

- implementation requires guessing
- documentation conflicts with existing architecture
- implementation duplicates existing systems
- undocumented design decisions are required
- additional architecture is needed

Do not guess.

---

# Completion Report

Provide:

1. Summary

2. Files created

3. Files modified

4. Engineering decisions

5. Verification

6. Recommendations for Sprint 2

Do not begin Sprint 2.