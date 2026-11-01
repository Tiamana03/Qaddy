# Dashboard — Release Candidate Redesign

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md`. Trips is the approved design reference (`docs/features/trips-release-candidate.md`); the Dashboard takes its animation language, spacing, elevation and pacing, with an identity of its own.

**Scope:** the Dashboard screen (`/home`) only. Notifications, Search, Rounds and the other destinations are unchanged except where noted under "Small changes elsewhere".

---

# Why

The old Dashboard was the first screen a golfer saw and it was mostly decoration: four quick-action tiles of which three did nothing, a "View Summary" button that was disabled, a greeting that always said "Good Morning" and a list of activity that went nowhere. It told the golfer nothing about *today*.

# Identity

Trips is a journey, Friends is a clubhouse. The Dashboard is **the first tee**: what is about to happen, how your game is going and what your mates are up to — in one scroll, with a reason to tap everything.

# The screen

1. **Header** — a greeting that follows the hour ("Good morning / afternoon / evening"), the golfer's name, today's date, and Search, Notifications (with a gold dot while there is something to read) and the golfer's avatar, which opens their profile.
2. **Next round** — the hero. A countdown to the next round that counts up on arrival ("6 days to tee-off", "Today" on the day), the course and tee time, weather, format and holes, the faces of who is playing and two actions: **Get ready** (opens Rounds) and **Tell the group**, which shares a message with when, where and "Who's in?". The small line above changes as the day approaches: NEXT ROUND → GET READY → IT'S ROUND DAY.
3. **Shortcuts** — four tiles that all work: Score a round (Live Scorecard), Plan a trip (Create Trip), Add a mate (Search golfers), My stats (Statistics).
4. **Your game** — the handicap index, counting up, and what the golfer's finished rounds say: wins, rounds played, average points, best round and the last round. Before the first round it shows an invitation instead of numbers. The whole card opens Statistics (see `statistics-release-candidate.md`).
5. **Next trip** — a countdown card for the soonest upcoming trip in the Trips store, in that trip's own colours; it opens the trip. With no trips it becomes "Plan your next golf trip" and opens Create Trip.
6. **From your mates** — the two latest moments from friends, with the same cheer buttons as Friends. "See all" goes to Friends.
7. **Your highlights** — recent moments from the golfer's own game; each row opens the place it belongs (Statistics, the group, Trips, Profile).

Nothing on the screen is a dead end, and nothing is disabled.

# Motion and feel

Reuses the Trips language: staggered entrance for sections and shortcut tiles; the countdown and handicap count up; press-down cards; a selection haptic on shortcuts. Reduce-motion turns every animation off; nothing loops.

# Logic

`features/dashboard/logic/dashboard_insights.dart` holds the pure logic, unit-tested without UI: the greeting for an hour, days until a weekday, the round countdown and its eyebrow, the date line and the share message. `dashboardClockProvider` is the clock it all reads, so tests (and later, previews) choose "now".

The countdown works from the round's day name ("Saturday") because the placeholder round has no calendar date. When Rounds gains real dates, `roundCountdown` should take the date instead (see TD-015).

# Small changes elsewhere

- New route `/rounds/scorecard` (Live Scorecard), so "Score a round" has somewhere to go. The scorecard shows an app bar with a back arrow when it was opened from another screen, and nothing extra when it stands alone.
- The Dashboard no longer imports a `QuickActionCard`; that file is deleted.
- Navigation tests that used the Dashboard's "Good Morning," as a marker now use "YOUR GAME", which does not depend on the hour.

# Rounds integration

Once Rounds became real (see `rounds-release-candidate.md`), the hero shows "ROUND IN PROGRESS · Hole N of 18" with **Continue round** while a round is being played, the first shortcut becomes *Continue round*, and the last-round row shows the round just played (winner, points, "Today") and opens its results.

# Placeholders and limits

- The notification dot is always on: Notifications has no read state yet.
- Until a round has been played in the app, the last round (The Dunes), the highlights and the friends' moments are placeholder data, and the placeholder last round has no results to open.
- Weather is placeholder text ("21°C Sunny"), not a forecast.
