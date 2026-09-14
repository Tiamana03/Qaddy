# Qaddy Development Principles

Version: 1.0

---

## Purpose

These principles define how Qaddy is designed, developed, reviewed and maintained.

Every contributor, whether human or AI, should follow these standards.

---

# Core Principles

## Build once. Reuse everywhere.

Reusable components always come before feature-specific components.

If a widget can be reused elsewhere, it belongs in the shared component library.

---

## Feature-first architecture.

Features own their own UI, state and logic.

Shared code belongs in the shared layer.

---

## Design System First

Every screen must use the Qaddy Design System.

Never invent colours.

Never invent spacing.

Never invent typography.

Never invent shadows.

Always use design tokens.

---

## Clean Code

Readable code beats clever code.

Small widgets.

Meaningful naming.

Single responsibility.

Composition over inheritance.

---

## Performance

Avoid unnecessary rebuilds.

Use const constructors whenever possible.

Optimise before adding complexity.

---

## Testing

Every reusable component should be testable.

Business logic should be isolated.

UI should remain predictable.

---

## Documentation

Every major architectural decision must be documented.

Large features require documentation before implementation.

---

## AI Development

AI should implement.

AI should not redesign.

AI should not invent product decisions.

ChatGPT defines architecture.

Claude implements architecture.

---

Version 1.0