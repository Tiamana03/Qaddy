# Rounds Feature Integration

## Overview

This document defines how all Sprint 2 (Rounds) features are integrated into a single, seamless user experience.

The purpose of this document is **not** to introduce new functionality. Every screen, widget and model has already been implemented during Sprint 2.

Instead, this document explains how those individual components are connected together to create the complete Rounds experience.

Once implemented, a user should be able to complete an entire golf round without leaving the feature.

---

# Goals

The completed Rounds feature must allow a user to:

- Create or open a round
- Review round information
- Start a round
- Enter scores hole-by-hole
- View the live leaderboard
- Complete the round
- View final results
- Return to the dashboard or begin another round

This becomes the first fully integrated feature within Qaddy.

---

# Scope

This integration includes:

- Navigation
- Route connections
- Screen transitions
- Placeholder data sharing
- Button wiring
- Feature state
- User flow
- Reuse of existing widgets
- Reuse of existing models

This integration does **not** include:

- Authentication
- Supabase
- Cloud syncing
- Multiplayer
- Push notifications
- Payments
- AI
- Statistics calculations
- Database persistence

Everything remains placeholder-driven.

---

# Feature Flow

The complete user journey is:

Dashboard

↓

Rounds

↓

Round Setup

↓

Live Scorecard

↓

Leaderboard

↓

Round Complete

↓

Dashboard

or

↓

Start New Round

Every screen should naturally lead to the next.

Users should never reach a dead end.

---

# Integration Objectives

The Rounds feature should behave as one continuous workflow instead of several independent screens.

The user should never feel as though they are opening unrelated pages.

Each screen should naturally continue from the previous screen.

---

# Navigation Flow

## Dashboard

The Dashboard displays the user's upcoming round.

Selecting the Upcoming Round opens the Round Setup screen.

---

## Round Setup

Displays:

- Players
- Course
- Date
- Side Games
- Competition Information

Primary Action:

Start Round

↓

Live Scorecard

---

## Live Scorecard

Displays:

- Current Hole
- Hole Information
- Score Controls
- Running Totals

Primary Action:

Finish Round

↓

Leaderboard

---

## Leaderboard

Displays:

- Live Positions
- Relative to Par
- Gross Score
- Through Hole

Primary Action:

Complete Round

↓

Round Complete

---

## Round Complete

Displays:

- Winner
- Final Leaderboard
- Round Summary

Actions:

Return Home

↓

Dashboard

or

Start New Round

↓

Round Setup

---

# Route Integration

The following routes should exist within the application.

| Route | Screen |
|---------|---------|
| /home | Dashboard |
| /rounds | Round Setup |
| /rounds/live | Live Scorecard |
| /rounds/leaderboard | Leaderboard |
| /rounds/complete | Round Complete |

No additional routes should be introduced.

---

# Shared Placeholder Data

All screens should reference a shared placeholder round.

The placeholder round becomes the single source of truth throughout Sprint 2.

The following information should never be duplicated across multiple screens:

- Course
- Date
- Players
- Hole Information
- Leaderboard
- Winner
- Round Status

Future sprints will replace this shared placeholder with live data.

---

# Widget Reuse

Existing components should always be reused before creating new widgets.

Reuse includes:

- QaddyAvatar
- QaddyStatusBadge
- PlayerCard
- LeaderboardRow
- PositionBadge
- WinnerCard
- RoundSummaryCard
- HoleHeader
- RunningTotalsCard
- ScoreStepper

No duplicate versions should exist.

---

# Model Reuse

Existing models should remain the single source of truth.

Reuse:

- Round
- HoleScore
- LeaderboardEntry
- RankedLeaderboardEntry

Avoid creating duplicate placeholder models.

---

# Button Behaviour

Buttons should perform the following actions.

| Button | Action |
|---------|---------|
| Start Round | Open Live Scorecard |
| Finish Round | Open Leaderboard |
| Complete Round | Open Round Complete |
| Return Home | Open Dashboard |
| Start New Round | Open Round Setup |

No button should remain disabled once this integration is complete.

---

# Placeholder State

During Sprint 2 all information remains in memory.

No information is persisted.

Leaving the feature resets all placeholder data.

Persistent storage will be introduced in future sprints.

---

# Acceptance Criteria

The feature is considered complete when:

- A user can start a round
- A user can score every hole
- A user can view the leaderboard
- A user can complete the round
- A user can return home
- A user can immediately begin another round
- No screen becomes a dead end
- No duplicate placeholder data exists
- Existing widgets are reused wherever possible
- All tests pass

---

# Future Integration

Future releases will replace placeholder data with:

- Supabase
- Real player data
- Live multiplayer scoring
- Statistics
- AI insights
- Handicap calculations
- Round history

This document should remain focused solely on integrating the existing Sprint 2 functionality.