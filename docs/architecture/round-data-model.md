# Round Data Model

**Version:** 1.0

**Status:** Draft

**Sprint:** 2.2

---

# Purpose

This document defines the complete data model for a golf round within Qaddy.

It is the single source of truth for:

- Round structure
- Hole structure
- Player scores
- Stableford calculations
- Side games
- Round status
- Future expansion

All future features must build upon this model.

No implementation may invent additional fields without this document being updated.

---

# Design Principles

The Round model must be:

- Simple
- Extendable
- Immutable where practical
- Easy to serialize
- Compatible with Supabase

The data model should support both casual golfers and competitive events.

---

# Round Lifecycle

Every round progresses through the following states:

1. Created
2. Players Added
3. Course Selected
4. Side Games Configured
5. Round Started
6. In Progress
7. Completed
8. Archived

Only completed rounds contribute to player statistics.

---

# Round Model

Each Round contains:

| Field | Type | Description |
|---------|------|-------------|
| id | String | Unique round ID |
| courseId | String | Course being played |
| organiserId | String | User who created the round |
| name | String | Optional round name |
| createdAt | DateTime | Creation timestamp |
| teeTime | DateTime | Scheduled tee time |
| status | RoundStatus | Current round state |
| scoringFormat | ScoringFormat | Stroke / Stableford |
| players | List<PlayerRound> | Players participating |
| holes | List<HoleScore> | Scores for each hole |
| sideGames | List<SideGame> | Active side competitions |

---

# Player Round

Each player contains:

| Field | Type |
|---------|------|
| userId | String |
| displayName | String |
| handicap | double |
| currentGross | int |
| currentNet | int |
| stablefordPoints | int |
| position | int |

### Player Status

Each player has a participation status.

Available values:

- Confirmed
- Pending
- Declined

This status represents attendance for the round.

It does not represent online presence.

## Hole Count

Represents the number of holes scheduled for a round.

Typical values:

- 9
- 18

This is separate from the HoleScore list, which stores the score for each individual hole during play.
---

# Hole Score

Each hole records:

| Field | Type |
|---------|------|
| holeNumber | int |
| par | int |
| strokeIndex | int |
| grossScore | int |
| netScore | int |
| stablefordPoints | int |
| putts | int |
| fairwayHit | bool |
| greenInRegulation | bool |

---

# Scoring Formats

Release 1 supports:

- Stroke Play
- Stableford

Future versions may add:

- Match Play
- Ambrose
- Four Ball
- Scramble

These are intentionally out of scope.

---

# Side Games

Supported in Release 1:

- Longest Drive
- Nearest the Pin
- Drive & Chip

Each side game stores:

- Hole Number
- Winner
- Optional Prize

---

# Round Status

The following status values exist:

- draft
- ready
- active
- completed
- archived

No additional status values may be introduced without updating this document.

---

# Statistics Ownership

Statistics are NOT stored inside the Round.

Statistics are calculated separately from completed rounds.

This prevents duplicated data and keeps the round immutable.

---

# Engineering Decisions

## One Source of Truth

A completed round becomes immutable.

Statistics should always be recalculated from rounds rather than duplicated.

---

## Future Compatibility

The model intentionally includes placeholders for:

- Live scoring
- Multiplayer syncing
- AI Insights
- Tournament mode
- Team events

These features are not implemented during Sprint 2.

---

# Out of Scope

Sprint 2 does NOT include:

- Database tables
- Supabase
- API models
- Network serialization
- Offline syncing
- Live multiplayer

---

# Acceptance Criteria

Sprint 2.2 is complete when:

- Round model is fully documented
- Hole model is defined
- Player model is defined
- Status lifecycle exists
- Side games are documented
- Future compatibility is preserved
- No implementation decisions remain ambiguous
