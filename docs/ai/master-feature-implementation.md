# Master Feature Implementation Workflow

**Version:** 1.0  
**Status:** Official Engineering Workflow

---

# Purpose

This document defines the mandatory implementation workflow for completing an entire Qaddy feature.

Examples include:

- Sprint 3 (Trips)
- Sprint 4 (Friends)
- Sprint 5 (Groups)
- Sprint 6 (Profile)
- Sprint 7 (Statistics)

This workflow replaces the individual sprint implementation process once a feature contains multiple completed sprint specifications.

No phase may be skipped.

---

# Primary Goal

Implement an entire feature as a single engineering task while maintaining the same engineering quality, testing standards, documentation standards and reusable architecture established throughout Qaddy.

# Feature Implementation Rule

When a Feature Integration document exists, it becomes the primary implementation specification for that feature.

Implementation order is:

1. Feature Integration
2. Architecture
3. Standards
4. Sprint Documents (reference only)

Sprint documents may still exist for planning, historical tracking, design notes, and future expansion, but they are no longer required for implementation when a complete Feature Integration document is available.

Do not stop implementation simply because individual sprint documents are empty or absent if the Feature Integration document fully specifies the feature.

If any contradiction exists, the Feature Integration document is the authoritative source.
---

# Phase 0 — Repository Review

Before writing any code:

Read the current repository.

Determine:

- Latest completed feature
- Latest completed sprint
- Existing reusable widgets
- Existing reusable models
- Existing utilities
- Existing extensions
- Existing design system components
- Existing placeholder data
- Existing architecture

Confirm:

- Git working tree
- Current branch
- Existing uncommitted changes

Do not modify unrelated files.

---

# Phase 1 — Documentation Review

Read every Architecture document required for this feature.

Examples:

- trip-data-model.md
- trip-lifecycle.md
- trip-structure.md

Read them completely.

Do not skim.

---

# Phase 2 — Standards Review

Read every Standards document required.

Examples

- placeholder-trip-data.md
- placeholder-data.md

Read completely.

These documents become the only approved placeholder data.

Never invent additional values.

---

# Phase 3 — Sprint Review

Read every sprint contained within the feature.

For example:

Sprint 3

- Sprint 3.1
- Sprint 3.2
- Sprint 3.3
- Sprint 3.4
- Sprint 3.5

Read every sprint before implementation begins.

---

# Phase 4 — Cross Reference Review

Cross-check:

Architecture

↓

Standards

↓

Sprint Documents

↓

Repository

Confirm:

- every widget exists
- every model exists
- every placeholder value exists
- every business rule exists
- every navigation reference exists
- every shared component exists

---

# Phase 5 — Repository Reuse Review

Before creating anything new, search the repository.

Determine whether reusable versions already exist.

Examples

- Cards
- Buttons
- Badges
- Avatars
- Lists
- Tiles
- Models
- Extensions
- Utilities

Reuse existing implementations whenever possible.

Do not duplicate functionality.

---

# Phase 6 — Documentation Validation

If documentation contains issues, classify them.

## Automatic Fixes

Claude may automatically fix:

- Broken file paths
- Broken document references
- Markdown formatting
- Duplicate references
- Typographical mistakes
- Dead documentation links

Document every automatic change.

---

## Product Decision Required

Claude must stop and report if documentation requires:

- New business rules
- New placeholder values
- New model fields
- New architecture concepts
- New workflows
- Missing acceptance criteria

Never invent these.

Produce one consolidated blocker report.

Wait for approval.

---

# Phase 7 — Blocker Report

Produce one report only.

Include:

Summary

Every blocker

Why it blocks implementation

Which document requires updating

Recommended solution

Do not implement anything.

---

# Phase 8 — User Approval

Wait for approval.

Only begin implementation after approval.

---

# Phase 9 — Feature Implementation

Implement every sprint contained within the feature.

Follow sprint order.

Do not skip requirements.

Do not implement future features.

---

# Phase 10 — Engineering Standards

Always:

Reuse widgets.

Reuse extensions.

Reuse utilities.

Reuse design tokens.

Maintain responsive behaviour.

Maintain accessibility.

Maintain naming conventions.

Maintain folder structure.

Maintain architecture.

---

# Phase 11 — Testing

Write tests for:

Models

Widgets

Screens

Utilities

Feature behaviour

Update existing tests if required.

---

# Phase 12 — Verification

Run:

dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test

Fix every issue before continuing.

---

# Phase 13 — Git Review

Review staged files.

Ensure unrelated work is excluded.

Confirm only feature files are staged.

---

# Phase 14 — Commit

Create one commit.

Commit message format:

feat: complete Sprint X feature

Examples

feat: complete Trips feature

feat: complete Friends feature

---

# Phase 15 — Push

Push to main.

Confirm push succeeded.

---

# Phase 16 — Completion Report

Produce a report containing:

## Feature Summary

Overall implementation summary.

---

## Sprints Completed

List every sprint completed.

---

## Files Created

List every new file.

---

## Files Modified

List every modified file.

---

## Engineering Decisions

Document every significant decision.

Explain why.

---

## Testing

Verification results.

Number of tests.

Analyze results.

Format results.

---

## Git

Commit hash

Commit message

Push confirmation

Working tree status

---

## Recommendations

Recommend improvements for the next feature.

---

# Engineering Rules

Always prefer:

Existing widget

↓

Existing model

↓

Existing utility

↓

Existing extension

↓

Create new implementation

Never duplicate existing functionality.

---

Never invent:

Placeholder values

Business rules

Architecture

Navigation

Acceptance criteria

Model fields

Workflow behaviour

If uncertain:

STOP

Document the blocker.

Wait.

---

# Success Criteria

A feature is considered complete only when:

✓ Every sprint is implemented

✓ Tests pass

✓ Analyze passes

✓ Format passes

✓ Documentation remains consistent

✓ Git working tree is clean

✓ Commit pushed

✓ Completion report produced

---

**End of Document**