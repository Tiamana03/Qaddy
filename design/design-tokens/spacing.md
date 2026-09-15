# Qaddy Design Tokens

# Spacing

Version: 2.0
Status: Active
Source: No dedicated spacing/layout asset exists in `design/assets/` — see [Note on Source](#note-on-source). Every value below is an Engineering Decision.
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for every spacing value used inside the Qaddy application — padding, margins, gaps between elements, and the space between sections.

No screen or widget should set a padding, margin or gap as a literal number. Every spacing value must be reached through a Flutter theme token, so that layout rhythm stays consistent across every screen and can be re-tuned from one place.

---

# Note on Source

The Colour Library (`colours.md`) and Typography Library (`typography.md`) were each built from a dedicated master asset shipped in `design/assets/`. **No equivalent spacing or layout asset exists anywhere in this repository.**

This was confirmed by searching the full asset tree: `design/assets/` contains `app-store/`, `colours/`, `icons/`, `illustrations/`, `logos/`, `marketing/`, `splash/` and `typography/` — no `spacing/`, `layout/` or `grid/` folder, and no `*-library-v1.png` anywhere else defines a spacing scale. The closest adjacent reference, the Buttons Library (`design/ui-components/buttons/buttons-library-v1.png`), specifies three *button heights* (Large 56px, Medium 48px, Small 40px) — a sizing spec for that component, not a general-purpose spacing scale, and out of scope for this file.

Because there is nothing to extract, this document does not have a "values sourced from the asset library" section the way `colours.md` and `typography.md` do. **Every value below is an Engineering Decision**, documented with its reasoning in that section — none of it should be read as derived from a design asset.

---

# Design Principles

- **Never hardcode spacing.** Every padding, margin and gap is reached through a named spacing token, never a literal number inside feature code.
- **One base unit.** Every token in the scale is a multiple of a single 4px base unit, so any two spacing values in the app either divide evenly into one another or share a common factor — nothing sits at an arbitrary in-between size.
- **Fewer values, used consistently.** A small, well-understood scale beats a large one nobody fully learns. If a screen seems to need a spacing value that isn't below, that's a signal to reuse the nearest token, not to introduce a new one.
- **Spacing communicates hierarchy.** Larger gaps separate less-related content (between sections); smaller gaps group related content (inside a card). Consistent use of the scale is itself part of how Qaddy "feels" premium and calm, per the Design Bible.

---

# Engineering Decisions

The Typography and Colour Libraries each ship a dedicated master asset in `design/assets/` that this project's token docs transcribe values from. **No equivalent asset exists for spacing** — so unlike `colours.md` and `typography.md`, nothing in this file is "sourced" in that sense. Every value below is an explicit Qaddy engineering standard, chosen for the reasons stated, not read off a design artefact.

## Base Unit & Scale

Qaddy adopts a **4px base unit**. The scale stays a strict multiple of 4 throughout, moving in 4px steps while values are small (where the difference between adjacent steps is visually significant — icon padding vs. compact layout padding) and in 8px-or-larger steps once values are large enough that finer granularity stops being useful. This also keeps every token from `xl` upward a multiple of 8px, consistent with the 8px vertical rhythm already adopted for the `statHoleNumber` typography token (see `typography.md`'s Engineering Decisions) — the two scales reinforce the same underlying grid rather than defining two incompatible rhythms.

| Token | Value | Step from previous | Usage | Flutter Token Name |
|---|---|---|---|---|
| XS | 4px | — | Tiny spacing: icon padding, space between an icon and its adjacent label. | `xs` |
| SM | 8px | +4px | Small gaps: space between closely related inline elements (e.g. a chip's internal padding). | `sm` |
| MD | 12px | +4px | Compact layouts: internal padding for dense components, gaps within a tight list. | `md` |
| LG | 16px | +4px | Standard spacing: default card padding, standard gaps between list items. | `lg` |
| XL | 24px | +8px | Section-level spacing: default screen/page padding, padding around major content blocks. | `xl` |
| XXL | 32px | +8px | Large sections: separation between distinct sections on a screen. | `xxl` |
| XXXL | 40px | +8px | Major separation: separation between unrelated content groups. | `xxxl` |
| Display | 48px | +8px | Hero layouts: padding around hero/feature content. | `display` |
| Hero | 64px | +16px | Landing screens: generous top-level padding for splash/onboarding/landing screens. | `hero` |

Reason: a single base unit keeps every spacing decision reducible to "how many steps on the grid," which is what makes a spacing scale enforceable in review rather than a matter of taste. The step size widens as values grow because the perceptual difference between, say, 4px and 8px matters a great deal at icon scale, while the difference between 56px and 60px would not — there is no benefit to that level of granularity at the "hero" end of the scale, only more tokens to remember.

## Semantic Spacing Aliases

These are named for their *role*, not their value, so a future re-tuning of "how much page padding Qaddy uses" changes one alias instead of every call site that happens to reference `xl`.

| Alias | Resolves to | Usage | Flutter Token Name |
|---|---|---|---|
| Page Padding | XL (24px) | Default horizontal padding for a screen's content area. | `pagePadding` |
| Card Padding | LG (16px) | Default internal padding for a card or elevated surface. | `cardPadding` |
| Button Padding | MD (12px) | Default internal padding for a button's content. | `buttonPadding` |
| Section Gap | XXL (32px) | Default vertical gap between distinct sections on a screen. | `sectionGap` |
| Card Gap | LG (16px) | Default gap between adjacent cards in a list or grid. | `cardGap` |

Reason: these five aliases cover the layout decisions every feature screen makes repeatedly (screen padding, card padding, button padding, section-to-section spacing, card-to-card spacing). Aliasing them to the base scale — rather than letting each feature pick its own combination of raw tokens — is what makes "every screen breathes the same way" (per the Design Bible) an enforceable property instead of a hope.

---

# Rules

- Never use an arbitrary spacing value. If none of the tokens above fit, that is a design conversation, not a reason to write a literal number.
- Prefer a semantic alias (`pagePadding`, `cardPadding`, etc.) over the raw scale token (`xl`, `lg`, etc.) at a call site where one exists — it documents intent and survives a future re-tuning of the underlying value.
- Keep spacing consistent across all screens and both themes; spacing does not change between Light and Dark Mode.

---

# Flutter Implementation

Every token above should exist as a named field on a single `ThemeExtension` (e.g. `QaddySpacing`), consistent with the approach taken for `QaddyColours` and `QaddyTypography`. Reference spacing only through that extension:

```dart
Theme.of(context).extension<QaddySpacing>()!.pagePadding
```

Never write a literal `EdgeInsets.all(16)` or `SizedBox(height: 24)` for a gap that has a token above — use the token's value instead, e.g. `EdgeInsets.all(spacing.cardPadding)`.

## Token reference

| Flutter Token Name | Value (logical pixels) |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 24 |
| `xxl` | 32 |
| `xxxl` | 40 |
| `display` | 48 |
| `hero` | 64 |
| `pagePadding` | 24 (alias of `xl`) |
| `cardPadding` | 16 (alias of `lg`) |
| `buttonPadding` | 12 (alias of `md`) |
| `sectionGap` | 32 (alias of `xxl`) |
| `cardGap` | 16 (alias of `lg`) |

## Example

```
Page Padding
Flutter Token: pagePadding

Card Padding
Flutter Token: cardPadding

Between sections
Flutter Token: sectionGap
```

---

Version 2.0
