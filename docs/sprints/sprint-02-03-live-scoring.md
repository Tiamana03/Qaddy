# Sprint 2.3 — Live Scoring

**Status:** Planned

**Sprint Goal**

Build the live scorecard used during a round.

This sprint introduces the score entry experience while still using placeholder data.

No persistence is implemented.

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

Allow players to record scores hole-by-hole.

The experience should feel extremely quick and require as few taps as possible.

This becomes the foundation for every future scoring feature.

---

# Build

Create:

- Live Scorecard Screen
- Hole Navigation
- Score Input Controls
- Running Totals
- Front Nine Total
- Back Nine Total
- Overall Total
- Relative-to-Par calculation

---

# Score Entry

Each hole displays:

- Hole Number
- Par
- Stroke Index
- Distance
- Current Score

Players may:

Increase score

Decrease score

Score cannot be lower than 1.

---

# Navigation

Users can move:

Previous Hole

Next Hole

Jump to Hole

Current hole should always be obvious.

---

# Running Totals

Continuously calculate:

Front 9

Back 9

18 Hole Total

Total vs Par

No database required.

Everything remains in memory.

---

# Layout

Desktop

Responsive Max Width

Large score controls

Tablet

Centered scorecard

Mobile

Optimised for one-handed scoring

Large touch targets

---

# Components

Use existing shared widgets where possible.

Create reusable widgets only if duplication would occur.

Potential widgets:

- HoleHeader
- ScoreStepper
- RunningTotalsCard

---

# Placeholder Data

Continue using:

docs/standards/placeholder-data.md

No API.

No Supabase.

No persistence.

---

# Design Rules

Use:

Typography tokens

Spacing tokens

Colour tokens

Radius tokens

Responsive widgets

No hardcoded styling.

---

# Do Not Build

Do not build:

Statistics

Leaderboards

Stableford

Match Play

Handicap calculations

GPS

Offline sync

Saving rounds

Editing completed rounds

Player management

Authentication

Supabase

---

# Acceptance Criteria

Users can:

- View every hole
- Enter scores
- Navigate between holes
- View running totals
- Complete every hole
- Experience responsive layouts
- Encounter no duplicated UI

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
- Recommendations for Sprint 2.4

Stop after completion.

Do not begin Sprint 2.4.