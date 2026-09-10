# Qaddy UI Component Library
Version: 1.0
Status: Active
Last Updated: September 2026

---

# Purpose

This document defines every reusable UI component used throughout Qaddy.

Components should be built once, tested thoroughly and reused across the application.

Consistency is more valuable than variety.

---

# Design Philosophy

Every component should be:

- Simple
- Premium
- Fast
- Accessible
- Consistent
- Reusable

If a new screen needs a UI element that already exists, reuse the component rather than creating a new version.

---

# Buttons

## Primary Button

Purpose

The primary call-to-action.

Examples

- Start Round
- Save
- Continue
- Join Challenge

Style

- Qaddy Green background
- White text
- Rounded corners
- Full-width when appropriate
- Subtle elevation

---

## Secondary Button

Purpose

Alternative actions.

Examples

- Cancel
- Learn More
- View Details

Style

- Transparent background
- Green border
- Green text

---

## Icon Button

Purpose

Quick actions.

Examples

- Share
- Edit
- Favourite
- Settings

Always use the approved Qaddy icon style.

---

# Cards

## Stat Card

Displays one key statistic.

Examples

- Handicap
- Fairways Hit
- Putts
- Average Score

---

## Round Card

Displays:

- Course
- Date
- Score
- Playing partners
- Quick actions

---

## Achievement Card

Displays:

- Achievement icon
- Title
- Date earned
- Description

---

## Trip Card

Displays:

- Destination
- Dates
- Courses
- Status

---

## Premium Card

Used to promote premium features.

Must feel informative rather than pushy.

---

# Navigation

## Bottom Navigation

Contains the primary navigation items.

Must remain consistent throughout the application.

---

## Top App Bar

Displays:

- Screen title
- Context actions
- Notifications when applicable

---

# Inputs

## Text Field

Used for:

- Search
- Notes
- Messages

---

## Search Field

Supports instant search where possible.

---

## Dropdown

Used for structured selections.

Avoid overusing dropdowns.

---

# Lists

Every list should support:

- Loading state
- Empty state
- Error state

---

# Charts

Charts should prioritise readability.

Animations should support understanding, not decoration.

---

# Empty States

Every empty screen should:

- Explain why it is empty.
- Encourage the next action.
- Feel positive.

Example:

"No rounds yet.

Let's play your first one."

---

# Loading States

Prefer skeleton loading over spinning indicators whenever practical.

Loading should reassure users that progress is being made.

---

# Error States

Always explain:

- What happened.
- What the user can do next.

Never display technical jargon.

---

# Accessibility

Every component must support:

- Large text
- Screen readers
- Colour contrast
- Comfortable touch targets

---

# Component Rules

Before creating a new component ask:

1. Does one already exist?
2. Can the existing component be extended?
3. Will this improve consistency?

Reuse before creating.

---

# Final Principle

The best interface is one users never need to think about.

Every component should quietly help golfers achieve their goal without distracting them.
