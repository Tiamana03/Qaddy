# Shared UI Patterns

**Status:** Active (November 2026)

Trips, Friends Home and the Dashboard are the Release Candidate reference screens. Every later screen reuses what they share instead of inventing its own layout language. If a screen needs something that two screens now do separately, extract it into `lib/core/widgets/` first, then use it from both.

## The rule

1. Before building a screen, look here and in `lib/core/widgets/`.
2. If a pattern exists, use it. If it nearly fits, extend it (a parameter, not a copy).
3. If you write the same widget a second time, stop and extract it — add it to this list with a test.

## What exists

| Pattern | Widget | Use it for |
|---|---|---|
| Hero card shell | `QaddyHeroCard` (`core/widgets/cards`) | The big gradient card at the top of a screen: rounded, shadowed, a tappable story and an optional footer for the main action. Friends' next round and rivalry, the Dashboard's next round. |
| Eyebrow | `QaddyEyebrow` (`core/widgets/text`) | The small spaced capitals above a headline ("NEXT ROUND", "YOUR GAME"). |
| Gold call to action | `QaddyGoldButton` (`core/widgets/buttons`) | The one bright "do this next" button on a hero, sheet or card. Once per surface. |
| Everyday primary / secondary / tertiary | `QaddyPrimaryButton`, `QaddySecondaryButton`, `QaddyTertiaryButton` | Plain screens and forms. |
| Icon badge | `QaddyIconBadge` (`core/widgets/badges`) | The tinted circle that says what a tile or row is about. |
| Status badge | `QaddyStatusBadge` (`core/widgets/badges`) | A state: Upcoming, Confirmed, Completed. |
| Avatar, avatar huddle | `QaddyAvatar`, `QaddyAvatarHuddle` (`core/widgets/avatars`) | One face; or overlapping faces with "+3 more · 8 playing". |
| Section heading | `QaddySectionHeading` (`core/widgets/headings`) | A section title with an optional count badge and "See all". |
| Card, section card, statistic card | `QaddyCard`, `QaddySectionCard`, `QaddyStatisticCard` (`core/widgets/cards`) | Everyday content surfaces; `QaddyCard` has the press-down scale when tappable. |
| Entrance motion | `QaddyFadeSlideIn`, `staggered(...)`, `staggerDelay` (`core/widgets/motion`) | Sections and tiles that arrive one after another. Respects reduce-motion. |
| Empty and error states | `QaddyEmptyState`, `QaddyErrorCard` (`core/widgets/states`) | Nothing here yet / something went wrong. |
| Actions | `tellUser`, `copyToClipboard`, `openLinkOrCopy`, `shareOrCopy` (`core/widgets/actions`) | Snackbar, copy, open a link, share — each with a fallback so a tap is never dead. |
| Haptics | `QaddyHaptics` (`core/utils`) | `selection` for a choice, `light` for a small action, `success` for a win. |

## House style

- **Spacing, type, radius, shadow** come from the theme extensions (`QaddySpacing`, `QaddyTypography`, `QaddyRadius`, `QaddyShadows`) — never literal numbers for these, except one-off sizes inside a single widget (avatar diameters, icon badges).
- **Text on a gradient** uses `colorScheme.onPrimary`; gold is for eyebrows, icons and the one call to action.
- **A screen opens** with a header (title, a one-line pulse, one or two round icon buttons), then a hero, then sections separated by `spacing.sectionGap`, each introduced by `QaddySectionHeading`.
- **Every card leads somewhere.** No disabled buttons and no "coming soon" tiles; leave a thing out rather than ship it dead.
- **Numbers count up** and bars grow on arrival (about 800–900 ms, ease-out), and nothing loops.
- **Tests:** a widget test for behaviour, layout at 320 / 400 / 820 / 1280 px in dark and light, and a `pumpAndSettle` to prove nothing animates forever.

## Known candidates to extract next

These still appear in more than one feature and should be extracted the next time a screen needs them:

- The "accent blended toward the background" gradient recipe (Trips cover, rivalry, clubs, Dashboard hero, next-trip card).
- The press-down tile (Dashboard shortcuts, club cards, squad faces).
- The outlined cheer pill (activity tile) and the info chip on the Dashboard hero.
- The big-number-over-caption stat (Dashboard "Your game", Friends peek sheet).
