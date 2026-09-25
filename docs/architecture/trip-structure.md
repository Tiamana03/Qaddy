# Trip Structure

**Version:** 1.0  
**Status:** Architecture Approved

---

# Purpose

This document defines the internal structure of a Trip within Qaddy.

A Trip is composed of multiple independent components that work together to provide a complete golf travel experience.

Rather than storing all information in a single model, each section of a Trip owns its own data and responsibilities.

No implementation may introduce new Trip sections without updating this document.

---

# Overview

A Trip is made up of the following sections:

```
Trip

├── Overview
├── Members
├── Itinerary
├── Courses
├── Accommodation
├── Transport
├── Flights
├── Expenses
├── Leaderboard
├── Photos
├── Documents
├── Chat
└── Statistics
```

Each section is responsible for a specific area of the Trip.

---

# Trip Overview

The Overview provides a summary of the Trip.

Examples:

- Destination
- Dates
- Status
- Organiser
- Number of Travellers
- Number of Golf Courses
- Countdown
- Budget Summary

The Overview should be the default screen when opening a Trip.

---

# Members

The Members section manages everyone participating in the Trip.

Examples:

- Organiser
- Administrators
- Travellers
- Invitation Status
- RSVP Status

Member permissions are defined in:

```
group-permissions.md
```

---

# Itinerary

The itinerary stores the daily schedule.

Examples:

- Flights
- Accommodation
- Tee Times
- Meals
- Activities
- Transport
- Free Time

Each day may contain multiple itinerary items.

---

# Courses

Stores every golf course played during the Trip.

Each Course may include:

- Course Name
- Tee Time
- Address
- Number of Holes
- Course Rating
- Slope Rating
- Weather
- Round Status

Completed Courses may link directly to Round records.

---

# Accommodation

Stores accommodation information.

Examples:

- Hotel
- Apartment
- Airbnb
- Check-in
- Check-out
- Address
- Booking Reference
- Contact Details

---

# Flights

Stores travel information.

Examples:

- Airline
- Flight Number
- Departure Airport
- Arrival Airport
- Departure Time
- Arrival Time
- Booking Reference

Multiple flights may exist within one Trip.

---

# Transport

Stores local transport information.

Examples:

- Hire Cars
- Shuttle Services
- Taxi Bookings
- Parking
- Fuel Costs

---

# Expenses

Stores all Trip expenses.

Examples:

- Accommodation
- Flights
- Green Fees
- Food
- Drinks
- Fuel
- Shopping
- Shared Costs

Expense logic should remain independent of Trip metadata.

---

# Leaderboard

Stores Trip-specific competition results.

Examples:

- Stableford
- Stroke Play
- Match Play
- Team Events
- Longest Drive
- Nearest The Pin

Trip Leaderboards remain separate from Season Leaderboards.

---

# Photos

Stores Trip memories.

Examples:

- Team Photos
- Course Photos
- Videos
- Trophy Photos
- Award Photos

Media contributes to the historical Trip record.

---

# Documents

Stores useful Trip documents.

Examples:

- Booking Confirmations
- Tee Sheets
- Travel Insurance
- Maps
- Packing Lists

Documents are optional.

---

# Chat

Provides communication between Trip members.

Examples:

- Messages
- Announcements
- Polls
- Shared Links

Chat history remains attached to the Trip.

---

# Statistics

Tracks Trip-specific statistics.

Examples:

- Courses Played
- Rounds Played
- Stableford Average
- Birdies
- Eagles
- Winning Percentage
- Prize Money
- Distance Travelled

These statistics contribute to player lifetime statistics.

---

# Relationships

```
Trip
│
├── Members
├── Courses
│      │
│      └── Rounds
│
├── Expenses
├── Leaderboard
├── Photos
├── Documents
├── Chat
└── Statistics
```

Each section owns its own data.

Relationships should use references wherever possible.

---

# Business Rules

- Every Trip must have one Organiser.
- A Trip may contain multiple golf courses.
- A Course may contain multiple Rounds.
- Every Expense belongs to one Trip.
- Every Photo belongs to one Trip.
- Every Leaderboard belongs to one Trip.
- Historical Trips remain read-only after archival.

---

# Engineering Decisions

The Trip model should remain lightweight.

Large collections such as:

- Photos
- Expenses
- Chat
- Documents

should remain separate feature models referenced by the Trip.

This keeps data loading efficient and avoids oversized documents.

---

# Future Expansion

Future Trip modules may include:

- Live Weather
- Currency Conversion
- Emergency Contacts
- AI Trip Planner
- Restaurant Bookings
- Equipment Hire
- Travel Checklist
- Local Attractions
- Live Flight Tracking
- Travel Notifications

Future modules should plug into the existing structure without changing existing components.

---

# Flutter Implementation Notes

Trip functionality should remain inside:

```
lib/features/trips/
```

Suggested feature structure:

```
trips/

├── overview/
├── members/
├── itinerary/
├── courses/
├── accommodation/
├── flights/
├── transport/
├── expenses/
├── leaderboard/
├── photos/
├── documents/
├── chat/
└── statistics/
```

Each module should own its own screens, widgets, services, and models.

---

# Related Documents

- trip-data-model.md
- trip-lifecycle.md
- profile-data-model.md
- group-data-model.md
- round-data-model.md
- system-overview.md

---

**End of Document**