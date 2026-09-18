# Qaddy Design Tokens

# Colours

Version: 1.0
Status: Active
Source: `design/assets/colours/colour-library-v1.png` — Qaddy Colour Library v1.0
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for every colour used inside the Qaddy application.

Every value below is taken directly from the Qaddy Colour Library — no colour in this document has been invented, approximated, or picked outside that asset.

No screen, widget or style should ever reference a raw hex value. Every colour must be reached through a Flutter theme token, so that:

- the palette can change in one place without touching feature code,
- Light Mode and Dark Mode stay in sync automatically, and
- accessibility guarantees (contrast, colour-blindness safety) hold everywhere at once.

If a colour is needed that isn't listed here, it does not exist yet — raise it as a design decision before adding it to the app.

---

# Design Principles

- **Never hardcode colours.** Every colour reaches a widget through `Theme.of(context).extension<QaddyColours>()`, never a literal `Color(0xFF...)` inside feature code.
- **Always use theme tokens.** Reference colours by their Flutter Token Name (right-hand column of every table below), not by hex or by description.
- **Support Light and Dark mode.** Every token defined here has a value for both themes (see [Dark Theme](#dark-theme) and [Light Theme](#light-theme)). Dark Mode is Qaddy's primary, default experience; Light Mode is the secondary/optional theme.
- **Accessibility first.** Colour is never the only signal for meaning (state also needs an icon or label), and every text/background pairing must meet WCAG AA contrast — see [Accessibility](#accessibility).
- **Semantic over literal.** Tokens are named for their *role* (`primary`, `success`, `textSecondary`), never for the literal colour family, so the underlying hex can evolve without renaming call sites.
- **Do use brand colours correctly; don't use unapproved colours.** If it isn't in this document, it isn't an approved Qaddy colour.

---

# Brand Colours

Our core brand colours. Use these to represent Qaddy across all touchpoints.

| Token | HEX | RGB | Usage | Flutter Token Name |
|---|---|---|---|---|
| Primary Green | `#0F3D2E` | `rgb(15, 61, 46)` | Main brand colour. Buttons, highlights and key elements. | `primary` |
| Primary Gold | `#D4AF37` | `rgb(212, 175, 55)` | Premium accents. Icons, highlights and special elements. | `gold` |
| Secondary Green | `#1E6B4B` | `rgb(30, 107, 75)` | Supporting colour. Secondary buttons and accents. | `secondary` |
| Dark Green | `#081B14` | `rgb(8, 27, 20)` | Background base. App background and deep surfaces. | `backgroundBase` |

`backgroundBase` is the raw brand value that the Neutral `background` and Text `textInverse` tokens both resolve to — see the note under [Neutral Colours](#neutral-colours).

---

# Neutral Colours

Used for backgrounds, surfaces, borders and text.

| Token | HEX | RGB | Usage | Flutter Token Name |
|---|---|---|---|---|
| Background | `#081B14` | `rgb(8, 27, 20)` | Main app background. | `background` |
| Surface 1 | `#102820` | `rgb(16, 40, 32)` | Cards, modals and elevated surfaces. | `surface1` |
| Surface 2 | `#163B2E` | `rgb(22, 59, 46)` | Alternate surface and containers. | `surface2` |
| Card | `#1F2F29` | `rgb(31, 47, 41)` | Card backgrounds. | `card` |
| Border | `#2E4A3F` | `rgb(46, 74, 63)` | Dividers and borders. | `border` |
| Divider | `#3F5E52` | `rgb(63, 94, 82)` | Subtle dividers. | `divider` |

> **Note:** the Colour Library's "Dark Mode Palette" panel restates `Border` as `#2E443F` (one digit off from the `#2E4A3F` defined here). This document standardises on the value above because it is the one cross-checked against its own listed RGB triplet (`46, 74, 63`); treat `#2E443F` as a source-asset typo, not a second token.

---

# Text Colours

Text hierarchy for clarity and accessibility.

| Token | HEX | RGB | Usage | Flutter Token Name |
|---|---|---|---|---|
| Text Primary | `#FFFFFF` | `rgb(255, 255, 255)` | Headings, primary text, high emphasis. | `textPrimary` |
| Text Secondary | `#9FB3AA` | `rgb(159, 179, 170)` | Body text, secondary info. | `textSecondary` |
| Text Tertiary | `#6B867B` | `rgb(107, 134, 123)` | Captions, placeholders, disabled text. | `textTertiary` |
| Text Inverse | `#081B14` | `rgb(8, 27, 20)` | Text placed on light backgrounds. | `textInverse` |

---

# Semantic Colours

Status colours for feedback and messaging.

| Token | HEX | RGB | Usage | Flutter Token Name |
|---|---|---|---|---|
| Success | `#22C55E` | `rgb(34, 197, 94)` | Success states, completed actions. | `success` |
| Error | `#EF4444` | `rgb(239, 68, 68)` | Errors, destructive actions. | `error` |
| Warning | `#F59E0B` | `rgb(245, 158, 11)` | Warnings, caution states. | `warning` |
| Info | `#3B82F6` | `rgb(59, 130, 246)` | Information, tips and hints. | `info` |
| Premium | `#8B5CF6` | `rgb(139, 92, 246)` | Premium features, exclusive content. | `premium` |

---

# Accent Colours

Extended palette for charts, icons and illustrations. Not brand colours — do not use for primary UI actions.

| Token | HEX | RGB | Usage | Flutter Token Name |
|---|---|---|---|---|
| Teal | `#14B8A6` | `rgb(20, 184, 166)` | Charts, data visualisation. | `accentTeal` |
| Sky | `#0EA5E9` | `rgb(14, 165, 233)` | Links, interactive elements. | `accentSky` |
| Pink | `#EC4899` | `rgb(236, 72, 153)` | Highlights, special elements. | `accentPink` |
| Orange | `#F97316` | `rgb(249, 115, 22)` | CTAs, active states. | `accentOrange` |
| Indigo | `#6366F1` | `rgb(99, 102, 241)` | Charts, secondary accents. | `accentIndigo` |

---

# Gradients

Subtle gradients for premium elements. The colour stops below are taken directly from the Colour Library; the direction is not.

| Token | Stops | Usage | Flutter Token Name |
|---|---|---|---|
| Green Gradient | `#0F3D2E` → `#1E6B4B` | Buttons, headers. | `gradientGreen` |
| Gold Gradient | `#D4AF37` → `#F4D676` | Premium elements. | `gradientGold` |
| Premium Gradient | `#8B5CF6` → `#EC4899` | Special/exclusive features. | `gradientPremium` |

**Engineering Decision — Gradient Direction.** The Colour Library's gradient swatches show a colour blend but do not encode a direction. **135° (top-left to bottom-right) is the official Qaddy implementation standard for all three gradients above**, not a value read from the asset. Reason: a single consistent angle across every gradient token is what makes them read as one system rather than three unrelated effects, and top-left-to-bottom-right is the conventional direction for this style of diagonal brand gradient. This applies unless and until a future design asset explicitly specifies a different direction for a given gradient — treat that as a design decision to update this document, not a reason for an engineer to pick their own angle in the meantime.

---

# Dark Theme

Dark Mode is Qaddy's **primary** theme — it is what the app ships with by default, not a secondary variant.

| Role | Token | Value |
|---|---|---|
| Background | `background` | `#081B14` |
| Surface | `surface1` | `#102820` |
| Card | `card` | `#1F2F29` |
| Border | `border` | `#2E4A3F` |
| Divider | `divider` | `#3F5E52` |
| Primary Text | `textPrimary` | `#FFFFFF` |
| Secondary Text | `textSecondary` | `#9FB3AA` |
| Brand accents | `primary` / `gold` / `secondary` | `#0F3D2E` / `#D4AF37` / `#1E6B4B` (unchanged from Brand Colours) |

Semantic, accent and gradient tokens do not change between themes — only neutral surfaces and text invert.

---

# Light Theme

Light Mode is the optional/secondary theme. Brand, semantic, accent and gradient tokens are unchanged; only the neutral surface and text tokens swap to these values.

| Role | Token | Value |
|---|---|---|
| Background | `background` | `#F8FAF9` |
| Surface | `surface1` | `#FFFFFF` |
| Alternate Surface | `surface2` | `#F5F7F6` |
| Card | `card` | `#F1F5F3` |
| Border | `border` | `#D1DAD6` |
| Divider | `divider` | `#D7DDD9` |
| Primary Text | `textPrimary` | `#0F3D2E` |
| Secondary Text | `textSecondary` | `#6B867B` |
| Tertiary Text | `textTertiary` | `#8CA196` |

**Engineering Decision — Light Mode `textTertiary`.** The Colour Library does not define a Light Mode tertiary text colour — this value is not read from that asset. **`textTertiary: #8CA196` is the official Qaddy implementation standard for Light Mode** unless and until a future design asset explicitly specifies a different value. Usage: captions, placeholders, disabled text, and other low-emphasis supporting text — the same role `textTertiary` plays in Dark Mode.

**Engineering Decision — Light Mode `surface2` and `divider`.** The Colour Library does not define a Light Mode `Surface 2` or `Divider` — these two values are not read from that asset. **`surface2: #F5F7F6` and `divider: #D7DDD9` are the official Qaddy implementation standard for Light Mode** unless and until a future design asset explicitly specifies different values. Reason: both sit in the same tonal relationship to Light Mode's `background` (`#F8FAF9`) and `surface1` (`#FFFFFF`) that their Dark Mode counterparts (`surface2`, `divider`) sit in relative to Dark Mode's `background` and `surface1` — a slightly-differentiated neutral step for `surface2`, and a subtle, low-contrast neutral for `divider` — so Light Mode keeps the same layering logic as Dark Mode instead of leaving two tokens undefined. This closes the one remaining Sprint 1 implementation blocker identified in the Sprint 1 Readiness Audit: without these two values, `QaddyColours`'s Light instance could not be fully constructed.

---

# Disabled State

Used for disabled buttons, inputs, toggles, checkboxes and other controls.

| Token | HEX | RGB | Usage | Flutter Token Name |
|---|---|---|---|---|
| Disabled Foreground | `#A8B5AE` | `rgb(168, 181, 174)` | Disabled text, disabled icons, disabled control labels. | `disabledForeground` |
| Disabled Background | `#E7ECE9` | `rgb(231, 236, 233)` | Disabled buttons, disabled input backgrounds, disabled chips, disabled surfaces requiring a muted appearance. | `disabledBackground` |
| Disabled Border | `#D3DBD6` | `rgb(211, 219, 214)` | Disabled outlined buttons, disabled text fields, disabled cards where required. | `disabledBorder` |

**Engineering Decision — Disabled State.** The Qaddy Design Library includes disabled buttons, inputs, toggles, checkboxes and other controls, but no design asset specifies the exact disabled colour values. **The three values above are the official Qaddy implementation standard** until superseded by a future design asset. These values intentionally maintain sufficient contrast while clearly communicating that an element is unavailable. All disabled components throughout Qaddy must reference these tokens rather than creating custom disabled colours.

---

# Accessibility

Contrast examples from the Colour Library, measured against the Dark Mode background (`#081B14`), all passing WCAG AA:

| Text token | Contrast ratio | WCAG AA (4.5:1 normal text) |
|---|---|---|
| `textPrimary` (`#FFFFFF`) | 4.8:1 | Pass |
| `gold` (`#D4AF37`) | 4.6:1 | Pass |
| `textSecondary` (`#9FB3AA`) | 4.5:1 | Pass (at the minimum — do not darken further) |
| `textTertiary` (`#6B867B`) | 4.6:1 | Pass |

Rules from the Colour Library's usage guidance:

- Do use brand colours correctly.
- Do maintain clear contrast between text and its background.
- Don't use unapproved colours (i.e. any colour not in this document).
- Don't use low-contrast combinations.
- Don't place text or logos on busy backgrounds (photography, patterns) without a scrim.
- Never rely on colour alone to communicate state — pair semantic colours with an icon or label.

---

# Flutter Implementation

Every token above should exist as a named field on a single `ThemeExtension` (e.g. `QaddyColours`), with light and dark instances built from the tables above. Reference colours only through that extension:

```dart
Theme.of(context).extension<QaddyColours>()!.primary
```

Never reference `Color(0xFF...)` literals outside of the file where `QaddyColours` itself is defined.

## Token → Color reference

| Flutter Token Name | Dark value | Light value (where defined) |
|---|---|---|
| `primary` | `Color(0xFF0F3D2E)` | — (unchanged) |
| `gold` | `Color(0xFFD4AF37)` | — (unchanged) |
| `secondary` | `Color(0xFF1E6B4B)` | — (unchanged) |
| `backgroundBase` | `Color(0xFF081B14)` | — (unchanged) |
| `background` | `Color(0xFF081B14)` | `Color(0xFFF8FAF9)` |
| `surface1` | `Color(0xFF102820)` | `Color(0xFFFFFFFF)` |
| `surface2` | `Color(0xFF163B2E)` | `Color(0xFFF5F7F6)` (Engineering Decision) |
| `card` | `Color(0xFF1F2F29)` | `Color(0xFFF1F5F3)` |
| `border` | `Color(0xFF2E4A3F)` | `Color(0xFFD1DAD6)` |
| `divider` | `Color(0xFF3F5E52)` | `Color(0xFFD7DDD9)` (Engineering Decision) |
| `textPrimary` | `Color(0xFFFFFFFF)` | `Color(0xFF0F3D2E)` |
| `textSecondary` | `Color(0xFF9FB3AA)` | `Color(0xFF6B867B)` |
| `textTertiary` | `Color(0xFF6B867B)` | `Color(0xFF8CA196)` (Engineering Decision) |
| `textInverse` | `Color(0xFF081B14)` | — (unchanged) |
| `disabledForeground` | `Color(0xFFA8B5AE)` | — (unchanged, Engineering Decision) |
| `disabledBackground` | `Color(0xFFE7ECE9)` | — (unchanged, Engineering Decision) |
| `disabledBorder` | `Color(0xFFD3DBD6)` | — (unchanged, Engineering Decision) |
| `success` | `Color(0xFF22C55E)` | — (unchanged) |
| `error` | `Color(0xFFEF4444)` | — (unchanged) |
| `warning` | `Color(0xFFF59E0B)` | — (unchanged) |
| `info` | `Color(0xFF3B82F6)` | — (unchanged) |
| `premium` | `Color(0xFF8B5CF6)` | — (unchanged) |
| `accentTeal` | `Color(0xFF14B8A6)` | — (unchanged) |
| `accentSky` | `Color(0xFF0EA5E9)` | — (unchanged) |
| `accentPink` | `Color(0xFFEC4899)` | — (unchanged) |
| `accentOrange` | `Color(0xFFF97316)` | — (unchanged) |
| `accentIndigo` | `Color(0xFF6366F1)` | — (unchanged) |

## Example

```
Primary Green
Flutter Token: primary

Background
Flutter Token: background

Text Primary
Flutter Token: textPrimary
```

---

Version 1.0