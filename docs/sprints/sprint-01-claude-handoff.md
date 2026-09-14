# Qaddy
# Sprint 01 – Flutter Foundation
## Claude Implementation Handoff

Version: 1.0

---

# Overview

Welcome to the Qaddy project.

Qaddy is a premium golf ecosystem built using Flutter.

The goal is to create the most polished and complete golf application available.

This repository already contains:

- Complete Design System
- UI Component Library
- Feature Mockups
- Asset Library
- Design Tokens
- Engineering Standards
- Product Documentation

This sprint focuses ONLY on building the application foundation.

No product features should be implemented.

---

# Objective

Create a production-ready Flutter foundation that every future feature will build upon.

The implementation must be scalable, maintainable and reusable.

---

# Technology Stack

Flutter

Riverpod

GoRouter

Supabase (not yet implemented)

Theme Extensions

Material 3

Responsive Layout

---

# Architecture

Follow Feature-First Architecture.

Shared code belongs inside shared/.

Feature-specific code belongs inside features/.

No duplicated UI.

No duplicated logic.

Reusable components always come first.

---

# Folder Structure

The project should follow this structure.

lib/

core/

shared/

features/

theme/

navigation/

providers/

services/

extensions/

widgets/

---

# Build These

## Theme

Light Theme

Dark Theme

ThemeData

Theme Extensions

Colour Palette

Typography

Spacing

Border Radius

Shadows

Animations

---

## Responsive Layout

Phone

Tablet

Desktop

Breakpoints

---

## Navigation

GoRouter

Shell Route

Bottom Navigation

Navigation Configuration

---

## Shared Components

Primary Button

Secondary Button

Outlined Button

Text Button

Loading Button

Card

Section Card

Statistic Card

Dialogs

Loading Spinner

Input Fields

Navigation Components

---

## Utilities

Spacing Extensions

Theme Extensions

Context Extensions

String Extensions

Date Extensions

---

## Providers

Theme Provider

Settings Provider

Navigation Provider

---

# Do NOT Build

Dashboard

Golf Bag

Golf IQ

Trips

Rounds

Round Details

Community

Ask Qaddy

Authentication

Supabase

Business Logic

Database

Payments

Notifications

AI

---

# Design Requirements

Use the existing Design System.

Use Design Tokens.

Use Typography Tokens.

Use Colour Tokens.

Use Spacing Tokens.

Never hardcode colours.

Never hardcode spacing.

Never hardcode typography.

Never hardcode border radius.

Never hardcode animation durations.

---

# Coding Standards

Const constructors wherever possible.

Small widgets.

Maximum widget length approximately 200 lines.

Meaningful filenames.

Meaningful class names.

Composition over inheritance.

No duplicated widgets.

No duplicated code.

Reusable first.

---

# Performance

Minimise rebuilds.

Prefer const widgets.

Use Riverpod correctly.

Avoid unnecessary nesting.

---

# Accessibility

Respect text scaling.

Support screen readers.

Minimum touch target size.

Support dark mode.

---

# Files Claude May Edit

lib/

pubspec.yaml

analysis_options.yaml

---

# Files Claude Must NOT Edit

design/

docs/

assets/mockups/

README files

GitHub configuration

---

# Acceptance Criteria

flutter analyze passes

flutter test passes

No warnings

No errors

Responsive

Dark mode working

Light mode working

Reusable components created

Navigation functioning

Theme fully implemented

Folder structure completed

No placeholder code

No TODO comments

Production-ready quality

---

# Deliverables

- App Theme
- Design Tokens
- Theme Extensions
- Navigation
- Responsive Layout
- Shared Widgets
- Riverpod Setup
- GoRouter Setup
- Folder Structure
- Base Application Shell

---

# Commit Message

feat: complete Sprint 01 Flutter foundation

---

# Definition of Done

Sprint 01 is complete when:

The application launches successfully.

Navigation is functional.

The theme is fully implemented.

All reusable components compile.

Flutter Analyze passes.

Flutter Test passes.

The codebase follows Qaddy engineering standards.

No feature-specific UI has been created.

Only the application foundation exists.

---

End of Sprint 01