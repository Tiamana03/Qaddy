# Identity — a Guest Profile That Makes Qaddy the Golfer's Own

**Status:** Implemented (November 2026)

**Scope:** who the golfer is: a first name and, optionally, a handicap and a home course, kept on the phone and used everywhere instead of the placeholder golfer (Tiamana).

---

# Why

Every golfer who opened the app was "Tiamana", handicap 8.4, from Queensland. For a soft launch that is the strongest "this is a demo" moment there is. There are still no accounts (see `docs/features/launch-experience.md`), so identity is a lightweight, local **guest profile**.

# The experience

- After the introduction (or after "Continue as guest" anywhere), **"Who's teeing off?"** asks for a **first name** (required), a **handicap** (optional, -10 to 54, "12", "8.4", "8,4" or "+2") and a **home course** (optional). The avatar and name fill in as the golfer types. "Only ever kept on this phone."
- A returning golfer who somehow has no details (for example from an earlier build) is asked once, after the splash.
- **Settings → your card → Edit** changes the handicap and home course. The **name is fixed** once set (see below); "Start over" lets the golfer choose another.

# What uses it

The greeting and avatar on Home, Profile's player card (name, handicap, home course, "Since" year), Statistics, the golfer's own place on every scorecard, leaderboard and results screen, groups ("You", the squad), trips (organiser, members, awards, expenses, chat), every share message sign-off, Search ("Your home course"), notifications ("Welcome to Qaddy, Sam", "Add your handicap") and scoring (the golfer's handicap sets their stableford shots; no handicap means scratch).

# How it works (and why)

The seeded world — the upcoming round, groups, trips — refers to the golfer by an id (`currentUserName` in `core/user/current_user.dart`). `useGolfer` sets that id from the golfer's name **once, at start-up (from the stored profile) or the moment they finish setting up, before the seeded data is first read**. So every screen, message and accessibility label says the right name by construction rather than by remembering to substitute it at each place.

- **No collisions.** If the golfer is called Tom, Ben, Luke, Josh, Nick, Sam, Liam or Jack — a seeded friend's name — their id gets an invisible zero-width space, so they never merge with that friend in a scorecard or table, and the name still reads the same. A test keeps the reserved list in step with the seeded friends.
- **Why the name is fixed.** The golfer's rounds and trips are recorded under their id, and the seeded data is built once per launch, so a rename would orphan their history. Handicap and home course are not part of any id and change live.
- **Storage.** `core/user/golfer.dart` (model, validation, document), `golfer_controller.dart` (`golferProvider`, `golferDetailsProvider`, the placeholder golfer used before setup and in tests), `golfer_form.dart` (the shared form), key `qaddy.golfer.v1`.
- **The leak test.** `test/identity/no_placeholder_golfer_test.dart` walks every screen of the real app with a golfer called Zed, with rounds played and a round in progress, and fails if "Tiamana" appears anywhere.
- The old `Profile` model and `placeholder_profile.dart` are deleted; their "favourite courses" and "profile visibility" were invented.

# Placeholders and limits

- The mates, groups, trips and season table are the Sample Clubhouse: seeded for every golfer, labelled Sample and removable (see `docs/features/sample-clubhouse.md`). Only the golfer is theirs.
- Trips seeded before the golfer saved a handicap carry that handicap for the golfer until the app is reopened; Profile, Home and scoring update at once.
- No photo or avatar upload; the avatar is initials.
