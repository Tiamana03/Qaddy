# Launch Experience — Release Candidate

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` and `docs/standards/shared-ui-patterns.md`.

**Scope:** Splash, Onboarding, Login, Sign Up, Continue as Guest, and remembering the introduction so returning golfers go straight into the app. **Supersedes** the "visual-only, not the boot sequence" decision in `docs/architecture/authentication-engineering-decisions.md` and `docs/features/authentication-feature-integration.md`.

---

# Why

The launch screens existed but were **never reached**: the app opened straight into the Dashboard (`initialLocation` was Home), and the screens themselves were a white page with a single icon and forms whose button always "signed in". For a soft launch, the first thirty seconds are the first impression, and a sign-in that accepts anything is the one thing that cannot feel fake.

# The principle

**Never claim something that is not happening.** Release 1 has no accounts, so the app says so plainly, makes the guest route the obvious one, and keeps the account screens honest.

# The flow

```
Splash ──► Introduction (first time) ──► Continue as guest ──► the app
   │             │  └─► Sign in / Create an account ──(valid)──► "Accounts open after the soft launch" ──► Continue as guest
   │             └────── remembered once the last page is reached
   └──────────────────► the app (returning golfers)
```

1. **Splash** — the Qaddy mark draws its gold ring and the ball settles in; the name and "The golfer's ecosystem" fade up. About 1.9 s (0.6 s with reduced motion). It then goes to the introduction the first time and straight into the app after that.
2. **Onboarding** — three pitches, each with a glowing orb in its own colour and three small icons drifting round it (the round in teal, the trip in sky blue, the mates in orange); the orb and the words move at different speeds as you swipe. Animated page dots stretch into a gold pill. "Skip" jumps to the last page. The **last page**, "Tee it up", says where things stand — your rounds, bag and trips are saved on this phone — and offers the three ways in: **Continue as guest** (gold), **Sign in**, **Create an account**.
3. **Login** and **Sign Up** — the same brand stage, the mark, an upfront notice ("Accounts open after the soft launch. Until then Qaddy keeps everything on this phone — jump in as a guest."), real validation (a believable email; a password of at least 8 characters when signing up; a name), and **Continue as guest** on both. A valid submit does **not** pretend to sign in: a sheet says *"Accounts open after the soft launch. Nothing you typed has been sent anywhere."* and offers the guest way in. Nothing typed is stored or transmitted.
4. **Continue as guest** — marks the golfer a guest, records that the introduction is done and goes to the Dashboard.

# Remembering

`AuthSession` (`onboardingComplete`, `isGuest`) is kept on the device as a small JSON document (`qaddy.session.v1`) through the shared `DocumentStorage`, exactly like the bag. Reaching the last page of the introduction records that it was seen (so quitting there does not bring it back); choosing guest records both. An unreadable document simply starts the golfer at the introduction.

# One look, whatever the phone says

The app follows the phone's light/dark setting, but the launch screens always use the **dark brand stage** (`LaunchScaffold`: deep green, a soft gold glow, the dark theme inside), so the first moments always look like Qaddy. The screens fade into one another rather than sliding.

# How it is built

- `core/widgets/brand/qaddy_mark.dart` — the mark (gold ring that draws itself, golf ball on a tee).
- `features/authentication/` — `models/session.dart`, `state/session_controller.dart` (`sessionProvider`, `sessionStorageProvider`), `logic/auth_validation.dart` (pure, tested), `ui/widgets/launch_scaffold.dart`, `ui/widgets/accounts_notice.dart` (the notice, `enterAsGuest`, the "accounts soon" sheet), and the four screens. `AuthHeader` was removed.
- `core/routing/app_router.dart` — `launchLocationProvider` (default Home, so tests and previews open in the app) and fade transitions for the four launch routes. `main.dart` overrides the launch location with the splash and the storage with `shared_preferences`.
- Reuses `QaddyGoldButton`, `QaddySecondaryButton`, `QaddyTertiaryButton`, `QaddyTextField`, `QaddyPasswordField`, `QaddyIconBadge`, `QaddyFadeSlideIn`/`staggered`, `QaddyHaptics`.
- Honours reduced motion everywhere: no drifting icons, no drawing ring, a short splash.

# Placeholders and limits

- **No accounts.** There is no sign-in, no password handling and no backend call; the account screens exist so the product looks and behaves intentionally, and say plainly that they are not open yet. Real authentication arrives with the backend (`docs/architecture/authentication-future-roadmap.md`).
- **Every guest is the placeholder golfer** (Tiamana, handicap 8.4, and the seeded mates, groups and trips). Making the golfer's own name and handicap real is the next step towards the product feeling like the user's own; it touches the shared placeholder data and is not part of this milestone.
- Settings does not yet show "Guest" (Settings is still to be polished).
- A golfer who deep-links to a page on the web bypasses the splash; that is fine, since there is nothing to protect.
