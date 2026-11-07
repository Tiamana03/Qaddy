# Mockup Checklist

The working checklist behind `mockup-conformance-audit-rc1.md`. Mockups live in `design/mockups/`; component specs in `design/ui-components/`. Conflicts are settled design system first, then mockups, then the existing code (see `docs/standards/shared-ui-patterns.md`).

**Status:** ✅ matches the design language · 🟡 blocked on an asset (see `docs/design/asset-register.md`) · 🔲 mockup shows a feature or layout that is not in Release 1 · ⚠️ no mockup: left functional, flagged for design, **no new visual direction invented**

---

# 1. Reusable components (the layer every screen inherits)

| Component | Source spec | Status |
|---|---|---|
| Typeface (Inter 400/500/600/700) | typography.md | ✅ bundled, theme default |
| Primary action `QaddyGoldButton` (Gold Gradient, 56/48/40, disabled) | Buttons Library | ✅ |
| Outline / secondary / tertiary buttons | Buttons Library | ✅ (accent outline per colours.md) |
| Destructive button | Buttons Library | ✅ (inside the dialog) |
| Icon button `QaddyIconButton` (+ tooltip, custom face) | Buttons Library | ✅ Home and Friends headers now use it |
| Segmented control, filter chip | Buttons Library | ✅ green selected |
| Confirmation dialog, **notice dialog** (shared surface) | Dialogs Library | ✅ the last stock `AlertDialog` is gone |
| Bottom navigation `QaddyBottomNav` | Navigation Library | ✅ |
| Card `QaddyCard` (hairline, radius, shadow) | Cards Library | ✅ |
| Text field, search field, password field | Forms Library | ✅ error tint, search opens focused |
| **Toggle switch, checkbox** | Forms Library | ✅ now brand green with a white thumb / check (were gold) |
| Info chip (frosted), Sample badge, status badge | Badges Library | ✅ |
| Eyebrow (sentence case), section heading | design language | ✅ |
| Sample banner | project | ✅ |
| Loaders (linear, circular) | Loaders Library | ✅ themed accent; `QaddyLinearLoader` / `QaddyCircularLoader` exist |
| Motion | animations.md | ✅ `QaddyMotion` throughout |
| Avatars | Avatars Library | 🟡 initials only (photos pending) |
| Icons | Icons Library | 🟡 Material until the icon set arrives |

**Stock Material still in use, by design.** App-bar `IconButton`s (they inherit the themed foreground and size), `TextButton`s (themed accent), `SnackBar`s and `showModalBottomSheet` (themed in `QaddyTheme`), and the date and time pickers (themed). None has a Qaddy replacement in the libraries.

---

# 2. Screens with a mockup

| Screen | Mockup | Done | Remaining |
|---|---|---|---|
| Splash, Onboarding | Splash Library | ✅ stage, gold, Inter | 🟡 crown logo lockup, topographic pattern |
| Home | `dashboard-home-v1` | ✅ hero, door tiles, frosted chips, bell count, calm sections | 🟡 photo hero, avatar photo, crown logo · 🔲 Latest News, Quick Tools, trip promo |
| Rounds | `rounds-home-v1` | ✅ start-a-round hero, list | 🔲 "My Rounds" list screen with Upcoming / Completed / Invitations · 🟡 course photos |
| Live scorecard | `live-scoring-v1` (left) | ✅ hole header (stat token), steppers, gold primary | 🔲 GPS map and distances, Hole Notes · 🟡 player photos |
| Leaderboard | `live-scoring-v1` (right) | ✅ green tabs, table | 🔲 Side Games block, Round Summary · 🟡 photos |
| Round results | `round-details-v1` family | ✅ celebration, achievements | 🔲 payment status, teams, notes |
| Profile | `profile-home-v1` | ✅ card, stat row, achievements | 🔲 XP journey bar · 🟡 photo avatar, badge artwork |
| Statistics | `profile-home-v1` (right) | ✅ hero, form chart, mix, holes | 🔲 handicap sparkline, driving and approach tiles |
| Golf Bag | `golf-bag-home-v1` | ✅ starter bag, distance ladder | 🔲 club list with photos, Add Club · 🟡 club photos |
| Groups | `groups-home-v1` (left) | ✅ cards, banner, green tabs | 🔲 status pills, create group · 🟡 course photos |
| Group details | `groups-home-v1` (right) | ✅ hero, members, frosted chips | 🔲 Teams, Chat, Payments tabs · 🟡 hero photo |
| Friends home | `community-home-v1` | ✅ squad, requests, rivalry | 🔲 social feed, weekly challenge |
| Trips list | `trips-home-v1` | ✅ hero (headline + up next), stats, actions | 🟡 destination photography |
| Trip details | `trip-details-v1` | ✅ planning, sections | 🔲 rating, price, Book Now · 🟡 photo hero |
| Trip sub-screens | `trip-itinerary-v1`, `trip-booking-v1`, `trip-group-chat-v1` | ✅ timeline, forms, chat | 🔲 booking |

# 3. Screens with no mockup: functional, flagged for design (⚠️)

Not restyled and not given a new visual direction; they reuse the shared components above.

- Setup ("Who's teeing off?")
- Login and Sign Up (account screens)
- Notifications
- Settings (a thumbnail exists, `profile-settings-v1`, too small to specify)
- Search
- Friend Requests, Friends List, Activity Feed, Friend profile, Rivalries
- Invite a mate
- Create Trip and the trip edit forms
- Trip settings, Trip invite, Trip export, Trip complete
- Sample Clubhouse banner and badges
- Round setup (who's playing) and the score picker

# 4. What changed in this step

- Switches and checkboxes are brand green (Forms Library) instead of gold, which also lightens Settings, Setup and Rounds.
- A second Qaddy dialog (notice) shares one surface with the confirmation dialog; Settings' "Fresh start" uses it instead of a stock `AlertDialog`.
- `QaddyIconButton` takes a tooltip and a custom face; the Home and Friends headers use it rather than their own circles.

# 5. Not done, and why

Everything marked 🟡 needs files from the design owner; everything marked 🔲 is a feature or layout change you have asked me not to start. Both are listed per screen above so nothing is lost.
