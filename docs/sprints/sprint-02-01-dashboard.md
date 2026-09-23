# Sprint 2.1 – Dashboard

**Version:** 1.0

**Status:** Draft

**Sprint:** 2.1

---

# Purpose

Sprint 2.1 delivers Qaddy's first real feature screen.

This sprint replaces the current placeholder Home screen with the first production Dashboard.

The Dashboard acts as the application's control centre and is the screen users return to most often.

It should immediately communicate:

- upcoming golf
- current rounds
- recent activity
- player statistics
- quick access to the most common actions

This sprint builds only the visual foundation.

No live data, backend integration or business logic is included.

---

# References

Implementation must follow:

- docs/architecture/navigation.md
- docs/architecture/responsive-layout.md
- docs/architecture/round-data-model.md
- docs/design/colours.md
- docs/design/spacing.md
- docs/design/typography.md
- docs/design/radius.md
- docs/design/breakpoints.md
- docs/project-rules.md
- docs/engineering-principles.md
- docs/ai/implementation-workflow.md

---

# Existing Foundation

The following infrastructure already exists and must be reused.

- QaddyTheme
- QaddyColours
- QaddyTypography
- QaddySpacing
- QaddyRadius
- QaddyBreakpoints
- ResponsiveBuilder
- ResponsivePadding
- ResponsiveMaxWidth
- QaddyScaffold
- App Router
- Navigation Shell
- Shared Buttons
- Shared Cards
- Shared Text Fields

Do not recreate any existing components.

---

# Sprint Goal

By the end of this sprint the user should be able to open Qaddy and immediately see a polished Dashboard rather than a placeholder page.

The dashboard should feel like a premium golf application despite using placeholder data.

---

# Build

Replace:

lib/features/dashboard/ui/screens/dashboard_screen.dart

Create supporting widgets only where necessary.

Avoid unnecessary widget fragmentation.

---

# Dashboard Layout

The dashboard contains the following sections in order.

---

## 1. Welcome Header

Displays

- Greeting
- User name (placeholder)
- Current date

Example

Good Morning,

Tiamana

Tuesday 22 September

---

## 2. Quick Actions

Four primary actions.

Create Round

Continue Round

Statistics

Friends

These should appear as reusable action cards.

No navigation logic is implemented.

Buttons remain disabled or placeholder.

---

## 3. Upcoming Round

Single feature card.

Displays placeholder information.

Example

Richmond Golf Club

Saturday

8:20 AM

8 Players

Status badge

Upcoming

---

## 4. Recent Round

Displays

Course

Winner

Score

Date

View Summary button

Uses placeholder values only.

---

## 5. Statistics Preview

Four summary cards.

Rounds Played

Average Score

Handicap

Best Round

Placeholder values only.

---

## 6. Recent Activity

Simple vertical timeline.

Examples

Round completed

Friend joined

Trip created

Achievement unlocked

Placeholder entries only.

---

# Empty States

If future data becomes empty the layout must gracefully support empty cards.

Do not implement empty-state logic.

Only ensure widgets allow future support.

---

# Loading States

No loading behaviour required.

Do not implement shimmer effects.

Future sprint.

---

# Responsive Behaviour

Dashboard must support

Mobile

Tablet

Desktop

Desktop should use ResponsiveMaxWidth.

Spacing must use QaddySpacing.

No hardcoded dimensions.

---

# Design Requirements

Dashboard must

use QaddyScaffold

use existing typography tokens

use existing colour tokens

use existing spacing tokens

use existing radius tokens

remain scrollable

remain responsive

avoid nested scrolling

---

# Accessibility

Touch targets

Minimum 48px

Text must follow typography tokens.

Icons require semantic labels where appropriate.

---

# Do Not Build

Do not build

authentication

Supabase

Riverpod providers

repositories

API calls

real navigation

statistics engine

round creation

friends

notifications

settings

premium

business logic

---

# Acceptance Criteria

Sprint 2.1 is complete when

- placeholder Home screen removed

- production dashboard created

- dashboard uses QaddyScaffold

- dashboard is fully responsive

- dashboard scrolls correctly

- no hardcoded colours

- no hardcoded spacing

- no business logic

- no duplicated widgets

- flutter analyze passes

- flutter test passes

---

# Verification

Run

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test
```

Fix every issue before continuing.

---

# Expected Output

The dashboard should resemble a polished golf application using placeholder data.

Users should immediately understand the purpose of Qaddy.

Although all data is static, the application should already feel premium and production quality.

---

# Commit

After successful verification

Stage all files

Create a commit

Push to main

Provide a Sprint Completion Report including

- Summary
- Files Created
- Files Modified
- Engineering Decisions
- Verification Results
- Git Status
- Recommendations for Sprint 2.2

Stop after completion.

Do not begin Sprint 2.2.