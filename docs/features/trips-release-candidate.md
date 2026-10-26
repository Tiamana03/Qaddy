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
- Nothing is persisted (TD-010). Search reads the live store; Profile's counts still read the seed constants (TD-011).
- Pure logic lives in `features/trips/logic/`: `expense_ledger.dart` (totals, who owes who, next payment), `trip_timeline.dart` (the day-by-day schedule), `trip_snapshot.dart` (hero facts), `trip_export.dart` (text itinerary, invite link), `trip_edit_summary.dart` (Edit Trip hub summaries). They are unit-tested without any UI.

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

**Trip Settings** — Rename Trip, Change Cover Image, Chat Settings, Invite More Friends, Share Invite Link (clipboard), Export Itinerary, Duplicate Trip (copies the plan; chat, payments and progress start fresh), Archive / Restore, Leave Trip, Delete Trip. Anything destructive or hard to undo asks for confirmation.

**Trip Chat** — a Messenger-style conversation: newest message anchored at the bottom, day separators, my messages right-aligned on the brand gradient, others left-aligned with profile circles and names, timestamps, an emoji tray, and a Send button that is disabled until there is text. After sending, the message ticks sent → delivered → read and another player briefly "types". Both are timed placeholders that honour the trip's Chat Settings (read receipts, typing indicators, mute).

**Courses** — each course has its own page: tee time, players, green fees (per player and total), rating and slope, dress code, address, phone and website (tap to copy), map and photo placeholders, the day's weather, directions (copy the address) and notes.

**Flights** — boarding-pass cards and a page per flight: route, times and duration, terminal, gate, seat, boarding time, booking reference (copy), a check-in status control and airport map placeholders.

**Accommodation** — dates and nights, booking number, contact details, room allocation, the cost split per guest, map and photo placeholders, notes.

**Transport** — bookings grouped by day: type, pickup time, route, driver, vehicle, reference, notes and a map placeholder.

**Expenses** — trip cost with a progress bar, paid and outstanding, what you owe and are owed, *who owes who* (pairwise netted, with Mark Paid), the full expense history and Add Expense.

**Planning** — a planning-progress ring and the next task, then four views: a daily Timeline (each day with weather; events link to their own pages; empty days offer to add an activity), a Task checklist (overdue tasks flagged), a Packing list, and Bookings (a summary of each booking type plus notes).

---

# Placeholders (see TD-013)

No dependency was added. Download PDF, maps and directions, phone/website links, photos, a weather service, a real invite link and real chat delivery are placeholders or clipboard actions, each labelled honestly in the UI.

---

# Testing

The Trips suites cover the controller, the ledger, timeline, snapshot, export and edit-summary logic, every form (add, validate, edit, delete), every detail page, trip management, chat behaviour (including reduced motion and the settings), and the hero. `test/features/trips/trips_test_harness.dart` provides `pumpApp` (the real router and theme on a phone-width screen), `pumpTrips` and `captureClipboard`.
