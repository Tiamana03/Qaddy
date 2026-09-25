# Trip Lifecycle

**Version:** 1.0  
**Status:** Architecture Approved

---

# Purpose

This document defines the lifecycle of a Trip within Qaddy.

A Trip progresses through a series of clearly defined stages from planning to historical archive.

This lifecycle ensures every Trip follows the same structure regardless of destination, duration, or number of participants.

No implementation may introduce additional lifecycle states without updating this document.

---

# Overview

A Trip moves through the following stages:

```
Planning

↓

Inviting

↓

Confirmed

↓

In Progress

↓

Completed

↓

Archived
```
Cancelled may occur from Planning, Inviting, or Confirmed.
Each stage has different permissions, available actions, and business rules.

---

# Lifecycle States

## Planning

The trip has been created but is still being organised.

Typical activities:

- Destination selected
- Dates chosen
- Courses added
- Accommodation discussed
- Budget estimated

Only Owners and Admins may edit the trip.

---

## Inviting

Invitations have been sent.

Players may:

- Accept
- Decline
- View details

Owners may continue updating trip details while invitations remain open.

---

## Confirmed

Enough players have accepted.

The trip is considered locked.

Typical activities:

- Final itinerary
- Flights booked
- Accommodation confirmed
- Tee times confirmed
- Transport organised

Minor edits remain allowed.

---

## In Progress

The trip is currently underway.

Examples:

- Daily itinerary
- Live scoring
- Expense tracking
- Photo uploads
- Checklists
- Chat

Most interaction occurs during this stage.

---

## Completed

The trip has finished.

The trip becomes read-only except for administrative corrections.

Examples:

- Final statistics
- Expense summary
- Trip leaderboard
- Awards
- Photo gallery

---

## Archived

Historical storage only.

Trips remain viewable forever.

Statistics continue contributing to:

- Player history
- Group history
- Achievements
- Lifetime statistics

Archived trips cannot be edited.

---

# Lifecycle Diagram

```
Planning
      │
      ▼
Inviting
      │
      ▼
Confirmed
      │
      ▼
In Progress
      │
      ▼
Completed
      │
      ▼
Archived
```
Cancelled may occur from Planning, Inviting, or Confirmed.
Trips only move forward through the lifecycle.

---

# State Responsibilities

| State | Editable | Invitations | Scoring | Expenses | Photos |
|--------|----------|-------------|----------|-----------|---------|
| Planning | ✅ | ❌ | ❌ | ❌ | ❌ |
| Inviting | ✅ | ✅ | ❌ | ❌ | ❌ |
| Confirmed | Limited | Closed | ❌ | Optional | ❌ |
| In Progress | Limited | Closed | ✅ | ✅ | ✅ |
| Completed | Admin Only | Closed | Locked | Finalised | ✅ |
| Archived | ❌ | ❌ | Locked | Locked | View Only |

---

# Business Rules

- Every Trip begins in Planning.
- Invitations cannot be sent until required trip information is completed.
- A Trip cannot become In Progress before its start date unless manually overridden.
- Completed Trips become read-only.
- Archived Trips remain permanently available.
- Historical Trips must never lose statistics or media.

---

# Permissions

Permissions vary by lifecycle stage.

Owners and Admins generally control:

- Editing
- Invitations
- Itinerary
- Expenses
- Trip settings

Members participate by:

- Accepting invitations
- Viewing schedules
- Recording scores
- Uploading photos
- Logging expenses (where permitted)

Detailed permissions are defined in:

```
group-permissions.md
```

---

# Data Flow

```
Create Trip

↓

Invite Players

↓

Confirm Attendance

↓

Book Travel

↓

Play Golf

↓

Record Results

↓

Complete Trip

↓

Archive History
```

Each stage feeds information into the next.

---

# Statistics Integration

Completed Trips contribute towards:

- Trips Played
- Courses Visited
- Countries Played
- Group Statistics
- Player Statistics
- Achievements

Trip data should automatically update these systems.

---

# Achievement Integration

Trips may unlock achievements such as:

- First Golf Trip
- Five Trips Completed
- Overseas Golfer
- Weekend Warrior
- Course Collector

Achievement logic belongs in:

```
profile-achievements.md
```

---

# Future Expansion

Future lifecycle enhancements may include:

- Draft Templates
- Waitlists
- Multi-leg Trips
- International Travel
- Tournament Trips
- Sponsor Events
- Automatic Check-ins
- AI Travel Assistant
- Live Weather Monitoring
- Emergency Contacts

Future additions should extend the lifecycle without replacing it.

---

# Engineering Decisions

Trip status represents the overall state of the trip.

Individual bookings (flights, accommodation, tee times) should manage their own statuses independently.

This keeps the lifecycle simple while allowing detailed tracking within each component.

---

# Flutter Implementation Notes

Trip lifecycle logic should remain inside:

```
lib/features/trips/
```

Status indicators should reuse shared widgets such as:

- QaddyStatusBadge
- QaddyCard
- QaddyAvatar

Lifecycle state should determine which actions are available within the UI.

---

# Related Documents

- trip-data-model.md
- profile-data-model.md
- group-data-model.md
- group-permissions.md
- profile-achievements.md
- system-overview.md

---

**End of Document**