# Qaddy Design Tokens

# Shadows

Version: 2.0
Status: Active
Source: No dedicated shadow asset exists in `design/assets/` — see [Note on Source](#note-on-source). Every value below is an Engineering Decision.
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for every drop shadow used inside the Qaddy application.

No screen or widget should set a `BoxShadow` as a literal set of numbers. Every shadow must be reached through a Flutter theme token, so elevation reads consistently everywhere it appears and stays "soft," per the Design Bible's explicit rule against heavy shadows.

---

# Note on Source

The Colour Library and Typography Library were each built from a dedicated master asset shipped in `design/assets/`. **No equivalent shadow asset exists anywhere in this repository.**

This was confirmed by searching the full asset tree for anything shadow- or elevation-related — nothing matches. It was also checked against the closest adjacent assets: the Buttons, Cards, Dialogs, Forms, Navigation and Charts UI-component libraries all render elevated surfaces in their mock-ups, and Card Guidelines says, in text, to "use consistent border radius and shadows" — but none of them prints an offset, blur radius or opacity anywhere on the sheet. The previous version of this file reflected that: it named five shadow levels with a one-word usage each, but no `BoxShadow` could actually be built from it.

Because there is nothing to extract, this document does not have a "values sourced from the asset library" section the way `colours.md` and `typography.md` do — the same situation as `spacing.md` and `radius.md`. **Every value below is an Engineering Decision**, documented with its reasoning in that section.

---

# Design Principles

- **Never hardcode a shadow.** Every `BoxShadow` is reached through a named shadow token, never literal offset/blur/opacity values inside feature code.
- **Soft over heavy.** Per the Design Bible: "Avoid heavy shadows. Use soft elevation." Every level in this scale uses a low opacity and a soft (large blur relative to offset) shadow — none of them should read as a hard drop-shadow.
- **Shadow is not the only elevation signal.** In Dark Mode especially, a black shadow barely reads against a dark background — Qaddy communicates elevation primarily through the layered surface colours already defined in `colours.md` (`background` → `surface1` → `surface2` → `card`, each progressively lighter), with shadow as a secondary, subtle reinforcement. See [Dark Mode vs. Light Mode](#dark-mode-vs-light-mode).
- **One scale, shared by every component type.** Buttons, cards, dialogs and floating elements all draw from the same five-level scale — there is no component-specific shadow that isn't one of these tokens.

---

# Engineering Decisions

No shadow asset exists to source values from (see [Note on Source](#note-on-source)). Every value below is an explicit Qaddy engineering standard.

## Shadow Scale

Each level increases offset, blur and opacity together in a steady progression, so each step reads as a clear, deliberate increase in elevation rather than a subtle, easy-to-miss difference. Blur radius is always kept large relative to the vertical offset — this is what keeps every level "soft" rather than a hard, cheap-looking drop shadow.

| Token | Offset (x, y) | Blur Radius | Spread Radius | Colour & Opacity | Usage | Flutter Token Name |
|---|---|---|---|---|---|---|
| None | (0, 0) | 0 | 0 | — (no shadow) | Flat surfaces: the base background, full-bleed content with no elevation. | `none` |
| Small | (0, 1) | 2 | 0 | `#000000` @ 12% | Buttons — just enough lift to feel tappable without competing with page content. | `small` |
| Medium | (0, 4) | 8 | 0 | `#000000` @ 16% | Cards — Qaddy's most common elevated surface. | `medium` |
| Large | (0, 8) | 16 | 0 | `#000000` @ 20% | Dialogs — clearly above page content, since a dialog demands full attention. | `large` |
| Extra Large | (0, 16) | 24 | 0 | `#000000` @ 24% | Floating elements: floating action buttons, bottom sheets, anything that visually hovers over everything else. | `extraLarge` |

Reason: offset and blur both roughly double at each step (1→4→8→16 for offset, 2→8→16→24 for blur) while opacity climbs in even 4-point steps (12%→16%→20%→24%). A single, predictable progression is what makes the scale easy to reason about and easy to extend later without guesswork about where a new level would sit.

## Dark Mode vs. Light Mode

Qaddy is Dark Mode-first (see `colours.md`). A black shadow at these opacities is intentionally subtle against the dark backgrounds defined there — this is deliberate, not a mistake: in Dark Mode, elevation is carried mainly by `colours.md`'s layered surface tokens (`background` → `surface1` → `surface2` → `card`, each a lighter tint of the same dark green), and the shadow scale here adds a secondary, gentle reinforcement rather than doing the primary work.

In Light Mode, surfaces are much closer to white throughout (see `colours.md`'s Light Theme values), so the same shadow scale carries proportionally more of the elevation signal. The same tokens and values apply in both themes — no separate light/dark shadow values are defined — because the opacities above were chosen to already read correctly against both.

---

# Rules

- Never hardcode a shadow value. If a component seems to need elevation that isn't one of the five levels above, that's a design conversation, not a reason to write a literal `BoxShadow`.
- Don't stack multiple shadow tokens on one surface — each component gets exactly one shadow level, matching its own elevation, not a combination.
- Keep shadows consistent across all screens; use the same token for the same component type everywhere it appears.

---

# Flutter Implementation

Every token above should exist as a named field on a single `ThemeExtension` (e.g. `QaddyShadows`), consistent with the approach taken for `QaddyColours`, `QaddyTypography`, `QaddySpacing` and `QaddyRadius`. Reference shadows only through that extension:

```dart
Theme.of(context).extension<QaddyShadows>()!.medium
```

Never write a literal `BoxShadow(...)` list for a surface that has a token above — use the token's value instead, e.g. `boxShadow: shadows.medium` on a `Card`'s decoration.

## Token reference

`color` is expressed as `Color.fromRGBO(0, 0, 0, opacity)`; `offset` and `blurRadius` are in logical pixels.

| Flutter Token Name | offset | blurRadius | spreadRadius | color |
|---|---|---|---|---|
| `none` | `Offset(0, 0)` | 0 | 0 | — (empty `boxShadow: []`) |
| `small` | `Offset(0, 1)` | 2 | 0 | `Color.fromRGBO(0, 0, 0, 0.12)` |
| `medium` | `Offset(0, 4)` | 8 | 0 | `Color.fromRGBO(0, 0, 0, 0.16)` |
| `large` | `Offset(0, 8)` | 16 | 0 | `Color.fromRGBO(0, 0, 0, 0.20)` |
| `extraLarge` | `Offset(0, 16)` | 24 | 0 | `Color.fromRGBO(0, 0, 0, 0.24)` |

## Example

```
Buttons
Flutter Token: small

Cards
Flutter Token: medium

Dialogs
Flutter Token: large

Floating elements
Flutter Token: extraLarge
```

---

Version 2.0
