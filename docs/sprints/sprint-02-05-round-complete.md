# Sprint 2.5 — Round Complete

**Status:** Planned

---

# Sprint Goal

Build the end-of-round experience.

When all 18 holes are completed, the round is finalised and players are shown the results.

This sprint completes the MVP scoring flow.

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

Provide a satisfying end to every round.

Players should immediately know:

- Who won
- Final scores
- Relative-to-par
- Final rankings

The experience should feel polished and rewarding.

---

# Build

Create:

- Round Complete Screen
- Final Leaderboard
- Winner Card
- Final Player Rankings
- Round Summary
- Return to Dashboard action

---

# Winner Card

Display:

🏆 Winner

Player Name

Final Score

Relative to Par

Position

Example

Winner

Matt

69

-3

---

# Final Leaderboard

Display:

Position

Player Name

Gross Score

Relative to Par

Total Holes

Display tied positions correctly.

---

# Round Summary

Display:

Course Name

Date

Players

Completed Holes

Winner

Round Status

Example

Royal Melbourne

18 Holes

4 Players

Completed

Winner: Matt

---

# Actions

Provide:

Return Home

Start New Round

These remain placeholder actions.

Navigation only.

---

# Completion Rules

Round becomes complete when:

All players have completed Hole 18.

No business logic beyond this rule.

---

# Placeholder Data

Continue using:

docs/placeholder-data.md

No saving.

No backend.

No networking.

---

# Responsive Layout

Desktop

Centered summary

Wide leaderboard

Tablet

Responsive cards

Mobile

Single-column layout

Large buttons

Comfortable spacing

---

# Components

Possible reusable widgets:

- WinnerCard
- FinalLeaderboard
- RoundSummaryCard
- CompletionActions

Reuse existing widgets wherever possible.

Avoid duplicated UI.

---

# Design Rules

Use only:

Typography tokens

Spacing tokens

Colour tokens

Radius tokens

Responsive widgets

Existing shared widgets

No hardcoded styling.

---

# Do Not Build

Do not build:

History

Statistics

Share Results

PDF Export

Stableford

Handicaps

Player Profiles

Photos

Trips

Friends

Notifications

Supabase

Authentication

Saving completed rounds

---

# Acceptance Criteria

Users can:

- Finish a round
- View the winner
- View final leaderboard
- View final scores
- View round summary
- Return to Dashboard
- Start another placeholder round
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
- Recommendations for Sprint 3

Stop after completion.

Do not begin Sprint 3.