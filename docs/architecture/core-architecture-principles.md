# Core Architecture Principles

Version: 1.0

Status: Active

---

# Purpose

This document records the fundamental architectural principles that govern the Qaddy codebase.

Every feature should reinforce these principles.

---

# Principle 1 — Single Source of Truth

Every piece of data has exactly one owner.

Other features should derive the data rather than duplicate it.

Examples:

- Handicap → Profile
- Friends Count → Friends
- Trips Count → Trips
- Group Standings → Groups
- Statistics → Derived

---

# Principle 2 — Documentation Before Code

Architecture is designed before implementation.

Implementation never invents behaviour.

Documentation is the source of truth.

---

# Principle 3 — Zero Blockers Before Implementation

Implementation only begins after documentation validation reaches zero blockers.

---

# Principle 4 — Reuse Before Creation

Always reuse:

- widgets
- models
- placeholder data
- design tokens

before creating new ones.

---

# Principle 5 — Derived Data

Whenever practical, derive values from existing feature owners.

Avoid duplicated placeholder values.

Example:

Statistics derives:

- Handicap
- Average Score
- Friends Count
- Trips
- Group Standing

rather than defining them independently.