# Qaddy Project Rules

**Version:** 1.0  
**Status:** Active  
**Last Updated:** September 2026

---

# Purpose

This document defines the engineering rules that every contributor—human or AI—must follow when working on Qaddy.

These rules exist to keep the project consistent, maintainable and scalable.

If another document describes *what* to build, this document describes *how* it must be built.

---

# Core Principles

## 1. Documentation is the Source of Truth

The documentation always takes precedence over implementation.

Code must follow the documentation.

The documentation must never be silently overridden by code.

---

## 2. Never Invent Missing Values

If a required value is missing from the documentation:

- stop implementation
- identify the missing information
- update the documentation first
- continue implementation only after the documentation is complete

This applies to:

- colours
- typography
- spacing
- radius
- shadows
- elevation
- animations
- breakpoints
- component behaviour
- architecture

---

## 3. Engineering Decisions Must Be Documented

Any value that is not directly sourced from a design asset must be documented as an Engineering Decision.

Engineering Decisions must include:

- the decision
- the reasoning
- where it applies

No undocumented engineering decisions are permitted.

---

## 4. No Magic Numbers

Never hardcode:

- colours
- spacing
- typography
- radius
- shadows
- elevation
- breakpoints
- animation durations
- animation curves

Everything must come from the design-token system.

---

## 5. Build Reusable Systems

Always prefer reusable systems over one-off implementations.

Examples:

- reusable widgets
- reusable themes
- reusable services
- reusable utilities

Avoid duplication whenever possible.

---

## 6. Respect Sprint Boundaries

Only complete the work defined for the current sprint.

Do not build future functionality.

Do not add "while I'm here" improvements.

Each sprint must finish cleanly before the next begins.

---

## 7. Follow the Repository Architecture

The established project architecture must be followed.

Do not create alternative folder structures without approval.

When unsure, follow the documented architecture rather than creating something new.

---

## 8. Quality Before Speed

Every implementation must:

- compile
- pass formatting
- pass static analysis
- pass tests

Required verification:

```bash
dart format .
flutter analyze
flutter test
```

No sprint is complete until all checks pass.

---

## 9. Keep Commits Focused

Each commit should represent one logical change.

Avoid mixing:

- documentation
- refactoring
- features
- bug fixes

in the same commit whenever possible.

---

## 10. Stop When Uncertain

If documentation is ambiguous:

Stop.

Do not guess.

Do not assume.

Do not invent.

Raise the ambiguity so it can be resolved.

---

# AI Development Rules

When using AI assistants (ChatGPT, Claude Code or future tools):

- Read project documentation before coding.
- Documentation overrides assumptions.
- Never invent missing values.
- Never silently change architecture.
- Explain engineering decisions.
- Respect sprint boundaries.
- Stop when ambiguity is discovered.
- Follow the repository coding standards.
- Prefer maintainability over cleverness.

---

# Definition of Done

A task is complete only when:

- documentation is updated (if required)
- implementation is complete
- formatting passes
- analysis passes
- tests pass
- engineering decisions are documented
- sprint report is produced

---

# Project Philosophy

Qaddy is being built as a long-term product.

Every decision should favour:

- clarity
- maintainability
- consistency
- scalability
- craftsmanship

We build systems first.

Features second.

Shortcuts become technical debt.

Good architecture compounds over time.