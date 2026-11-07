# Mockup Checklist

The working checklist behind `mockup-conformance-audit-rc1.md`. Mockups live in `design/mockups/`; component specs in `design/ui-components/`. **The mockups win over the design-system documents** (updated 7 November 2026); the documents follow the mockups. See `docs/standards/shared-ui-patterns.md`.

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
| Home | `dashboard-home-v1` | ✅ measured against the mockup at 393 wide (`fidelity/home-1.png`): header, 205 hero with weather card, 80 door tiles, 136 round card with pill buttons, 90 stat tiles with foot icons, promo card | 🟡 hero photo, course thumbnail, avatar photo, serif crown logo · 🔲 Latest News, Quick Tools · ⚠️ door labels differ (see Fidelity Pass) |
| Rounds | `rounds-home-v1` | ✅ measured against the mockup (`fidelity/my-rounds-1.png`): brand bar, "My rounds" with Create round, search and filter, three pill tabs, photo round cards (138 x 94 thumbnail, date, time, format and forecast, faces with the count, status pill, three pill buttons) | 🔲 Get Directions and payment states (Paid / Pending / Not Paid) and Mark as Paid, the filter itself (kept, dimmed), real location lines · 🟡 course photos, player photos · ⚠️ the middle button is Share, the status pill is Planned / Live / Finished, the Invitations tab is an honest empty state |
| Live scorecard | `live-scoring-v1` (left) | ✅ measured against the mockup (`fidelity/live-scorecard-1.png`): top bar with title, course and faces, hole strip with gold-ringed current hole, "Hole N" with facts and the Next hole pill, 290-tall hole view, one "Enter scores" panel (face, name, boxed stepper, running score against par), Previous and gold Finish round | 🔲 GPS, wind, weather and course-map tiles, back/middle/front distances, flyover, Hole Notes · 🟡 aerial photography, player photos · ⚠️ foot buttons are Previous / Finish round, not Hole Notes / Save Scores |
| Leaderboard | `live-scoring-v1` (right) | ✅ "Live leaderboard" card with Pos / Player / Thru / Pts, side-game tiles, Round summary | 🔲 Leaderboard / Scorecard / Stats / Side Games tabs, Stroke Play dropdown, teams, side-game entries and winners · 🟡 player photos |
| Round results | `round-details-v1` family | ✅ celebration, achievements | 🔲 payment status, teams, notes |
| Profile | `profile-home-v1` | ✅ header (bell, gear), identity with Edit profile, four stat tiles, achievements, recent rounds with thumbnails, gold View full statistics | 🔲 XP journey bar and level, tagline/title, camera badge · 🟡 photo avatar, round thumbnails, badge artwork |
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

# 6. Visual fidelity pass (7 November 2026): what moved to match the mockups

Measured as the median of several samples per value, then written back into `design/design-tokens/`.

| Token or component | Was | Now (mockup) |
|---|---|---|
| `gold` | `#D4AF37` | `#F8B64D` |
| `gradientGold` | `#D4AF37 → #F4D676` | `#FBBD55 → #F5B547` |
| `selected` (new) | gold outline / `#1E6B4B` | `#01813D` on every selected control |
| `pagePadding` | 24 | 12 (mockup margin ≈ 10 pt) |
| `sectionGap` / `cardGap` | 32 / 16 | 24 / 12 |
| radius `large` / `extraLarge` | 24 / 32 | 18 / 24 |
| Quick-action tiles | coloured icon badge | white glyph, first tile filled green |
| Section heading | `h3`, gold link | `h4` semibold, grey "See all ›" |

**Still different, and why (the differences a side-by-side shows now):**

- Photography in the Home hero and the Upcoming Round thumbnail, the crown logo and photo avatar in the Home header. 🟡 assets (the slots exist and are the final size and position)
- The live scorecard has one "Next hole" (gold, bottom right) rather than the mockup's two (a pill by the title and "Save Scores"): scores save as they are entered, so there is nothing to save, and a second Next would be a duplicate. The pill's place shows Front or Back nine. 🟡 decision
- Rounds, Profile, Groups and Bag are different screens in the mockup (see section 2).
- The bottom bar is now the mockup's: a rounded bar nearly the width of the screen, with a green pill behind the active icon and a filled glyph, and no underline. The tab set stays Home / Rounds / Trips / Friends / Profile; the mockups disagree with each other on it (Home / Bag / Round / Community or Groups / More or Profile), so the set is a product decision, not a styling one. 🟡 decision

## Fidelity Pass — type and size scale measured from the mockups

The mockups set most of the interface smaller than the Typography Library's names suggest. `lib/core/theme/qaddy_text.dart` holds the sizes measured by rendering a screen at 393 wide and laying it beside its mockup: hero name 26 bold, greeting 14, section title 16 semibold, card title 14, meta 12, time 15 bold, door label 12, pill label 12 semibold, tile figure 18 bold, tile label 11. Compact buttons are 36-tall pills; door tiles 80; stat tiles 90; hero 205; round card about 136. Home was the first screen measured this way; the other screens still use the earlier scale and are brought across as they are measured.

Side-by-side images are kept in `docs/reviews/fidelity/`.

### How fidelity is measured

`QADDY_RENDER=1 flutter test test/tool/render_screens_test.dart` renders screens to `build/renders/*.png` at 393 x 852 with the bundled Inter and Material icon fonts (no browser needed, same result every time). Each is laid beside its mockup, with the status bar cropped out, and the images are kept in `docs/reviews/fidelity/`.
