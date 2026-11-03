# Trips Sub-Screens — Release Candidate Polish

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` and `docs/standards/shared-ui-patterns.md`.

**Scope:** Create Trip (`/trips/create`), Invite Friends (`/trips/:id/invite`), Trip Complete (`/trips/:id/complete`) and Golf Schedule (`/trips/:id/golf`) — the Trips screens that still read as lists of rows and plain cards next to the redesigned Trips home and Trip Details.

---

# Create Trip

Already the best of the four: a live preview card fills in as the golfer types, with a cover picker. It now:

- arrives one section after another,
- ends in the **gold** "Save Trip" button (with a take-off icon),
- says "Pick a look" for the cover,
- no longer promises an "invite link" (there are none — TD-013); a public trip is "visible to anyone you share it with".

# Invite Friends — "Who's coming?"

1. **Hero** (the Trips `DetailHeader`) — "Who's coming?", the trip name and "8 going · 1 waiting".
2. **Your mates** — the tickable list, now fed by the live friends store (so only confirmed mates show, and a newly accepted friend appears).
3. **Invite N friends** — a gold button that **appears only once someone is ticked**, so there is never a greyed-out dead action.
4. **Or send a message** — the invite in a message-bubble panel, with **Share Invite** (gold) and **Copy Message**.
5. **Waiting to reply** — each mate who has not answered, with their face.

The "going" count is the confirmed members, so it agrees with "8 players" everywhere else on the trip.

# Trip Complete — "That's a wrap"

- A one-off **confetti** burst, then the trip's header with its dates, rounds and players.
- **The champion** gets a gold card with their face and "TRIP CHAMPION"; the other awards (runner-up, longest drive, nearest the pin) are tiles with each winner's face.
- **Courses played** with the day each was played.
- **The bill** — the total, and what it comes to **each**.
- Archive Trip (secondary) and Return Home (gold).
- Gone: the duplicated "Trip Summary" rows, the empty "Winners" card shown for trips with no results, and the "Memories: photos will appear here" placeholder (the app has no photos — TD-013).

# Golf Schedule

- A hero — "The golf": rounds, players and the first tee time.
- The course cards by day (unchanged — they were already good).
- **Playing groups** show each player's face; **side games** are pills with their hole.
- "Add Course" is a quiet secondary button (the "+" is in the app bar too).

# How it is built

Shared pieces reused throughout: `DetailHeader`, `QaddyGoldButton`, `QaddySecondaryButton`, `QaddyCard`, `QaddySectionHeading`, `QaddyAvatar`, `QaddyConfetti`, `QaddyFadeSlideIn`/`staggered`. `TripFriendPicker` became a `ConsumerWidget` reading `confirmedFriendsProvider` (no longer the placeholder list — this closes the Trips half of TD-014) and writes handicaps with `handicapLabel`. Gold surfaces use the dark base colour for text, as the gold button does.

# Placeholders and limits

- Awards exist only for the seeded Melbourne trip (`melbourneGolfWeekendResults`); other trips go straight from the header to their courses and bill.
- "Each" is the total divided by the players, rounded; it is not a settled split of who owes whom (Expenses does that).
- Everything else about these screens is unchanged from `docs/features/trips-release-candidate.md`.
