# Design Fidelity Audit — Release Candidate 1

**Updated:** 4 November 2026, after the first fidelity pass.

## The rule used to settle every conflict

1. **The approved design system** (token docs, Colour / Typography / component libraries) is the source of truth.
2. **The high-fidelity mockups** come second. When a mockup disagrees with the design system it is treated as an earlier concept, *unless* the difference is clearly intentional across several mockups.
3. **The existing implementation** comes last.
4. Where the design system is silent, match the mockups as closely as practical, consistently across the whole app.
5. Screens with no mockup reuse the existing approved design language. No new visual styles.

**How this settled the conflicts found in the first audit**

| Conflict | Decision |
|---|---|
| Mockup colours (amber `#F9B84C`, vivid green `#01813D`) are not in the Colour Library | Tokens win. Hex values are never sampled from the PNGs. The vivid green is reached through the `secondary` token (`#1E6B4B`) |
| Mockups show about 9 pt page margins; `spacing.md` says 24 pt | The spacing tokens win |
| Primary button: Buttons Library says green gradient; **every** screen mockup and your earlier instruction say gold | Gold is kept, because it is consistent across all mockups. It now uses the design system's own **Gold Gradient token**. This is one component (`QaddyGoldButton`), so reversing it is a one-file change |
| Three different bottom-nav tab sets in the mockups | Not a design-system rule, and `navigation.md` already fixes the five Release 1 tabs. Tab set unchanged; the bar itself now follows the Navigation Library |
| Photography, a crown logo lockup, custom icons | Cannot be shipped: see "What cannot be matched" |

---

# 1. What changed in this pass

All of it is in shared components, so every screen inherited it.

| Component | Was | Now (per the design system) |
|---|---|---|
| **Typeface** | Inter was named but **never bundled**; every screen rendered in Roboto / San Francisco | Inter 400 / 500 / 600 / 700 bundled (SIL OFL licence shipped) and set as the theme default |
| **Primary button** (`QaddyGoldButton`) | Flat gold, 52 px "tall", no shadow | Gold Gradient token, Buttons Library heights 56 / 48 / 40, small shadow, real disabled state |
| **Confirmation dialog** | Plain text dialog | Dialogs Library layout: icon medallion, centred copy, Cancel and confirm side by side, destructive in the error colour |
| **Segmented control and filter chip** | Gold outline when selected | Green selected state (`secondary` token), check mark on chips |
| **Bottom navigation** | Stock Material bar | Navigation Library: floating rounded bar, outlined icons that fill when active, active indicator, `navigation` text style |
| **Card** | No outline | Hairline `border` outline (the Cards Library), `medium` shadow |
| **Text field** | Error state only reddened the border | Error state also tints the field (Forms Library) |
| **Info chip on heroes** | Flat translucent | Frosted: blurred wash with a hairline highlight (the mockups' weather card) |
| **Bell** | Bare dot | Gold count badge, as in the mockups |
| **Motion** | 58 literal durations and 38 literal curves | Everything up to 1 s goes through `QaddyMotion`; **elastic and overshoot curves removed** (`animations.md` forbids them) |
| **Hole number** | 72 px | `statHoleNumber` (48 / 56), the token for exactly this |
| **Dashboard hero** | Wrapped badly in Inter's wider metrics | Countdown and course lines laid out for Inter |

**Also fixed on the way:** Friend Requests' raw Material buttons now use the shared buttons. The simulated chat delivery timers were left untouched (they are not animations).

---

# 2. Screen-by-screen audit

"Overall" is my judgement against the mockup, informed by pixel measurements and inspection, and should be read as ±10. Large-sheet mockups are more reliable than thumbnail ones. Earlier overall scores are in brackets.

## Home (Dashboard) — **74%** (was 60%) — mockup: `dashboard-home-v1`
- **Matches:** palette tokens, Inter, gold gradient CTA, frosted weather/detail chips, gold count badge on the bell, four rounded quick tiles, Your Game stat block, floating nav with gold active tab, card outlines.
- **Differs:** the mockup header is the crown wordmark plus a photo avatar, the app's is a greeting plus initials; the mockup hero is a **course photograph** with a weather card, the app's is a gradient card; the mockup shows an Upcoming Round card with a thumbnail, and then **Latest News, Quick Tools and a trip promo**, which the app does not have.
- **Needs:** course photography, the crown logo (vector), and the News / Quick Tools features (Release 2).

## Rounds — **70%** (was 65%) — mockup: `rounds-home-v1` (a round *list*)
- **Matches:** type, gold CTA, avatar huddle, card styling, nav.
- **Differs:** the mockup is "My Rounds": Create Round, search, Upcoming / Completed / Invitations tabs and photo cards. The app's Rounds is a start-a-round setup. These are different screens.
- **Needs:** a rounds list screen, which is a new feature, not styling.

## Live scorecard — **72%** (was 62%) — mockup: `live-scoring-v1`, left phone
- **Matches:** hole header uses the statistic token, gold primary, green selected states, steppers, nav.
- **Differs:** the mockup has a numbered hole strip 1–9, a **GPS course map** with distances and weather/GPS side controls, and a Hole Notes + Save Scores footer.
- **Needs:** map imagery and GPS (new feature); a "Hole Notes" action.

## Leaderboard — **74%** (was 68%) — mockup: `live-scoring-v1`, right phone
- **Matches:** tab segmentation (now green selected), table structure, gold highlights.
- **Differs:** photo avatars; the mockup adds Side Games cards and a Round Summary under the table.
- **Needs:** player photos; Side Games / Round Summary blocks.

## Profile — **72%** (was 67%) — mockup: `profile-home-v1`, left phone
- **Matches:** type, stat tiles, achievements, gold CTA, hairline cards.
- **Differs:** the mockup has a photo avatar, an **XP "Journey" bar**, hexagon badges, and Recent Rounds with photos.
- **Needs:** photo avatar support, an XP model (new feature), badge artwork.

## Statistics — **70%** (was 65%) — mockup: `profile-home-v1`, right phone
- **Matches:** type and tokens, tab selection style, hero numeral on the `display` token.
- **Differs:** the mockup has a handicap sparkline, Driving and Approach tiles, and a performance-by-hole bar chart.
- **Needs:** the charts and the extra statistics (fairways hit, GIR, putts) that Release 1 does not capture.

## Golf Bag — **68%** (was 65%) — mockup: `golf-bag-home-v1` (thumbnail)
- **Matches:** tokens, type, hairline cards, distance numerals.
- **Differs:** the mockup is a club **list with product photos** and an Add Club button; the app is a distance ladder.
- **Needs:** club photography and an Add Club flow.

## Groups — **73%** (was 67%) — mockup: `groups-home-v1`, left phone
- **Matches:** header, green selected tabs, cards, status pills, crests, nav.
- **Differs:** course photos on every card; "Round Ready" / "Waiting on 2" status pills; a search field and a Create Group button.
- **Needs:** photography; status pills and a create flow.

## Group details — **70%** (was 62%) — mockup: `groups-home-v1`, right phone
- **Matches:** members list structure, frosted chips, gold CTA.
- **Differs:** the mockup has a photo hero with a weather card, a Members / Teams / Chat / Payments tab row, and Start Scoring.
- **Needs:** hero photography; the extra tabs (Teams, Chat, Payments are new features).

## Friends home — **70%** (was 66%) — mockup: `community-home-v1` (thumbnail, social feed)
- **Matches:** tokens, type, cards, segmentation.
- **Differs:** the mockup is a social feed with posts and a weekly challenge; the app is a squad and rivalry view.
- **Needs:** a feed (Release 2).

## Trips list — **76%** (was 69%) — mockup: `trips-home-v1` (thumbnail)
- **Matches:** tokens, hero card, tabs, gold CTA, nav.
- **Differs:** the mockup is photo-led, with suggested destinations.
- **Needs:** photography.

## Trip details — **74%** (was 68%) — mockup: `trip-details-v1` (thumbnail)
- **Matches:** structure, tabs, tokens.
- **Differs:** photo hero, rating, price and a "Book Now" button.
- **Needs:** photography; booking is a different product.

## Splash / Onboarding — **76%** (was 71%) — mockup: Splash Screen Library
- **Matches:** dark green stage, gold accents, tagline structure, Inter.
- **Differs:** the library uses the **crown "Qaddy" lockup** and "More Golf. Better Days."; the app uses a golf-ball-on-tee mark.
- **Needs:** the vector logo lockup.

**Mean: 72%.**

---

# 3. What cannot be matched without something from you

| Gap | Why it blocks | What I need |
|---|---|---|
| **Photography** (hero, courses, players, clubs) | The repo has no image assets; the mockup photos are AI renders | Licensed or owned images, or a decision to ship without |
| **Crown "Qaddy" logo lockup** | The only logo files are about 140 px thumbnails | A vector (SVG) or 1000 px+ PNG of the lockup |
| **Custom thin-line icon set** | The app uses Material Icons | SVG exports of the Icons Library |
| **Mockup-only features** (Latest News, Quick Tools, GPS map, XP, My Rounds list, Teams / Chat / Payments, Side Games block, Booking) | New functionality, not styling; you asked for no Release 2 work | Your call per feature |
| **Primary colour** | Gold kept over the Buttons Library's green | Confirm gold, or say "green" and it is a one-file change |

---

# 4. Design-system rules that still need code (next pass)

- 11 `fontSize` literals, of which 6 are display-size numerals; replace with tokens or add a token.
- 4 `BoxShadow`, 4 `BorderRadius`, and 18 `EdgeInsets` literals in feature code.
- Ambient loops over 1 s (splash ring, onboarding orbs) are left as literals because `animations.md` defines no loop duration.
- Section headings: the app uses small gold uppercase "eyebrow" labels inside cards where the mockups use white sentence-case titles outside the card ("Your Game", "Playing Partners"). This is a deliberate, wide-reaching change to `QaddyEyebrow` and every card that uses it, so it is the next candidate once you confirm.
