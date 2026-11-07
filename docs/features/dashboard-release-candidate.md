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

Composed as the approved mockup (`design/mockups/dashboard/dashboard-home-v1.png`) draws it, top to bottom:

1. **Header** — the brand mark and wordmark (placeholder for the crown lockup), then Search, Notifications (with a gold unread count) and the golfer's avatar, which opens their profile.
2. **Hero** (`HomeHero`) — a 200 px photo slot (`QaddyMediaPlaceholder`) with the greeting that follows the hour, the golfer's name and today's date at the bottom left, and a frosted weather card (temperature, condition, course, "Sample") at the top right. The weather is the upcoming round's forecast and only appears while a round is planned.
3. **Shortcuts** — four tiles that all work: Start a round / Continue round (featured, green), Plan a trip, Invite a mate, My stats.
4. **Upcoming round** (`UpcomingRoundCard`) — a thumbnail slot, the course, the day, how close it is ("Today", "Tomorrow", "In 6 days"), the tee time, the faces of who is playing, **View details** (shares when, where and "Who's in?") and the gold **Get ready** (opens Rounds). With nothing planned it is **Start round**; while a round is under way it says "Hole N of M" and **Continue round** opens the scorecard. "See all" opens Rounds.
5. **Your game** (`YourGameTiles`) — four tiles: Handicap, Rounds, Best score, Wins; a dash for what is not known yet. Shown once there is a handicap or a finished round; opens Statistics.
6. **Next trip** — a countdown card for the soonest upcoming trip, in that trip's own colours; it opens the trip. With no trips the "Plan a trip" shortcut is the way in.

The mates feed and the highlights moved off Home: the mockup has neither, and Friends and Statistics already carry them. Nothing on the screen is a dead end, and nothing is disabled.

# Motion and feel

Reuses the Trips language: staggered entrance for sections and shortcut tiles; the countdown and handicap count up; press-down cards; a selection haptic on shortcuts. Reduce-motion turns every animation off; nothing loops.

# Logic

`features/dashboard/logic/dashboard_insights.dart` holds the pure logic, unit-tested without UI: the greeting for an hour, days until a weekday, the round countdown and its eyebrow, the date line and the share message. `dashboardClockProvider` is the clock it all reads, so tests (and later, previews) choose "now".

The countdown works from the round's day name ("Saturday") because the placeholder round has no calendar date. When Rounds gains real dates, `roundCountdown` should take the date instead (see TD-015).

# Small changes elsewhere

- New route `/rounds/scorecard` (Live Scorecard), so "Score a round" has somewhere to go. The scorecard shows an app bar with a back arrow when it was opened from another screen, and nothing extra when it stands alone.
- The Dashboard no longer imports a `QuickActionCard`; that file is deleted.
- Navigation tests that used the Dashboard's "Good Morning," as a marker now use "Upcoming round", which does not depend on the hour.

# Rounds integration

While a round is being played the upcoming-round card shows "Hole N of M" with **Continue round**, and the first shortcut becomes *Continue round*.

# Placeholders and limits

- The Sample Clubhouse supplies the upcoming round, its forecast and the trip; each says "Sample".
- Weather is placeholder text ("21°C Sunny"), not a forecast.
