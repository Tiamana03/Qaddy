# Settings — Release Candidate

**Status:** Implemented (November 2026)

**Scope:** Settings (`/profile/settings`, from Profile). Everything on it does something.

---

# Why

Settings was read-only: "Profile Visibility: Friends Only" (an invented setting), four green "Enabled" badges that were not switches, "Theme: Dark" while the app actually follows the phone, and a version literal.

# The screen

1. **The golfer** — their face, name, handicap and home course; **Edit** opens a sheet (name locked, see `identity.md`).
2. **Appearance** — **Auto / Light / Dark**, applied app-wide immediately and kept on the phone. Auto follows the phone. (The launch screens always use the dark brand stage.)
3. **Notifications** — a real switch for each kind; they choose what the feed and the bell show. In-app only, and says so.
4. **Your account** — "Playing as a guest. Everything is saved on this phone. Accounts open after the soft launch."
5. **Your data** — what is kept; **Clear my rounds** (only when there are some; asks first) and **Start over** (clears everything on the phone; asks first; then asks the golfer to reopen Qaddy, because the seeded world was built around the old name).
6. **About** — **Privacy** (plain words: no accounts, nothing sent to a server, no tracking or ads, crash reports off, sharing goes only where you send it) and **About Qaddy** (version, release); the version again at the foot.

# How it is built

`core/theme/theme_mode_controller.dart` (`themeModeProvider`, key `qaddy.theme.v1`), `core/config/app_info.dart` (version — checked against `pubspec.yaml` by a test), `core/services/local_data.dart` (`LocalData`, clears every `qaddy.` key), `RoundsController.clearHistory`, and the notification switches from `notifications_controller.dart`. Reuses `QaddyCard`, `QaddySegmentedControl`, `QaddySwitchRow`, `QaddyNavRow`, `showQaddyConfirm`, `GolferForm`.

# Placeholders and limits

No export of data, no units setting, no language setting. If crash reporting or analytics are ever switched on, the Privacy text must change with them.
