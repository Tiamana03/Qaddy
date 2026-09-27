# Activity Feed

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the Activity Feed screen and the Activity Feed Item model.

Activity Feed shows a chronological list of what the user's friends have been doing across Qaddy.

No implementation may introduce additional Activity Feed Item fields without first updating this document.

---

# Activity Feed Item Model

| Field | Type | Description |
|--------|------|-------------|
| id | String | Unique activity identifier |
| actor | String | The friend the activity belongs to |
| type | ActivityType | The kind of activity |
| message | String | Display text for the activity |
| relatedEntity | String? | Optional related name (course, group, trip) |
| timestamp | DateTime | When the activity occurred |

---

# Activity Type

Supported values:

```
RoundCompleted
FriendJoined
GroupJoined
TripCreated
HandicapChanged
AchievementUnlocked
```

No additional activity types may be introduced without updating this document.

---

# Screen Contents

Activity Feed displays, per entry:

- Icon (derived from Activity Type)
- Actor's avatar
- Message
- Relative timestamp

Entries are ordered newest first.

---

# Source of Truth

This screen reuses the same style of activity already shown on the Dashboard (`docs/sprints/sprint-02-01-dashboard.md`'s "Recent Activity" section) but scoped to friend activity specifically, rather than the current user's own activity.

Placeholder entries are defined in `docs/standards/placeholder-friend-data.md`.

---

# Business Rules

- Activity is never manually entered — it is a display of events that have already happened elsewhere in the app.
- Activity Feed never duplicates the Dashboard's own "Recent Activity" placeholder list; it draws from the Friends-scoped list defined in `placeholder-friend-data.md`.
- Removing a friend does not delete their historical activity entries from the feed's placeholder record, consistent with `friend-relationship-model.md`'s "Removed Friendships" rules.

---

# Do Not Build

Do not build:

- Live/realtime updates
- Push notifications for new activity
- Commenting or reacting to activity
- Filtering by activity type

These belong to future releases — see `friends-future-roadmap.md`.

---

# Related Documents

- friend-data-model.md
- friend-relationship-model.md
- docs/standards/placeholder-friend-data.md
- docs/features/friends-feature-integration.md

---

**End of Document**
