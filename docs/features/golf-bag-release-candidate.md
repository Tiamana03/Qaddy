# Golf Bag — Release Candidate Redesign

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` and `docs/standards/shared-ui-patterns.md`.

**Scope:** the Golf Bag screen (`/profile/bag`, reached from Profile), the bag's data and the store that keeps it.

---

# Why

Golf Bag was an inventory: a "Bag Summary" that said **Total Clubs 5** (it counted the putter and the ball), a list of five key/value rows and three average distances (Driver, Irons, Wedges). Nothing could be changed, nothing told you anything, and it did not look like a bag.

# The idea

The golfer's **personal equipment locker** — the screen you would open before every round to see what you are carrying, how it is gapped and which club you trust.

# The screen

1. **Your bag (hero)** — a warm, leathery card: "14 clubs in the bag", one sentence on the gapping ("Nicely spread. Keep an eye on the 23m gap between your Hybrid and 5 iron."), and chips for the longest club, the **go-to club** and the ball.
2. **Your distances** — the distance ladder. Every club from the longest to the shortest as a bar that grows in, coloured by kind (woods gold, hybrid orange, irons teal, wedges blue), with the carry on the right and, beneath it, the **gap down** from the club above, coloured **tight** (18 m or less), **watch** (up to 25 m) or **a hole** (more). Each club shows five **confidence** dots, a star if it is the go-to and a note icon if it has a note. A hole in the bag is visible at a glance.
3. **Putter and ball** — their own tiles: model, and the putter's confidence.
4. **Notes to self** — the golfer's own words, quoted back ("My go-to. Smooth tempo, never force it.").

# Tuning a club

Tap any club, the putter or the ball and a sheet opens:

- **Model** — free text.
- **How far it carries** — big, with −5 / −1 / +1 / +5 steps (20–350 m), and a live line for the gaps either side as it would be after the change ("10m shorter than your 6 iron · 10m longer than your 8 iron"), coloured like the ladder.
- **How much do you trust it?** — one to five, with words (Shaky, Getting there, Reliable, Confident, Go-to). Tap the current rating again to clear it.
- **Note to self** — up to 160 characters.

**Save** keeps it (a success haptic), closes the sheet, and the ladder animates: the bar slides to its new length and the clubs re-sort. Dismissing the sheet changes nothing. A putter or ball has no carry.

# How it is built

- `models/bag_club.dart` — a club or the ball: id, name, family, model, carry, note, confidence.
- `models/placeholder_my_bag.dart` — the starting bag: Driver, 3 wood, 5 wood, Hybrid, 5–9 iron, pitching, gap, sand and lob wedge and a putter: a complete bag of 14 clubs (the most the rules allow) plus the ball. The models are the golfer's placeholder kit from before (TaylorMade Qi35 / P790, Cleveland RTX, Odyssey White Hot, Titleist Pro V1); the carries average to the old "Driver 235 m / Irons 145 m / Wedges 95 m".
- `logic/bag_insights.dart` — pure, tested: ordering by carry, gaps and how they read, the widest gap, the go-to club, the gapping sentence, the confidence words.
- `state/bag_controller.dart` — `BagController` is the only way a club changes (clamped carry, trimmed model and note). The bag is saved on the device after every change.
- `repositories/bag_codec.dart` — stores only the editable fields, keyed by club id, **laid over the starting bag**; a club added to the starting bag later still appears, and an unreadable document starts the bag as new.
- `core/services/document_storage.dart` — a shared storage seam (one JSON document under a key). Golf Bag is the first user; Trips and Rounds still have their own copies (TD-017).

# Single source of truth

Golf Bag now owns the bag. **Profile no longer carries an equipment list** (`profileEquipment` is deleted); Profile shows no equipment at all. The old `ClubDistance` model and the Driver/Irons/Wedges averages are gone; the ladder is the distances.

# Placeholders and limits

- The starting bag, its notes and its confidence ratings are placeholder data until the golfer edits them.
- Distances are the golfer's own stated carries, not measured. There is no shot tracking.
- No adding, removing or renaming clubs: the bag has fixed slots in Release 1. Changing the model covers a swap.
- Carries are metres only; the app has no units setting yet.
- `docs/standards/placeholder-golf-bag-data.md` describes the old data and is superseded.
