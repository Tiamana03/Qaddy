# Qaddy Design Tokens

# Typography

Version: 1.2
Status: Active
Source: `design/assets/typography/typography-library-v1.png` — Qaddy Typography Library v1.0, plus project Engineering Decisions for gaps the asset does not cover
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for every text style used inside the Qaddy application.

Every size, weight, line height and letter-spacing value below is taken directly from the Qaddy Typography Library. Where the library does not define a value for something this document is asked to cover, that gap is stated explicitly rather than filled with an invented number — see [Gaps in the Source Library](#gaps-in-the-source-library).

No screen or widget should set a font size, weight, line height or letter spacing as a literal value. Every text style must be reached through a Flutter `TextTheme` / theme-extension token, so the whole app's typography can change from one place and stays consistent across Light and Dark Mode.

---

# Font Family

The Typography Library does not print a font family name anywhere on the sheet — every sample is shown as "The Quick Brown Fox" in a geometric sans-serif, with no typeface label.

**Resolved.** This gap is now closed by an explicit project decision — see [Engineering Decisions → Font Family](#font-family-1). Qaddy's typeface is **Inter**, as a documented engineering standard rather than a value read from this asset.

| Role | Value |
|---|---|
| Primary font | Inter — Engineering Decision, not sourced from the asset (see [Engineering Decisions](#engineering-decisions)) |
| Fallback | System sans-serif |

---

# Design Principles

- **Never hardcode type values.** Every font size, weight, line height and letter spacing is reached through a named `TextStyle` token, never a literal `TextStyle(fontSize: ...)` inside feature code.
- **Use the type scale, not arbitrary sizes.** If a screen seems to need a size that isn't below, that's a sign a new token is missing — raise it as a design decision, don't pick a nearby number.
- **Maintain hierarchy.** Display and Heading styles establish importance; Body/Small/Caption carry content; Statistics styles exist specifically to make numbers (scores, handicaps, distances) read at a glance.
- **Respect accessibility.** All styles must scale with the user's system text-size setting (no fixed/unscaled `TextStyle` for user-facing content) — see the Design Bible and UI Component Library accessibility requirements.

---

# Display, Headings, Body, Caption

All values below are transcribed directly from the Typography Library and cross-checked at native resolution against the source PNG.

| # | Style | Font Size | Weight | Line Height | Letter Spacing | Usage | Flutter Token Name |
|---|---|---|---|---|---|---|---|
| 1 | Display | 72px | Bold (700) | 80px | -1.5px | Hero titles and key messaging. | `display` |
| 2 | Heading 1 | 40px | Bold (700) | 48px | -0.5px | Main page headings. | `h1` |
| 3 | Heading 2 | 32px | SemiBold (600) | 40px | -0.25px | Section headings. | `h2` |
| 4 | Heading 3 | 24px | SemiBold (600) | 32px | 0px | Subsection headings. | `h3` |
| 5 | Heading 4 | 20px | Medium (500) | 28px | 0px | Smaller headings. | `h4` |
| 6 | Body Large | 18px | Regular (400) | 28px | 0px | Important body content. | `bodyLarge` |
| 7 | Body | 16px | Regular (400) | 24px | 0px | Standard body text. | `body` |
| 8 | Small Text | 14px | Regular (400) | 20px | 0px | Secondary information. | `small` |
| 9 | Caption | 12px | Regular (400) | 16px | 0.25px | Hints, labels and metadata. | `caption` |

---

# Statistics Typography

For numbers, stats and key data — the library defines Font Size and Weight for each, but **does not specify Line Height or Letter Spacing** for this section. Line height is now resolved for every row by an explicit Engineering Decision (see [Engineering Decisions → Statistics Typography](#statistics-typography-1)); letter spacing is resolved only for `statHoleNumber` and remains open for the rest.

| Style | Font Size | Weight | Line Height | Letter Spacing | Usage | Flutter Token Name |
|---|---|---|---|---|---|---|
| Large Stat | 72px | Bold (700) | 80px — Engineering Decision (matches `display`) | Not decided | Large hero-sized statistics (e.g. a round's final score total). | `statLarge` |
| Hole Number | 48px | Bold (700) | 56px — Engineering Decision (8px vertical rhythm) | 0px — Engineering Decision | The current hole number in scoring/live-scoring UI. | `statHoleNumber` |
| Handicap | 40px | SemiBold (600) | 48px — Engineering Decision (matches `h1`) | Not decided | Handicap index display. | `statHandicap` |
| Score | 40px | Bold (700) | 48px — Engineering Decision (matches `h1`) | Not decided | A single score value (e.g. "-3"). | `statScore` |
| Distance | 40px | Bold (700) | 48px — Engineering Decision (matches `h1`) | Not decided | Short-form distances (e.g. "254m"). | `statDistance` |
| Distance (Long) | 32px | SemiBold (600) | 40px — Engineering Decision | Not decided | Longer-form distances (e.g. "15.4 km"). | `statDistanceLong` |

**Note:** the proportional-values Engineering Decision only specifies line height for 32px/24px/16px directly; 72px and 40px are resolved here by the same "proportional, consistent with the rest of the system" rule applied to sizes that already exist in the main type scale (`display` and `h1` respectively) — a direct, mechanical extension of that rule, not a separate invented value. `statHoleNumber` (48px) has no counterpart anywhere in the type scale, so it is resolved by its own dedicated Engineering Decision (56px line height, 0px letter spacing, chosen to hold an 8px vertical rhythm) rather than the proportional table. Letter spacing for the other five statistics rows is still undecided; leave `TextStyle.letterSpacing` unset (font default) for those until a value is confirmed.

---

# Button Text

The library's "Button Labels" panel (section 10) is a **visual mock-up only** — it shows five example buttons (BOOK ROUND, START ROUND, VIEW SCORECARD, JOIN GROUP, SAVE CHANGES) but prints no font size, weight, line height or letter-spacing numbers at all, unlike every other section.

Observable from the mock-up (descriptive only, not a sourced spec): label text is uppercase, appears bold-weight, and is paired with a trailing arrow icon.

**Resolved.** This gap is now closed by an explicit project decision — see [Engineering Decisions → Button Typography](#button-typography-1). Flutter Token: `button`.

---

# Navigation Text

The Typography Library has **no dedicated section for navigation/tab-bar text** — it is not covered anywhere in the asset.

**Resolved.** This gap is now closed by an explicit project decision — see [Engineering Decisions → Navigation Typography](#navigation-typography-1). Flutter Token: `navigation`.

---

# Gaps in the Source Library

Summary of everything this document was asked to cover that the Typography Library does not actually define. All four are now addressed — either resolved by an explicit Engineering Decision, or left honestly open where no decision has been made:

1. **Font family name** — not printed anywhere on the sheet. **Resolved** by Engineering Decision: Inter (see [Font Family](#font-family) / [Engineering Decisions](#engineering-decisions)).
2. **Button text** — visual example only, no numeric spec. **Resolved** by Engineering Decision (see [Button Text](#button-text)).
3. **Navigation text** — no section at all. **Resolved** by Engineering Decision (see [Navigation Text](#navigation-text)).
4. **Statistics line height / letter spacing** — font size and weight only. **Line height fully resolved** by Engineering Decision for every statistics row, including `statHoleNumber` (48px → 56px, for an 8px vertical rhythm). **Letter spacing resolved only for `statHoleNumber`** (0px); the other five statistics rows remain genuinely undecided — see [Statistics Typography](#statistics-typography).

Nothing above was inferred silently — every resolved value is attributed to an explicit Engineering Decision below, and every still-open value is labelled "Not decided" rather than filled in.

---

# Flutter Implementation

Every confirmed style above should exist as a named `TextStyle` on the app's `TextTheme` (or a `QaddyTypography` theme extension, consistent with the approach taken in `colours.md`). Reference styles only through that theme:

```dart
Theme.of(context).textTheme.headlineLarge // or the equivalent QaddyTypography field
```

Never construct a feature-level `TextStyle` with a literal `fontSize`, `fontWeight`, `height` or `letterSpacing` for text that has a token above.

## Token reference

`fontSize` and `height` below are in logical pixels; `height` is expressed as Flutter's `TextStyle.height` multiplier (line height ÷ font size), since Flutter does not take an absolute line-height in pixels directly.

| Flutter Token Name | fontSize | fontWeight | height (line-height ÷ size) | letterSpacing |
|---|---|---|---|---|
| `display` | 72 | `FontWeight.w700` | 80/72 ≈ 1.111 | -1.5 |
| `h1` | 40 | `FontWeight.w700` | 48/40 = 1.2 | -0.5 |
| `h2` | 32 | `FontWeight.w600` | 40/32 = 1.25 | -0.25 |
| `h3` | 24 | `FontWeight.w600` | 32/24 ≈ 1.333 | 0 |
| `h4` | 20 | `FontWeight.w500` | 28/20 = 1.4 | 0 |
| `bodyLarge` | 18 | `FontWeight.w400` | 28/18 ≈ 1.556 | 0 |
| `body` | 16 | `FontWeight.w400` | 24/16 = 1.5 | 0 |
| `small` | 14 | `FontWeight.w400` | 20/14 ≈ 1.429 | 0 |
| `caption` | 12 | `FontWeight.w400` | 16/12 ≈ 1.333 | 0.25 |
| `button` | 16 | `FontWeight.w600` | 24/16 = 1.5 | 0.1 |
| `navigation` | 12 | `FontWeight.w500` | 16/12 ≈ 1.333 | 0.2 |
| `statLarge` | 72 | `FontWeight.w700` | 80/72 ≈ 1.111 (Engineering Decision, matches `display`) | Not decided |
| `statHoleNumber` | 48 | `FontWeight.w700` | 56/48 ≈ 1.167 (Engineering Decision, 8px vertical rhythm) | 0 (Engineering Decision) |
| `statHandicap` | 40 | `FontWeight.w600` | 48/40 = 1.2 (Engineering Decision, matches `h1`) | Not decided |
| `statScore` | 40 | `FontWeight.w700` | 48/40 = 1.2 (Engineering Decision, matches `h1`) | Not decided |
| `statDistance` | 40 | `FontWeight.w700` | 48/40 = 1.2 (Engineering Decision, matches `h1`) | Not decided |
| `statDistanceLong` | 32 | `FontWeight.w600` | 40/32 = 1.25 (Engineering Decision) | Not decided |

`button` and `navigation` are Engineering Decisions, not values read from the Typography Library — see [Engineering Decisions](#engineering-decisions).

## Example

```
Display
Flutter Token: display

Heading 1
Flutter Token: h1

Body
Flutter Token: body

Caption
Flutter Token: caption
```

---

# Engineering Decisions

The values in this section are **intentional Qaddy project standards, deliberately decided by engineering to close gaps in the Typography Library — they are not values sourced directly from the design asset.** Everywhere else in this document, a value traces back to a pixel in `typography-library-v1.png`; everywhere in this section, the value traces back to this decision instead. Treat them with the same authority as sourced values (do not hardcode around them, do not re-derive them differently elsewhere), but do not cite them as coming from the Typography Library — they don't.

## Font Family

**Inter**, with a system sans-serif fallback.

Reason:

- Already referenced elsewhere in the project.
- Optimised for Flutter.
- Excellent readability across Android, iOS and Web.
- Official font family for Qaddy unless changed in a future design revision.

## Button Typography

| Property | Value |
|---|---|
| Font Size | 16px |
| Font Weight | 600 (SemiBold) |
| Line Height | 24px |
| Letter Spacing | 0.1px |

Reason: provides strong emphasis for primary actions while maintaining readability.

Flutter Token: `button`

## Navigation Typography

| Property | Value |
|---|---|
| Font Size | 12px |
| Font Weight | 500 (Medium) |
| Line Height | 16px |
| Letter Spacing | 0.2px |

Reason: keeps bottom navigation and tab labels readable without competing with page content.

Flutter Token: `navigation`

## Statistics Typography

Where the source library does not specify line height or letter spacing, use proportional values consistent with the rest of the typography system:

| Font Size | Line Height |
|---|---|
| 32px | 40px |
| 24px | 32px |
| 16px | 24px |

Only apply these where the source asset provides no value.

Applying this to the statistics sizes that already coincide with an entry in the main type scale gives `statDistanceLong` (32px → 40px, matching `h2`), and — by the same rule, mechanically extended to the other type-scale sizes the statistics panel reuses — `statLarge` (72px → 80px, matching `display`) and `statHandicap`/`statScore`/`statDistance` (40px → 48px, matching `h1`).

### Stat Hole Number

`statHoleNumber` (48px) has no counterpart anywhere in the main type scale, so it falls outside the proportional table above. It is resolved separately:

| Property | Value |
|---|---|
| Font Size | 48px |
| Line Height | 56px |
| Letter Spacing | 0px |

Reason: the master typography asset does not specify these values. To maintain an 8px vertical rhythm across the typography scale, Qaddy standardises the 48px statistic style with a 56px line height.

This is an engineering decision and not sourced directly from the typography asset library.

Letter spacing for the remaining statistics rows (`statLarge`, `statHandicap`, `statScore`, `statDistance`, `statDistanceLong`) is still not covered by any decision and remains undecided.

These statistics line-height values are project engineering standards applied to fill a gap — they are not values taken directly from the design library.

---

Version 1.2
