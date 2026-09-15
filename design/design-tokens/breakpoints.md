# Qaddy Design Tokens
# Breakpoints
Version: 1.0
Status: Approved
Last Updated: August 2026

---

# Purpose

Defines the responsive layout system used throughout Qaddy.

All layouts, spacing, grids and adaptive widgets must reference these
breakpoints.

Developers must never invent breakpoint values.

---

# Source

No design asset currently exists for responsive breakpoints.

These values are Engineering Decisions created as the official
Qaddy responsive standard.

---

# Breakpoint Scale

| Token | Width | Device |
|-------|--------|---------|
| mobile | 0–599px | Phones |
| tablet | 600–1023px | Tablets / Foldables |
| desktop | 1024px+ | Desktop / Large Web |

---

# Layout Rules

## Mobile

- Single column layout
- Bottom navigation
- Full-width cards
- Side padding: 16px
- Maximum content width: 100%

---

## Tablet

- Two-column layouts where appropriate
- Bottom navigation
- Increased whitespace
- Side padding: 24px
- Cards may appear side-by-side

---

## Desktop

- Centered content
- Maximum content width: 1440px
- Side navigation may replace bottom navigation
- Side padding: 32px
- Multi-column dashboards encouraged

---

# Grid

Mobile:
- 4-column grid

Tablet:
- 8-column grid

Desktop:
- 12-column grid

---

# Responsive Behaviour

Cards should:

Mobile
- Full width

Tablet
- 2 across where possible

Desktop
- 3–4 across depending on content

---

Navigation

Mobile
- Bottom Navigation Bar

Tablet
- Bottom Navigation Bar

Desktop
- Navigation Rail (future)

---

Typography

Typography scales remain identical across all breakpoints unless
specifically overridden.

---

Spacing

Spacing tokens remain identical across all breakpoints.

Only layout width changes.

---

Images

Images scale responsively.

Never stretch images.

Maintain aspect ratios.

---

Developer Notes

Flutter implementations should use:

MediaQuery

LayoutBuilder

ResponsiveBuilder (if adopted later)

Never hardcode screen widths.

Always reference these breakpoint tokens.

---

Engineering Decisions

These breakpoint values are based on Material Design 3 responsive
guidelines and are adopted as the official Qaddy standard.

Future devices should continue using these three responsive categories
unless the design system is formally updated.