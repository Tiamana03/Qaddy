# ADR-002

## Title

Device packages for Trips: persistence, links and sharing

---

## Status

Accepted (November 2026, approved by the project owner during the Trips delight pass)

---

## Decision

Add three packages, each used behind a small interface so it can be replaced or faked:

| Package | Used for | Interface |
|---|---|---|
| `shared_preferences` | Keeping trips on the device between launches | `TripsStorage` (`features/trips/repositories/trips_storage.dart`) |
| `url_launcher` | Calling a number, opening a website, opening a place or route in a maps app | `LinkLauncher` (`core/services/link_launcher.dart`) |
| `share_plus` | Sharing the invite and the itinerary through the system share sheet | `ShareService` (`core/services/share_service.dart`) |

`pdf` / `printing` and `image_picker` were **not** approved. Itineraries are exported as text (shared or copied) and the Download PDF button was removed rather than left as a "coming soon" dialog; trip covers remain the six designed presets and course/stay pages carry no photo placeholders.

---

## Reason

- **Persistence.** A trip organiser who loses their trip when the app restarts cannot use the app for a real trip. Release 1 has no backend; on-device storage is the smallest thing that makes Trips usable at the 20 November 2026 soft launch. The whole store is saved as one versioned JSON document (`trips_codec.dart`), loaded once at start-up and written after every change. A document that cannot be read falls back to the seed trips rather than crashing. When the backend arrives only `TripsStorage` changes.
- **Links.** Phone numbers, websites and addresses that only copy to the clipboard feel broken. `url_launcher` is the standard first-party Flutter plugin for this.
- **Sharing.** Organising a trip is mostly telling other people about it. `share_plus` is the standard plugin for the platform share sheet; invites and itineraries had nowhere to go but the clipboard.

Alternatives considered: `hive`/`isar`/`sqflite` (heavier than a single document needs, and a migration cost we'd pay again when Supabase arrives); `dart:html` local storage (web-only); copying to the clipboard (what we had).

---

## Consequences

- Every launcher and share call degrades gracefully: when nothing can open a link or share, the value is copied and the golfer is told. Nothing throws into the UI.
- Tests never touch a plugin. The Trips test harness installs recording fakes (`FakeLinkLauncher`, `FakeShareService`) and the default `TripsStorage` keeps nothing, so every test starts from the seed trips.
- The saved document is versioned (`tripsDocumentVersion`). Changing the model means bumping the version or keeping decoding forgiving; an unreadable document silently resets to seeds, so a format change should be paired with a migration if testers' trips matter.
- Seed trips are only used until the golfer first changes something; after that their stored trips win, so edits to the seed data do not reach existing installs.
- The seed websites use the reserved `.example` domain, so tapping one on a real device ends in the browser's "can't reach this site" page — correct for fictional data, and a reason to keep the placeholder set small until real course data exists.
- Windows desktop builds need Developer Mode enabled (symlink support) for any plugin; web and mobile are unaffected.

---

## Related

`docs/features/trips-release-candidate.md`, `docs/reviews/technical-debt.md` (TD-010, TD-013).
