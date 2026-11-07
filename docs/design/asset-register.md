# Asset Register

**Purpose:** the single list of every visual asset the app is waiting for. The app ships with clean placeholders in each slot (designed gradients, emblems and initials), so nothing is blocked and no screen was redesigned around a missing asset. When a final asset arrives, replace the placeholder named here; nothing else should need to change.

**Status key:** 🔲 needed · 🟡 partial (thumbnail only in `design/assets/`) · ✅ supplied

Last updated: 4 November 2026.

---

# 1. Brand

| ID | Asset | Spec | Where it goes | Placeholder today | Status |
|---|---|---|---|---|---|
| B1 | **Crown "Qaddy" logo lockup** (primary, with "More Golf. Better Days." tagline variant) | SVG, light and dark versions | Splash, onboarding header, login, sign-up, Settings › About; a compact version for the app bar | `QaddyMark` (golf ball on a tee in a gold ring) plus the word "Qaddy" in Inter, in `core/widgets/brand/qaddy_mark.dart` | 🟡 140 px thumbnails only (`design/assets/logos/`) |
| B2 | Brand tagline | Text decision | Splash and Settings › About | "The golfer's ecosystem" | 🔲 confirm wording ("More Golf. Better Days." in every mockup) |
| B3 | Topographic pattern background | SVG or tiling PNG | Splash and onboarding stage (`LaunchScaffold`) | Plain green gradient with a soft gold glow | 🟡 thumbnail only |
| B4 | App icon, adaptive icon, notification icon, splash assets | Store and platform sizes | `android/` and `ios/` (you are handling this) | Flutter default icon | 🔲 |

# 2. Photography

All photography slots currently show a designed gradient hero with an emblem, so a screen never looks empty.

| ID | Asset | Spec | Where it goes | Placeholder today | Status |
|---|---|---|---|---|---|
| P1 | **Home hero** (a course at golden hour) | 1200×800 min, JPG | Home hero (`HomeHero`, 200 px) and the Upcoming Round thumbnail (76 px) | `QaddyMediaPlaceholder` (sky, hills and flag) | 🔲 |
| P2 | **Course photos** (one per course; Richmond for the sample round) | 800×600 min | Round cards, Rounds hero, Group cards, scorecard hole view (aerial, 190 px) | Gradient and emblem | 🔲 |
| P3 | **Trip covers** | 1200×800, a set of 8–12 destinations | Trips hero, trip card, Create Trip cover picker | The nine gradient + icon presets in `TripCoverPreset` / `trip_cover_tile.dart` | 🔲 |
| P4 | **Group covers** | 800×600 | Group cards and Group details hero | `GroupCrest` (initial in a gold ring) on a tone gradient | 🔲 |
| P5 | **Player photos** for the sample mates | 400×400 | Avatars everywhere a mate appears | `QaddyAvatar` initials on a stable colour | 🔲 (the golfer's own photo is a Release 2 upload) |
| P6 | **Golf Bag club photos** | 400×400, transparent PNG | Club list and club sheet | Distance ladder, no photos | 🔲 |
| P7 | Onboarding hero art | 3 illustrations | The three pitch pages | Glowing orb with three drifting icons | 🔲 |

# 3. Icons and illustrations

| ID | Asset | Spec | Where it goes | Placeholder today | Status |
|---|---|---|---|---|---|
| I1 | **Custom thin-line icon set** (Icons Library, 5 batches) | SVG, 24 px grid, outline + filled | Everywhere (`Icon(Icons.…)` today) | Material Icons | 🟡 library sheets only |
| I2 | **Empty-state illustrations** (no rounds, empty bag, friends waiting, trip planning, statistics growth, achievement unlocked, weather delay) | SVG or 3× PNG | `QaddyEmptyState` and the Statistics / Trips / Friends / Bag empty states | A single large Material icon | 🟡 about 140 px thumbnails |
| I3 | **Achievement badge artwork** (hexagon, locked and earned) | SVG | Achievements shelf, Profile, Round complete | Circular icon badges | 🔲 |
| I4 | Weather icons | SVG | Hero weather chips | Material `wb_sunny` etc. | 🔲 |

# 4. Where a placeholder is swapped

| Slot | One place to change |
|---|---|
| Logo | `QaddyMark` (`core/widgets/brand/qaddy_mark.dart`) |
| Any photograph | Add a `QaddyPhoto` slot next to the hero or card; the gradient stays as the loading and error state |
| Icons | Replace the `IconData` constants with the icon-set glyph font, or an `SvgPicture`, in the shared widgets first (`QaddyIconBadge`, `QaddyBottomNav`, `QaddyQuickActions`) |
| Empty states | `QaddyEmptyState` takes an illustration in place of its icon |
| Avatars | `QaddyAvatar` takes an optional image; initials stay as the fallback |

# 5. Not assets, but still open

- Final tagline (B2).
- The Save/Share/Export icons used in Settings are standard Material until I1 arrives.
