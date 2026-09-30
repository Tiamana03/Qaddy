# Qaddy Project Rules

**Version:** 1.0

**Status:** Active

**Source:** Engineering Standards

**Last Updated:** September 2026

---

# Purpose

This document defines the mandatory engineering rules that apply across the entire Qaddy project.

These rules exist to maintain consistency, quality and long-term maintainability.

They apply to every feature without exception.

---

# Documentation Rules

Always read documentation from disk.

Never rely on memory.

Always review:

- Feature Integration
- Architecture
- Data Models
- Placeholder Data
- Navigation
- Engineering Decisions
- Design Tokens

before implementation.

---

# Documentation Consistency

Documentation must remain internally consistent.

Automatically resolve:

- terminology mismatches
- outdated references
- duplicated information
- missing placeholder values
- navigation inconsistencies
- documentation drift

Only escalate genuine architecture decisions.

---

# Single Source of Truth

Never duplicate:

- models
- placeholder data
- navigation
- routes
- engineering decisions

Every concept must have one authoritative document.

---

# Placeholder Data

Never invent placeholder data.

Only use documented placeholder values.

If required placeholder data is missing:

- update the placeholder document
- re-read it
- continue implementation

---

# Models

Never invent model fields.

Never duplicate models.

If a new field is genuinely required:

- update the model first
- then implement

---

# Navigation

Never invent routes.

Never invent navigation.

Navigation must match navigation.md exactly.

---

# Shared Components

Before creating:

- widget
- service
- repository
- model
- animation

check whether one already exists.

Always reuse before creating.

---

# Feature Boundaries

Every feature owns its own implementation.

Shared functionality belongs in shared or core modules.

Avoid coupling features together.

---

# Design Tokens

Never hardcode:

- colours
- typography
- spacing
- radius
- shadows
- durations

Always use shared design tokens.

---

# Naming

Use consistent naming.

Avoid abbreviations unless already established.

Names should clearly describe purpose.

---

# Verification

Every feature must pass:

- dart format
- flutter analyze
- flutter test

before completion.

Warnings should be resolved wherever possible.

---

# Code Quality

Prefer:

- readable code
- simple solutions
- reusable components
- small widgets
- modular architecture

Avoid unnecessary complexity.

---

# Continuous Improvement

Leave the project cleaner than you found it.

When safe:

- improve documentation
- improve consistency
- improve naming
- improve reuse
- remove duplication

---

# Cross-Feature Consistency

If a safe improvement benefits previously completed features:

Apply it consistently across all affected features.

Do not leave similar implementations inconsistent.

---

# Automatic Fixes

Automatically resolve:

- documentation inconsistencies
- placeholder inconsistencies
- implementation inconsistencies
- naming inconsistencies
- routing inconsistencies
- reusable component opportunities

Only ask for user input when a product or architecture decision is genuinely required.

---

# Commits

Do not commit automatically.

Only commit when explicitly requested.

Every commit should represent a stable, working state.

---

# Definition of Done

A feature is complete only when:

- documentation is internally consistent
- implementation matches documentation
- navigation is correct
- placeholder data is complete
- shared widgets are reused
- analyzer passes
- tests pass
- formatting passes
- no unresolved blockers remain

---

# Final Principle

Build Qaddy as if it will still be actively developed ten years from now.

Every decision should make the project easier to extend, easier to understand and easier to maintain.

Short-term convenience must never compromise long-term quality.

---

**End of Document**