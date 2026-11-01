# Trips — Release Candidate Completion

**Status:** Implemented (October 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` ("polish over expansion")

**Supersedes, where they differ:** the Trips sections of `docs/features/trips-feature-integration.md` (which describes the original single-trip, read-only screens). Placeholder values: `docs/standards/placeholder-trip-data.md`, "Release Candidate Revision".

---

# Why

The first Trips redesign made the overview feel premium but most of the feature behind it was read-only: Create Trip opened the Melbourne trip, only Melbourne had pages, chat could not be written to, and expenses said "All Settled". The test for this work is: *if the app launched tomorrow, could golfers organise a whole golf trip inside it?*

---

# State

Trips live in `tripsProvider` (`lib/features/trips/state/trips_controller.dart`), an in-memory `Notifier` seeded from `placeholder_trips.dart`. It holds every `Trip` and a `TripPlan` per trip (members, courses, flights, accommodation, transport, activities, expenses, checklist, packing, weather, chat, notes, change log).

- Screens read through `tripProvider(id)`, `tripPlanProvider(id)`, `upcomingTripsProvider`, `pastTripsProvider` and `archivedTripsProvider`, and change things only through `TripsController` methods (`createTrip`, `updateTrip`, `updatePlan`, `duplicateTrip`, `archiveTrip`, `deleteTrip`, `inviteFriends`, `removeMember`, `settleDebt`, `sendMessage`, …). Screens never edit a model directly.
- Anything that changes the plan can be logged (`log:`); the newest entry is the hero's "latest update".
- Trips are saved on the device after every change and loaded at start-up (`TripsStorage`, `shared_preferences`, one versioned JSON document — see `docs/decisions/ADR-002-trips-device-packages.md`). Search reads the live store; Profile's counts still read the seed constants (TD-011).
- Pure logic lives in `features/trips/logic/`: `expense_ledger.dart` (totals, who owes who, next payment), `trip_timeline.dart` (the day-by-day schedule), `trip_snapshot.dart` (hero facts), `trip_export.dart` (text itinerary, invite message), `trip_edit_summary.dart` (Edit Trip hub summaries). They are unit-tested without any UI.

---

# Routes

Every trip route carries the trip's id. `create` is registered before `:tripId` so it is never read as an id. Builders live in `AppRoutes`.

| Route | Screen |
|---|---|
| `/trips` | Trips (hero, summary, Upcoming / Past / Archived) |
| `/trips/create` | Create Trip |
| `/trips/:tripId` | Trip Details (overview and hub) |
| `/trips/:tripId/planning` | Planning |
| `/trips/:tripId/flights`, `/flights/:flightId` | Flights, Flight |
| `/trips/:tripId/accommodation` | Accommodation |
| `/trips/:tripId/transport` | Transport |
| `/trips/:tripId/golf`, `/golf/:courseId` | Golf Schedule, Course |
| `/trips/:tripId/expenses` | Expenses |
| `/trips/:tripId/chat` | Trip Chat |
| `/trips/:tripId/complete` | Trip Complete |
| `/trips/:tripId/edit` | Edit Trip (hub) |
| `/trips/:tripId/edit/:section` | Edit one section (details, dates, destination, players, notes, chat settings) or a list (accommodation, flights, transport, courses, expenses, activities, checklist, weather, packing) |
| `/trips/:tripId/edit/:section/:itemId` | Add (`itemId` = `new`) or edit one item |
| `/trips/:tripId/settings` | Trip Settings |
| `/trips/:tripId/invite` | Invite Friends |
| `/trips/:tripId/export` | Export Itinerary |

An unknown trip, section or item shows a "Trip not found" state rather than a blank form.

---

# What each part does

**Create Trip** — a full screen (not a dialog): cover image, trip name, destination, start and end dates, description, Private/Public, and a friend picker. Errors appear only after the first Save attempt. The end date cannot precede the start (the end picker opens on the earliest valid date). Saving adds a `Planning` trip, organised by the golfer, with the invited friends as pending players, and returns to Trips where it is listed under Upcoming Trips.

**Trips overview** — the soonest upcoming trip is the hero; the rest are under Upcoming Trips, then Past Trips and Archived. Every card opens its own trip.

**Hero card** — countdown (counts up once; static when the device asks for reduced motion), a planning progress ring, the first tee with a course-logo placeholder, the weather with its icon, the next task, what the golfer owes next, a budget bar, who is going and how many invites are pending, and the latest plan update and chat message. A section the golfer has not filled in simply does not appear.

**Trip Details** — cover, status, visibility and countdown; planning progress; a row for every part of the trip, each with a live summary; players (invited players marked); a weather strip; notes; Complete Trip. The app bar offers Edit Trip and Trip Settings.

**Edit Trip** — a hub of 15 sections, each with a one-line summary: Trip Details (rename, description, cover, visibility), Dates, Destination, Accommodation, Flights, Transport, Courses & Tee Times, Players, Expenses, Activities & Dining, Checklist, Notes, Weather, Packing List, Chat Settings. Lists show their items and an Add button; each item has an add/edit/delete form. Deleting asks first. Accommodation includes room allocation (one room per guest); expenses support Equally or Custom splits and a custom split must add up to the amount.

**Trip Settings** — Rename Trip, Change Cover Image, Chat Settings, Invite More Friends, Share Invite (the trip details as a message, through the system share sheet), Export Itinerary (share or copy as text), Duplicate Trip (copies the plan; chat, payments and progress start fresh), Archive / Restore, Leave Trip, Delete Trip. Anything destructive or hard to undo asks for confirmation.

**Trip Chat** — a Messenger-style conversation: newest message anchored at the bottom, day separators, my messages right-aligned on the brand gradient, others left-aligned with profile circles and names, timestamps, an emoji tray, and a Send button that is disabled until there is text. After sending, the message ticks sent → delivered → read and another player briefly "types". Both are timed placeholders that honour the trip's Chat Settings (read receipts, typing indicators, mute).

**Courses** — each course has its own page: tee time, players, green fees (per player and total), rating and slope, dress code, address, phone and website (tap to copy), a map placeholder, the day's weather, directions (opens the route from your stay in a maps app) and notes.

**Flights** — boarding-pass cards and a page per flight: route, times and duration, terminal, gate, seat, boarding time, booking reference (copy), a check-in status control and airport map placeholders.

**Accommodation** — dates and nights, booking number, contact details, room allocation, the cost split per guest, a map placeholder, notes.

**Transport** — bookings grouped by day: type, pickup time, route, driver, vehicle, reference, notes and a map placeholder.

**Expenses** — trip cost with a progress bar, paid and outstanding, what you owe and are owed, *who owes who* (pairwise netted, with Mark Paid), the full expense history and Add Expense.

**Planning** — a planning-progress ring and the next task, then four views: a daily Timeline (each day with weather; events link to their own pages; empty days offer to add an activity), a Task checklist (overdue tasks flagged), a Packing list, and Bookings (a summary of each booking type plus notes).

---

# Placeholders (see TD-013)

Three packages were approved and used behind small interfaces (ADR-002): `shared_preferences` (trips survive restarts), `url_launcher` (calls, websites, maps) and `share_plus` (invite, itinerary). What remains placeholder: PDF export (removed, not half-built), real cover photos, an embedded map, a weather service, real invite links and real chat delivery.

---

# Testing

The Trips suites cover the controller, the ledger, timeline, snapshot, export and edit-summary logic, every form (add, validate, edit, delete), every detail page, trip management, chat behaviour (including reduced motion and the settings), and the hero. `test/features/trips/trips_test_harness.dart` provides `pumpApp` (the real router and theme on a phone-width screen), `pumpTrips` and `captureClipboard`.

---

# Delight pass (November 2026)

After the completion work, Trips was reviewed again as a first-time golfer would meet it: it was complete but read like a dashboard — a dense hero, flat cards, little motion and a wall of "Nothing added yet" on a new trip. The aim was emotion, not features. Nothing was added to what Trips can do; what changed is how it feels.

**Hero card (cover-led).** The card now carries the trip's own cover colours and emblem and tells a short story: an eyebrow that builds anticipation (`NEXT TRIP` → `GET READY` inside a week → `IT'S TRIP DAY` → `LIVE NOW`), a big countdown that counts up once (and glows for a few pulses inside a week), the planning ring, and one **Up next** moment — the next flight, tee time or dinner still to come, worded "Today" or "Tomorrow" when it is. The ten facts the first version listed are now four tiles (First tee with weather, Next task, Money with an animated bar, Squad) and a ticker that alternates the latest plan update and chat message. With reduced motion the ticker shows both lines and nothing animates.

**First-run.** A golfer with no trips sees a welcome ("Plan your next golf trip", three reasons, one button) instead of an empty list. A new or sparse trip shows a **Set up your trip** card — invite your squad, add flights, where you are staying, a course, something fun — each step opens the right form and ticks off as the trip fills in; it disappears when done. Saving a new trip now opens it, with the Trips list (and the trip, under Upcoming Trips) behind it.

**Visual hierarchy.** Trip Details opens with an immersive cover banner (cover gradient, emblem, countdown, status) instead of a plain card. Trip cards in lists lead with a cover-and-date tile in the trip's own colours. Create Trip is the larger action beside Browse. Trip Complete opens with "That's a wrap". The timeline marks the next event **NEXT** with a highlighted card and a glowing dot.

**Motion and feel (app-wide primitives in `core`).** `QaddyFadeSlideIn` takes a `delay` and `staggered(...)` cascades a column of cards (capped so a long list never makes the last item wait); every Trips screen uses it. `QaddyCard` presses down a touch under a finger. Progress bars animate to their value. New chat messages slide in. Pages cross-fade and drift (`FadeForwardsPageTransitionsBuilder`) on every platform. `QaddyHaptics` gives selection, light and success feedback on chips, segmented controls, switches, ticking tasks and packing, copying, sending, settling a debt and creating a trip. Everything honours the system's reduce-motion setting, and no animation loops forever (so nothing can keep a test or a battery busy).

**Small fixes.** "1 Player" is singular; "Everyone is settled up" became "All square — nobody owes anybody."
