# Sprint 2.4 — Leaderboard

**Status:** Planned

---

# Sprint Goal

Build the live leaderboard that updates throughout the round using placeholder data.

This sprint introduces multi-player scoring while keeping all data in memory.

No backend or networking is implemented.

---

# References

Read completely before implementation:

- docs/ai/implementation-workflow.md
- docs/architecture/round-data-model.md
- docs/architecture/navigation.md
- docs/placeholder-data.md
- docs/engineering-principles.md
- docs/project-rules.md

---

# Purpose

Provide players with a live leaderboard during the round.

As scores are entered, rankings should update immediately.

The leaderboard should be simple, fast, and easy to read.

---

# Build

Create:

- Live Leaderboard Screen
- Leaderboard List
- Player Position Indicators
- Relative-to-Par Display
- Through-Hole Indicator
- Tie Handling
- Sorting Logic

---

# Leaderboard Layout

Display:

Position

Player Name

Gross Score

Relative to Par

Current Hole

Through Indicator

Example:

1. Matt ........ -2 ..... Thru 12

2. Josh ........ E ...... Thru 12

3. Ben ......... +3 ..... Thru 11

---

# Ranking Rules

Leaderboard updates immediately whenever:

- A score changes
- A hole is completed
- A player progresses to another hole

Sorting priority:

1. Lowest score relative to par

2. Lowest gross score

3. Furthest hole completed

4. Original player order

---

# Relative To Par

Display examples:

-5

-2

E

+1

+4

Use golf-standard formatting.

---

# Player Cards

Each player row should contain:

Position

Avatar placeholder

Player Name

Score

Through Hole

Highlight the current leader.

---

# Tie Handling

If two or more players are tied:

Display equal ranking.

Example:

T1

T1

3

No duplicated ranking numbers.

---

# Placeholder Data

Continue using:

docs/placeholder-data.md

Use placeholder players only.

No networking.

No persistence.

---

# Responsive Layout

Desktop

Wide leaderboard

Tablet

Centered leaderboard

Mobile

Single-column layout

Large touch targets

Readable typography

---

# Components

Create reusable widgets where appropriate.

Possible components:

- LeaderboardRow
- PositionBadge
- ScoreChip
- ThroughHoleChip

Avoid duplicated UI.

---

# Design Rules

Use only:

Typography tokens

Spacing tokens

Colour tokens

Radius tokens

Responsive widgets

No hardcoded styling.

---

# Do Not Build

Do not build:

Realtime networking

Supabase

Firebase

Player invitations

Statistics

Stableford

Handicaps

History

Saving results

Editing completed rounds

Authentication

---

# Acceptance Criteria

Users can:

- View leaderboard
- See rankings update instantly
- View player scores
- View relative-to-par
- View through-hole progress
- View ties correctly
- Experience responsive layouts

---

# Verification

Run:

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test
```

Fix every issue before continuing.

---

# Commit

After successful verification:

Stage all files

Create a commit

Push to main

Provide a Sprint Completion Report including:

- Summary
- Files Created
- Files Modified
- Engineering Decisions
- Verification Results
- Git Status
- Recommendations for Sprint 2.5

Stop after completion.

Do not begin Sprint 2.5.