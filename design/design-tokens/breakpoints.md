# Qaddy Design Tokens

# Breakpoints

Version: 2.0
Status: Active
Source: No dedicated breakpoints asset exists in `design/assets/` — see [Note on Source](#note-on-source). Every value below is an Engineering Decision.
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for every responsive breakpoint used inside the Qaddy application — the width thresholds that decide whether a screen is laid out as mobile, tablet, or desktop.

No screen or widget should compare `MediaQuery` width against a literal number. Every breakpoint check must be reached through a Flutter token, so "is this a tablet?" is answered the same way everywhere in the app.

---

# Note on Source

The Colour Library and Typography Library were each built from a dedicated master asset shipped in `design/assets/`. **No equivalent breakpoints/responsive-layout asset exists anywhere in this repository** — this was confirmed by searching the full asset tree and the repository's documentation for "breakpoint," "tablet" and "desktop" during the Sprint 1 Readiness Audit; nothing beyond the Sprint 1 handoff's own requirement to have breakpoints turned up.

Because there is nothing to extract, this document does not have a "values sourced from the asset library" section the way `colours.md` and `typography.md` do — the same situation as `spacing.md`, `radius.md`, `shadows.md`, `elevation.md` and (partially) `animations.md`. **Every value below is an Engineering Decision**, documented with its reasoning in that section.

---

# Design Principles

- **Never hardcode a breakpoint.** Every width comparison is reached through a named token, never a literal `if (width > 600)` inside feature code.
- **Three categories, not four.** Mobile, tablet and desktop are the whole scale. If a screen seems to need a fourth category, that's a design conversation, not a reason to add an ad hoc threshold.
- **Layout adapts; tokens don't.** Colour, typography, spacing, radius, shadow and elevation tokens are identical at every breakpoint — only the *layout* (column count, navigation pattern, max content width) changes between them. Breakpoints decide *which layout*, never *which token value*.
- **Reuse the spacing scale, don't duplicate it.** Where a breakpoint needs a padding value, it reuses a token already defined in `spacing.md` rather than introducing a new number that happens to look similar.

---

# Engineering Decisions

No breakpoints asset exists to source values from (see [Note on Source](#note-on-source)). Every value below is an explicit Qaddy engineering standard.

## Breakpoint Scale

| Token | Width | Device | Flutter Token Name |
|---|---|---|---|
| Mobile | 0–599px | Phones | `mobile` |
| Tablet | 600–1023px | Tablets / foldables | `tablet` |
| Desktop | 1024px+ | Desktop / large web | `desktop` |

**Reason:** these three cutoffs (0/600/1024) reuse Android's long-standing "smallest width" screen-size buckets (`sw600dp` / `sw1024dp`) — a decades-old, widely recognised convention for exactly this phone/tablet/desktop split. This is a deliberate correction from an earlier draft of this file, which attributed the scale to "Material Design 3 responsive guidelines." That citation was inaccurate: Material 3's own window-size-class system is a different, five-tier scale (compact/medium/expanded/large/extra-large, breaking at 600/840/1200/1600dp) built for a different purpose. Reusing the simpler, three-tier `sw600dp`/`sw1024dp` convention — rather than Qaddy inventing bespoke thresholds, and rather than mis-citing M3 — is what lets any engineer recognise these numbers on sight.

The ranges are contiguous with no gap and no overlap: every width from 0px upward resolves to exactly one of the three tokens.

## Layout Rules

Per-breakpoint layout behaviour. Side padding reuses `spacing.md` tokens directly — reference the named token below, not the raw pixel number.

| Property | Mobile | Tablet | Desktop |
|---|---|---|---|
| Columns (page layout) | Single column | Two columns where appropriate | Multi-column, centred |
| Navigation | Bottom navigation bar | Bottom navigation bar | Navigation rail (future) |
| Cards | Full width | 2 across where possible | 3–4 across, depending on content |
| Side padding | `spacing.md`'s `lg` / `cardPadding` (16px) | `spacing.md`'s `xl` / `pagePadding` (24px) | `spacing.md`'s `xxl` / `sectionGap` (32px) |
| Maximum content width | None (100% of viewport) | None (100% of viewport) | 1440px |

**Reason for reusing `spacing.md`'s tokens:** the side-padding values were already exactly `lg`, `xl` and `xxl` in `spacing.md`'s own scale — this document names that explicitly rather than restating 16/24/32 as if they were new, breakpoint-specific numbers. An engineer who already knows the spacing scale doesn't need to learn a second one.

**Reason for Desktop's 1440px maximum content width:** an unconstrained desktop layout becomes uncomfortably wide to read and visually thin on very large monitors — text lines get too long and cards spread too far apart. 1440px is a widely used content-width cap for exactly this reason. This is a Qaddy engineering decision, not sourced from any design asset, and is called out here rather than left as an unexplained number the way it was in the previous draft of this file.

## Grid

| Breakpoint | Columns |
|---|---|
| Mobile | 4 |
| Tablet | 8 |
| Desktop | 12 |

**Reason:** a 4/8/12-column progression is a widely used responsive-grid convention, where each larger breakpoint doubles or triples the previous column count. It was chosen because it divides cleanly into simple layout fractions (halves and quarters on mobile; halves, thirds and quarters on tablet and desktop), not because any design asset specifies it.

## Breakpoint-Independent Tokens

Typography, spacing, radius, shadow and elevation values do not change across breakpoints — only the layout properties above do. Images scale responsively and must maintain their aspect ratio at every breakpoint; never stretch an image to fill a wider column.

---

# Rules

- Never hardcode a screen-width threshold. If a widget seems to need a breakpoint that isn't above, that's a design conversation, not a reason to write a literal number.
- Reference `spacing.md`'s tokens for per-breakpoint padding — don't reintroduce 16/24/32 as if they were breakpoint-specific values.
- Only the three categories above exist. Don't add a fourth without updating this document first.

---

# Flutter Implementation

Breakpoints are plain width thresholds compared against `MediaQuery`, not a `ThemeExtension` like `QaddyColours` or `QaddySpacing` — there's no themed value to look up, only a comparison to make. Every token above should exist as a named constant/helper on a single class (e.g. `QaddyBreakpoints`):

```dart
class QaddyBreakpoints {
  const QaddyBreakpoints._();

  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet &&
      MediaQuery.sizeOf(context).width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}
```

Never write a literal `MediaQuery.sizeOf(context).width > 600` inline — use `QaddyBreakpoints.isTablet(context)` (or the constant directly) instead.

## Token reference

| Flutter Token Name | Lower bound (px) | Upper bound (px) |
|---|---|---|
| `mobile` | 0 | 599 |
| `tablet` | 600 | 1023 |
| `desktop` | 1024 | — (no upper bound) |

| Layout property | Mobile | Tablet | Desktop |
|---|---|---|---|
| Side padding | `spacing.lg` (16) | `spacing.xl` (24) | `spacing.xxl` (32) |
| Grid columns | 4 | 8 | 12 |
| Max content width | none | none | 1440 |

## Example

```
Phone layout
Flutter Token: mobile

Tablet layout
Flutter Token: tablet

Desktop layout
Flutter Token: desktop
```

---

Version 2.0
