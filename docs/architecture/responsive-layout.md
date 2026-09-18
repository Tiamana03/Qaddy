# Responsive Layout Architecture

**Version:** 1.1

**Status:** Active

**Last Updated:** September 2026

---

# Purpose

This document defines how Qaddy behaves across different screen sizes.

It is the single source of truth for:

- Breakpoints
- Responsive layout behaviour
- Maximum content widths
- Adaptive spacing
- Responsive widgets
- Layout scaling

No developer or AI may invent responsive behaviour outside this document.

---

# Responsive Principles

## Mobile First

All layouts begin with the mobile experience.

Additional screen space should enhance the interface rather than fundamentally changing it.

---

## Consistent

Every screen should follow identical responsive behaviour.

Responsive layouts should feel predictable throughout the application.

---

## Scalable

Layouts should support future tablets, desktops and larger monitors without redesign.

---

## Token Driven

All responsive behaviour must reference:

- breakpoints.md
- spacing.md
- typography.md

No breakpoint or spacing value may be hardcoded.

---

# Breakpoints

Official breakpoints are defined in:

`design/design-tokens/breakpoints.md`

These values must never be duplicated.

---

# Layout Behaviour

## Mobile

- Single column
- Full width
- Standard spacing

---

## Tablet

- Increased spacing
- Wider content
- Optional two-column layouts where appropriate

---

## Desktop

- Maximum content width
- Centred layouts
- Increased whitespace
- Multi-column layouts where appropriate

---

# Maximum Content Width

Content should never continue expanding indefinitely.

Maximum widths must use the values defined within `breakpoints.md`.

---

# Responsive Widgets

Sprint 1.4 introduces reusable responsive helpers including:

- ResponsiveBuilder
- ResponsivePadding
- ResponsiveMaxWidth
- ResponsiveSpacing

Future responsive helpers should follow the same architecture.

---

## ResponsiveBuilder

Chooses the appropriate widget for the current breakpoint.

All breakpoint calculations must delegate to `QaddyBreakpoints`.

---

## ResponsivePadding

Applies the correct horizontal padding for the current breakpoint.

Padding values must come from `spacing.md`.

---

## ResponsiveMaxWidth

Constrains content to the maximum width defined by `breakpoints.md`.

Desktop layouts should remain centred.

---

## ResponsiveSpacing

ResponsiveSpacing provides adaptive spacing between widgets.

It is a lightweight wrapper around `SizedBox` that resolves Qaddy spacing tokens into the correct spacing values for the current breakpoint.

Business screens should use `ResponsiveSpacing` rather than manually creating responsive `SizedBox` widgets.

### Constructors

ResponsiveSpacing provides three constructors:

```dart
const ResponsiveSpacing.vertical({
  this.size = ResponsiveSpacingSize.medium,
});

const ResponsiveSpacing.horizontal({
  this.size = ResponsiveSpacingSize.medium,
});

const ResponsiveSpacing({
  required this.direction,
  this.size = ResponsiveSpacingSize.medium,
});
```

### ResponsiveSpacingSize

ResponsiveSpacing supports the following semantic spacing sizes:

| ResponsiveSpacingSize | QaddySpacing Token |
|-----------------------|--------------------|
| small                 | sm                 |
| medium                | md                 |
| large                 | lg                 |
| extraLarge            | xl                 |

These semantic sizes provide a stable public API for ResponsiveSpacing.

The widget must resolve these semantic sizes to the corresponding `QaddySpacing` token defined in the table above.

ResponsiveSpacing is responsible for selecting the appropriate QaddySpacing token for the current breakpoint and using that token's value.

It must never define or calculate spacing values itself.

Feature code must never reference `QaddySpacing` directly when using ResponsiveSpacing.

Future spacing sizes should extend this table rather than introducing new constructors or bypassing semantic sizing.

### Default Behaviour

If no size is supplied:

- `vertical()` defaults to `ResponsiveSpacingSize.medium`
- `horizontal()` defaults to `ResponsiveSpacingSize.medium`

`ResponsiveSpacingSize.medium` maps to the `QaddySpacing.md` token.

Medium is the official Qaddy default spacing between unrelated UI elements.

### Rules

ResponsiveSpacing must:

- never contain hardcoded spacing values
- never calculate spacing directly
- always resolve values from `QaddySpacing`
- delegate breakpoint logic to `QaddyBreakpoints`
- remain a lightweight reusable widget
- contain no business logic
- contain no UI

### Example Usage

```dart
const ResponsiveSpacing.vertical();

const ResponsiveSpacing.horizontal();

const ResponsiveSpacing.vertical(
  size: ResponsiveSpacingSize.large,
);

const ResponsiveSpacing.horizontal(
  size: ResponsiveSpacingSize.small,
);
```

Future spacing sizes should extend the `ResponsiveSpacingSize` enum rather than introducing new constructors.

---

# Responsive Extensions

`responsive_extensions.dart` provides convenience extensions for accessing responsive information.

It exists purely to make feature code cleaner.

It must never duplicate responsive calculations.

All calculations must delegate to `QaddyBreakpoints`.

## BuildContext Extension

Provide a single `BuildContext` extension.

Available helpers include:

```dart
context.isMobile

context.isTablet

context.isDesktop

context.screenWidth

context.screenHeight
```

These extensions simply call the corresponding methods from `QaddyBreakpoints`.

No breakpoint values may be hardcoded.

### Rules

Extensions must:

- remain lightweight
- contain no business logic
- contain no UI
- never calculate breakpoint values directly
- always delegate to `QaddyBreakpoints`

Future responsive helpers should be added here rather than duplicated throughout the application.

### Example Usage

```dart
if (context.isDesktop) {
  ...
}
```

---

# Flutter Implementation

Responsive layouts will use:

- MediaQuery
- LayoutBuilder
- Breakpoint helper methods
- Responsive wrapper widgets

No widget should manually compare screen widths throughout the application.

---

# Engineering Decisions

## Responsive Helpers

Responsive behaviour should be encapsulated inside reusable widgets.

Business screens should consume responsive widgets rather than implementing breakpoint logic directly.

---

## Layout Logic

Breakpoint calculations belong inside shared responsive utilities.

Feature screens must never duplicate responsive calculations.

---

# Rules

- Never hardcode breakpoint values.
- Never duplicate responsive calculations.
- Always consume design tokens.
- Keep responsive behaviour reusable.
- Responsive behaviour must remain consistent throughout the application.

---

# Future Expansion

Future desktop-specific layouts should extend this architecture rather than replacing it.

Any responsive change must update this document before implementation begins.