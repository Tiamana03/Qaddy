# Qaddy Design Tokens

# Border Radius

Version: 2.0
Status: Active
Source: No dedicated radius asset exists in `design/assets/` — see [Note on Source](#note-on-source). Every value below is an Engineering Decision.
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for every corner radius used inside the Qaddy application.

No screen or widget should set a `BorderRadius` as a literal number. Every corner radius must be reached through a Flutter theme token, so the app's rounded, premium visual language (per the Design Bible) stays consistent everywhere it appears.

---

# Note on Source

The Colour Library and Typography Library were each built from a dedicated master asset shipped in `design/assets/`. **No equivalent radius/corner asset exists anywhere in this repository.**

This was confirmed by searching the full asset tree for anything radius-related — nothing matches. It was also confirmed against the closest adjacent assets: the Buttons, Cards, Dialogs and Forms UI-component libraries (`design/ui-components/*/*-library-v1.png`) all show rounded corners in their mock-ups and all say, in text, to "use consistent border radius" — but none of them prints an actual radius number anywhere on the sheet.

Because there is nothing to extract, this document does not have a "values sourced from the asset library" section the way `colours.md` and `typography.md` do — the same situation as `spacing.md`. **Every value below is an Engineering Decision**, documented with its reasoning in that section.

---

# Design Principles

- **Never hardcode radius.** Every `BorderRadius` is reached through a named radius token, never a literal `BorderRadius.circular(16)` inside feature code.
- **One scale, shared by every component type.** Cards, buttons, dialogs, sheets and chips all draw from the same five-value scale — there is no card-specific or button-specific radius that isn't one of these tokens.
- **Rounder for bigger surfaces.** Radius increases with the size of the surface it's applied to (a button gets less rounding than the bottom sheet it might open), which is what keeps proportionally-similar rounding across very differently sized components — a large radius on a small control reads as a pill or a blob, not as "rounded."
- **Consistent with the spacing grid.** The scale is built on the same 8px base unit as `spacing.md`, so radius and spacing decisions reinforce one visual rhythm rather than defining two unrelated ones.

---

# Engineering Decisions

No radius asset exists to source values from (see [Note on Source](#note-on-source)). Every value below is an explicit Qaddy engineering standard.

## Radius Scale

| Token | Value | Reason | Usage | Flutter Token Name |
|---|---|---|---|---|
| Small | 8px | Matches the `sm` spacing step (`spacing.md`) — the smallest radius that still reads as "rounded" rather than sharp at small control sizes. | Compact controls: input fields, badges, tags, small chips-as-filters. | `small` |
| Medium | 16px | Matches the `lg` spacing step — enough rounding to feel premium on a control the size of a button without looking like a pill. | Buttons. | `medium` |
| Large | 24px | Matches the `xl` spacing step — the scale's default for the app's most common elevated surface. | Cards, dialogs. | `large` |
| Extra Large | 32px | Matches the `xxl` spacing step — visibly rounder than `large`, reserved for full-width surfaces that need to feel soft against the whole screen edge. | Bottom sheets. | `extraLarge` |
| Pill | 999px | A value larger than any realistic component height forces `BorderRadius.circular` to cap at a true stadium/pill shape, regardless of the component's actual size — this is a standard trick for "fully rounded," not a literal 999px radius ever being reached. | Chips, fully-rounded status pills. | `pill` |

Reason for the scale as a whole: reusing the exact numeric values already defined in `spacing.md` (8/16/24/32) means a Flutter engineer who already knows the spacing scale already knows the radius scale — there is nothing new to memorise, and the two token systems visibly agree with each other instead of coincidentally almost matching.

---

# Rules

- Never hardcode a radius value. If a component seems to need a radius that isn't above, that's a design conversation, not a reason to write a literal number.
- Don't mix radius tokens on a single component's different corners unless a mockup explicitly shows an asymmetric shape (e.g. a bottom sheet rounded only at the top) — the default is uniform rounding on all four corners.
- Keep radius consistent across all screens and both themes; radius does not change between Light and Dark Mode.

---

# Flutter Implementation

Every token above should exist as a named field on a single `ThemeExtension` (e.g. `QaddyRadius`), consistent with the approach taken for `QaddyColours`, `QaddyTypography` and `QaddySpacing`. Reference radius only through that extension:

```dart
Theme.of(context).extension<QaddyRadius>()!.large
```

Never write a literal `BorderRadius.circular(24)` for a shape that has a token above — use the token's value instead, e.g. `BorderRadius.circular(radius.large)`.

## Token reference

| Flutter Token Name | Value (logical pixels) |
|---|---|
| `small` | 8 |
| `medium` | 16 |
| `large` | 24 |
| `extraLarge` | 32 |
| `pill` | 999 |

## Example

```
Cards
Flutter Token: large

Buttons
Flutter Token: medium

Bottom Sheets
Flutter Token: extraLarge

Chips
Flutter Token: pill
```

---

Version 2.0
