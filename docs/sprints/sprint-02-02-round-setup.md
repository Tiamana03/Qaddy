# Sprint 2.2 – Round Setup

**Version:** 1.0

**Status:** Draft

**Sprint:** 2.2

---

# Purpose

Sprint 2.2 introduces the Round Setup experience.

This sprint replaces the placeholder Rounds screen with a production-ready interface that allows users to prepare a golf round before play begins.

The goal is to create a clean, intuitive setup flow using placeholder data only.

No database, backend integration or business logic is included.

---

# References

Implementation must follow:

- docs/architecture/navigation.md
- docs/architecture/round-data-model.md
- docs/architecture/responsive-layout.md
- design/design-tokens/colours.md
- design/design-tokens/spacing.md
- design/design-tokens/typography.md
- design/design-tokens/radius.md
- docs/design/breakpoints.md
- docs/standards/placeholder-data.md
- docs/project-rules.md
- docs/engineering-principles.md
- docs/ai/implementation-workflow.md

---

# Existing Foundation

The following infrastructure already exists and must be reused.

- QaddyTheme
- QaddyScaffold
- ResponsiveBuilder
- ResponsivePadding
- ResponsiveMaxWidth
- Shared Buttons
- Shared Cards
- Shared Text Fields
- Navigation Shell
- App Router

Do not recreate existing infrastructure.

---

# Sprint Goal

By the end of this sprint users should be able to navigate to the Rounds screen and feel like they are preparing for a real golf round.

Although all information is placeholder data, the UI should resemble a production application.

---

# Build

Replace:

lib/features/rounds/ui/screens/rounds_screen.dart

Create reusable widgets only where appropriate.

Avoid unnecessary widget fragmentation.

---

# Screen Layout

The screen contains the following sections.

---

## 1. Page Header

Displays

- Page Title
- Short description

Example

Rounds

Create and manage your golf rounds.

---

## 2. Upcoming Round Card

Display information from placeholder-data.md

Include

- Course
- Date
- Tee Time
- Player Count
- Weather
- Status Badge

---

## 3. Players Section

Display all players listed in placeholder-data.md

Each player card contains

- Name
- Handicap
- Placeholder Avatar
- Status

---

## 4. Round Information

Display

- Course
- Tee Time
- Format
- Holes

Use placeholder values only.

---

## 5. Side Games

Display enabled side games.

Include

- Longest Drive
- Nearest The Pin
- Drive & Chip

Show configured holes.

No editing functionality.

---

## 6. Primary Actions

Display action buttons.

- Start Round
- Edit Round
- Cancel Round

Buttons are visual only.

No functionality.

---

# Placeholder Data

All displayed information must come from

docs/standards/placeholder-data.md

Do not invent values.

---

# Responsive Behaviour

Support

- Mobile
- Tablet
- Desktop

Desktop layouts must use ResponsiveMaxWidth.

Spacing must use QaddySpacing.

No hardcoded dimensions.

---

# Design Requirements

The screen must

- use QaddyScaffold
- remain scrollable
- use design tokens
- use shared widgets
- avoid nested scrolling

---

# Accessibility

Touch targets

Minimum 48px

Typography must follow design tokens.

Icons require semantic labels where appropriate.

---

# Do Not Build

Do not implement

- Create Round logic
- Editing rounds
- Saving rounds
- Riverpod providers
- Supabase
- APIs
- Business logic
- Navigation actions
- Validation
- Live scoring
- Leaderboard calculations

---

# Acceptance Criteria

Sprint 2.2 is complete when

- Placeholder screen removed
- Round Setup screen implemented
- Placeholder data displayed correctly
- Existing shared widgets reused
- Fully responsive
- Scroll behaviour correct
- No duplicated components
- No business logic
- Flutter analyze passes
- Flutter tests pass

---

# Verification

Run

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test
```

Fix all issues before continuing.

---

# Expected Output

The Round Setup screen should resemble a modern golf application ready for users to begin a round.

Although all information is static, the screen should feel polished, premium and production ready.

---

# Commit

After successful verification

- Stage all files
- Create a commit
- Push to main

Provide a Sprint Completion Report including

- Summary
- Files Created
- Files Modified
- Engineering Decisions
- Verification Results
- Git Status
- Recommendations for Sprint 2.3

Stop after completion.

Do not begin Sprint 2.3.