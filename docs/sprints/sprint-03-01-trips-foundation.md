# Sprint 3.1 — Trips Foundation

**Version:** 1.0

**Status:** Ready for Implementation

**Sprint:** 3.1

---

# Purpose

Replace the existing Trips placeholder screen with the first production-ready Trips screen.

This sprint establishes the reusable foundation for all future trip functionality.

No backend functionality is implemented.

All data comes from placeholder-trip-data.md.

---

# User Story

As a golfer,

I want to quickly view my golf trips,

so I can see upcoming adventures and previous golf holidays from one place.

---

# Existing Foundation

The following systems already exist and **must be reused**.

- QaddyScaffold
- ResponsiveBuilder
- ResponsivePadding
- ResponsiveMaxWidth
- QaddyCard
- QaddySectionCard
- QaddyStatusBadge
- QaddyPrimaryButton
- QaddySecondaryButton
- Theme Tokens
- Navigation
- Responsive Utilities

Do not recreate existing components.

---

# Build

Replace

```
Trips Placeholder Screen
```

with

```
Trips Foundation Screen
```

---

Create the following reusable widgets.

```
QaddyTripCard

TripsSummaryCard

TripsQuickActions
```

These widgets should be reusable by future screens.

---

# Screen Layout

```
Trips

------------------------------------------------

Trips Summary

Upcoming
Past
Countries

------------------------------------------------

Quick Actions

Create Trip

Browse Trips

------------------------------------------------

Upcoming Trips

Trip Card

Trip Card

------------------------------------------------

Past Trips

Trip Card

Trip Card

```

---

# Trips Summary

Display

- Upcoming Trips
- Past Trips
- Countries Visited

Values come from

```
placeholder-trip-data.md
```

---

# Quick Actions

Display

- Create Trip

- Browse Trips

Buttons do not navigate during this sprint.

---

# Upcoming Trips

Display every Upcoming Trip.

Each card contains

- Cover Image Placeholder
- Trip Name
- Destination
- Dates
- Duration
- Player Count
- Status Badge

Cards must use

```
QaddyTripCard
```

---

# Past Trips

Display every completed Trip.

Cards use the same layout.

Completed Trips appear newest first.

---

# Trip Card

The reusable Trip Card contains

Cover Image Placeholder

Trip Name

Destination

Trip Dates

Player Count

Status Badge

Chevron Icon

The card should visually match the Dashboard cards introduced in Sprint 2.1.

---

# Status Badges

Reuse

```
QaddyStatusBadge
```

Supported values

- Planning

- Confirmed

- In Progress

- Completed

- Cancelled

No additional status values may be created.

---

# Responsive Behaviour

## Mobile

Single column layout.

Cards occupy full width.

---

## Tablet

Summary cards become horizontal.

Trip cards display in two columns.

---

## Desktop

Summary cards remain horizontal.

Trip cards display in three columns.

Maximum content width must use

```
ResponsiveMaxWidth
```

---

# Placeholder Data

Use only

```
placeholder-trip-data.md
```

No hardcoded values.

---

# Styling

Use only existing design tokens.

Never hardcode

- Colours

- Padding

- Radius

- Typography

- Elevation

---

# Accessibility

Buttons require semantic labels.

Cards must be keyboard accessible.

Text must respect Flutter scaling.

---

# Do Not Build

Do not build

- Trip Details
- Flight Information
- Accommodation Pages
- Expenses
- Weather
- Maps
- Itinerary
- Chat
- Notifications
- Bookings
- Photos
- Sharing
- Backend
- Authentication
- Supabase
- APIs

---

# File Structure

Expected additions

```
lib/
└── features/
    └── trips/
        ├── ui/
        │   ├── screens/
        │   │   trips_screen.dart
        │   │
        │   └── widgets/
        │       qaddy_trip_card.dart
        │       trips_summary_card.dart
        │       trips_quick_actions.dart
```

---

# Testing

Add widget tests covering

Trips Screen

Trip Card

Responsive Layout

Summary Cards

Status Badge Rendering

---

# References

Read before implementation

```
docs/ai/implementation-workflow.md

docs/architecture/navigation.md

docs/architecture/responsive-layout.md

docs/architecture/trip-data-model.md

docs/standards/placeholder-trip-data.md

design/design-tokens/colours.md

design/design-tokens/spacing.md

design/design-tokens/typography.md

design/design-tokens/radius.md

design/design-tokens/breakpoints.md
```

---

# Verification

Run exactly

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test
```

If any command fails

Fix the issue

Run verification again

Repeat until all commands pass

---

# Git Workflow

After verification

Review every changed file.

Stage only sprint files.

Commit using

```
feat: complete Sprint 3.1 trips foundation
```

Push to

```
main
```

---

# Sprint Completion Report

Provide

## Sprint Summary

Describe what was implemented.

---

## Files Created

List every created file.

---

## Files Modified

List every modified file.

---

## Engineering Decisions

Explain every implementation decision that required interpretation.

Reference the supporting documentation where applicable.

---

## Verification Results

Report

- dart format

- flutter analyze

- flutter test

---

## Git Status

Provide

Commit hash

Commit message

Push confirmation

---

## Recommendations for Sprint 3.2

List improvements or preparation work that would benefit the next sprint.

---

Stop after completing Sprint 3.1.

Do not begin Sprint 3.2.