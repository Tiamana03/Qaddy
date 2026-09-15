# Qaddy Design Tokens

# Elevation

Version: 2.0
Status: Active
Source: No dedicated elevation asset exists in `design/assets/` — see [Note on Source](#note-on-source). Every value below is an Engineering Decision.
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for how surfaces stack, one above another, throughout the Qaddy application.

Elevation is a *layering* concept — it says which surfaces sit above which — and is distinct from, but closely related to, `shadows.md`, which defines how each layer is visually rendered (offset/blur/opacity). No screen or widget should assign a raw `elevation` value or invent a new stacking order; every layer must be reached through a Flutter theme token, so "what's on top of what" stays predictable across the whole app.

---

# Note on Source

The Colour Library and Typography Library were each built from a dedicated master asset shipped in `design/assets/`. **No equivalent elevation asset exists anywhere in this repository**, and none of the UI-component sheets checked while building `shadows.md` (Buttons, Cards, Dialogs, Forms, Navigation, Charts) annotate a numeric elevation value either.

Because there is nothing to extract, this document does not have a "values sourced from the asset library" section the way `colours.md` and `typography.md` do — the same situation as `spacing.md`, `radius.md` and `shadows.md`. **Every value below is an Engineering Decision**, documented with its reasoning in that section.

---

# Design Principles

- **Elevation is ordering, not decoration.** This file answers "does the Dialog render above the Navigation bar?" — it does not itself define how heavy a shadow looks. That's `shadows.md`'s job; the two are cross-referenced below rather than duplicated.
- **Keep elevation minimal.** Only use a higher level when a surface genuinely needs to sit above another — don't reach for elevation to fake visual emphasis that a colour or typography token should carry instead.
- **Never stack shadow effects.** A surface has exactly one elevation level and therefore exactly one shadow token (from `shadows.md`) — never layer two shadows on the same surface to make it "extra" elevated.
- **Elevated components stay visually lightweight.** Higher elevation should read as "closer to the user," not "heavier" — consistent with the Design Bible's rule against heavy shadows.

---

# Engineering Decisions

No elevation asset exists to source values from (see [Note on Source](#note-on-source)). Every value below is an explicit Qaddy engineering standard.

## Elevation Scale

The six levels reuse Material Design 3's standard elevation scale (0 / 1 / 3 / 6 / 8 / 12 logical pixels). Flutter's Material widgets (`Card`, `AppBar`, `NavigationBar`, `Dialog`, etc.) are already built around exactly this scale for their own `elevation` property — reusing it means Qaddy's elevation stays compatible with how those widgets already animate and layer, instead of inventing a bespoke numbering system that fights the framework.

| Level | Elevation (dp) | Component | Shadow Token (`shadows.md`) | Usage | Flutter Token Name |
|---|---|---|---|---|---|
| 0 | 0 | Background | `none` | The base app background — nothing sits below it. | `level0` |
| 1 | 1 | Cards | `medium` | Qaddy's most common elevated surface. | `level1` |
| 2 | 3 | Navigation | `small` | Bottom navigation and the top app bar — persistent chrome that sits above page content but below any card the user has opened. | `level2` |
| 3 | 6 | Floating Action Button | `extraLarge` | A FAB floats above cards and navigation, but below anything modal. | `level3` |
| 4 | 8 | Dialog | `large` | A dialog interrupts the current screen and must render above everything on it, including any FAB. | `level4` |
| 5 | 12 | Modal | `extraLarge` | Full-screen or near-full-screen modals (e.g. a large bottom sheet) — the top of the stack. | `level5` |

Note on the Shadow Token column: elevation *level* (this file) and shadow *weight* (`shadows.md`) are related but independently decided — `level3` (FAB) and `level5` (Modal) intentionally share the `extraLarge` shadow token even though they sit at different points in the stacking order, because they are visually similar in weight even though one always renders structurally above the other (via widget/`Navigator`/`Overlay` order, not via a heavier shadow). Don't infer stacking order from shadow weight; use the Level/Elevation columns for that.

---

# Rules

- Never hardcode an elevation value. If a surface seems to need a level that isn't above, that's a design conversation, not a reason to invent a number between two levels.
- A surface gets exactly one elevation level and the one shadow token that level maps to — never combine two.
- Keep elevation consistent across all screens and both themes; elevation levels do not change between Light and Dark Mode (only the rendered shadow's visual prominence differs — see `shadows.md`'s Dark Mode vs. Light Mode note).

---

# Flutter Implementation

Every level above should exist as a named field on a single `ThemeExtension` (e.g. `QaddyElevation`), consistent with the approach taken for `QaddyColours`, `QaddyTypography`, `QaddySpacing`, `QaddyRadius` and `QaddyShadows`. Reference elevation only through that extension:

```dart
Card(
  elevation: Theme.of(context).extension<QaddyElevation>()!.level1,
  // For a custom-painted surface instead of a Material widget's own
  // `elevation` property, pair the same level with its shadow token:
  // decoration: BoxDecoration(boxShadow: shadows.medium),
)
```

Never write a literal `elevation: 6` for a widget that has a token above — use the token's value instead.

## Token reference

| Flutter Token Name | Elevation (dp) | Paired Shadow Token |
|---|---|---|
| `level0` | 0 | `none` |
| `level1` | 1 | `medium` |
| `level2` | 3 | `small` |
| `level3` | 6 | `extraLarge` |
| `level4` | 8 | `large` |
| `level5` | 12 | `extraLarge` |

## Example

```
Cards
Flutter Token: level1

Navigation
Flutter Token: level2

Dialog
Flutter Token: level4

Modal
Flutter Token: level5
```

---

Version 2.0
