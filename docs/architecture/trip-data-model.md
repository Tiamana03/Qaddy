# Trip Data Model

**Version:** 1.0

**Status:** Active

**Source:** Product Architecture

**Last Updated:** September 2026

---

# Purpose

This document defines the canonical Trip data model used throughout Qaddy.

It is the single source of truth for:

- Trip information
- Trip lifecycle
- Trip participants
- Trip itinerary
- Trip expenses
- Trip bookings
- Trip statistics

No implementation may invent Trip fields outside this document.

---

# Design Principles

Trips represent complete golf experiences.

A Trip is far more than accommodation and flights.

Trips combine:

- Golf
- Friends
- Travel
- Competition
- Expenses
- Memories

Every future feature extends this model.

---

# Trip Model

| Field | Type | Required |
|---------|------|----------|
| id | String | Yes |
| name | String | Yes |
| destination | String | Yes |
| country | String | Yes |
| startDate | DateTime | Yes |
| endDate | DateTime | Yes |
| status | TripStatus | Yes |
| organiserId | String | Yes |
| playerCount | int | Yes |
| coverImage | String? | No |
| description | String? | No |

---

# Trip Lifecycle

Trips move through the following lifecycle.

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

```
Cancelled may occur from:

• Planning
• Inviting
• Confirmed
```

---

### Trip Status

Every Trip uses one of the following status values.

| Status | Description |
|---------|-------------|
| Planning | Trip is being created and edited. |
| Inviting | Invitations have been sent and responses are being collected. |
| Confirmed | Trip is confirmed and ready to begin. |
| In Progress | The trip has started and is currently active. |
| Completed | The trip has finished successfully. |
| Cancelled | The trip has been cancelled before completion. |
| Archived | Historical trip retained for reference only. |

---

# Trip Participants

Each trip contains participants.

## Participant Model

| Field | Type |
|-------|------|
| userId | String |
| displayName | String |
| handicap | double |
| role | TripRole |
| status | ParticipantStatus |

---

## Participant Status

| Status | Description |
|---------|-------------|
| Confirmed | Player has accepted the invitation. |
| Pending | Awaiting a response. |
| Declined | Player declined the invitation. |


---

# Trip Roles

Supported roles

- Organiser
- Player

Future releases may introduce:

- Spectator
- Guest

These are not implemented in Release 1.

---

# Trip Schedule

A Trip may contain an itinerary.

The itinerary is intentionally lightweight during Release 1.

Future releases may extend it.

---

## Itinerary Item

| Field | Type |
|---------|------|
| id | String |
| title | String |
| date | DateTime |
| time | TimeOfDay |
| type | ItineraryType |
| notes | String? |

---

## Itinerary Types

- Golf
- Travel
- Accommodation
- Dinner
- Activity
- Free Time

---

# Golf Courses

Trips may contain multiple golf courses.

## Course Model

| Field | Type |
|---------|------|
| name | String |
| location | String |
| teeTime | DateTime |
| playerCount | int |

---

# Accommodation

Trips may include accommodation.

| Field | Type |
|--------|------|
| name | String |
| address | String |
| contact | String |
| checkIn | DateTime |
| checkOut | DateTime |

---

# Flights

Trips support flight information.

Release 1 does not populate this data.

Future releases may include flight details.

| Field | Type |
|---------|------|
| airline | String |
| flightNumber | String |
| departure | DateTime |
| arrival | DateTime |

---

# Transport

Trips may include transport.

Supported transport types

- Rental Car
- Taxi
- Uber
- Bus
- Walking

---

# Expenses

Trips may track shared expenses.

## Expense

| Field | Type |
|---------|------|
| title | String |
| amount | double |
| paidBy | String |
| splitBetween | List<String> |

Release 1 displays expenses only.

Automatic calculations arrive in a future release.

---

# Statistics

Each trip stores summary statistics.

Examples

- Courses Played
- Total Players
- Countries Visited
- Total Spend
- Total Rounds

Statistics are read-only summaries.

---

# Photos

Trips may contain photos.

Release 1 stores placeholders only.

Gallery functionality arrives later.

---

# Chat

## Trip Message

| Field | Type |
|---------|------|
| sender | String |
| message | String |
| timestamp | DateTime |

Trip messages are placeholder-only during Release 1.

Future releases may introduce reactions, attachments and read receipts.

---

# Notifications

Trips may generate notifications.

Examples

- Tee Time Reminder
- Flight Reminder
- Accommodation Check-in

Release 1 does not implement notifications.

---

# Relationships

Trip

↓

Participants

↓

Rounds

↓

Scores

↓

Statistics

Trips may also contain

- Flights
- Accommodation
- Expenses
- Photos
- Chat
- Transport

---

# Engineering Decisions

## Stable Identifiers

Every Trip uses a unique immutable id.

---

## Date Range

Every Trip must contain both

- Start Date

and

- End Date

Single-day trips use the same value for both.

---

## Organiser

Every Trip has exactly one organiser.

Future releases may allow multiple organisers.

---

## Cover Images

Cover images are optional.

If none exists, the UI displays a placeholder image.

---

## Statistics

Statistics are derived values.

They must never be manually entered.

---

## Feature Scope

This document defines the data model for the complete Trips feature.

Implementation order is defined by
docs/features/trips-feature-integration.md.

Individual sprint documents exist only to document design decisions and are no longer the primary implementation source.
---

# Future Expansion

Future releases may add

- AI Itinerary Planning
- Flight APIs
- Accommodation APIs
- Weather
- Currency Conversion
- Shared Expenses
- Live Trip Chat
- Media Gallery
- Offline Mode
- Push Notifications

This document should be extended rather than replaced.