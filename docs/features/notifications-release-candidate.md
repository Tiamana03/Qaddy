# Notifications — Release Candidate

**Status:** Implemented (November 2026)

**Scope:** the Notifications screen (`/home/notifications`) and the bell on Home.

---

# Why

Notifications were four hard-coded sentences ("Josh accepted your invitation.", "New version of Qaddy available.") under a "Total Notifications" statistic card. Nothing could be read, the bell was always lit and nothing was tappable.

# The idea

A live feed of what is really going on in the golfer's golf — **worked out, not stored** — with what they have not seen lit up and every line one tap from where it matters.

# What it tells the golfer

Round in progress (back to the scorecard) · the next round and how soon (Rounds) · friend requests waiting (Requests) · the next trip and how far away (the trip) · mates who have not replied to it (Invite) · where they stand in their group's season (the group) · achievements earned (Profile) · "Add your handicap" when there is none (Settings) · a welcome. Each has a stable id, so reading it reads it for good; when what it says changes (a new position, another achievement) it is new again, and when it stops being true (a request accepted) it disappears.

# The screen

"What's happening", a pulse ("3 new", "You're all caught up"), **New** (with a count) and **Earlier**. Each row has a coloured icon badge, the message (bold while unread), a detail line, when or how soon, and a gold dot while unread. Tapping reads it and goes there (tabs are gone to, other screens pushed). **Mark all read** clears the lot. If every kind has been switched off, the screen says so and points to Settings.

# The bell

The dot on Home's bell shows only when something is unread, and the tooltip says how many.

# Settings

Four real switches (Rounds, Mates and groups, Trips, Tips and milestones) choose what appears in the feed and counts on the bell. They are in-app only: Qaddy sends no push notifications, and says so.

# How it is built

- `logic/notification_feed.dart` — pure: `buildNotificationFeed(NotificationInputs)`.
- `state/notifications_controller.dart` — the read set and switched-off kinds (key `qaddy.notifications.v1`), `notificationFeedProvider` (derived from rounds, friends, trips, groups, achievements and the golfer), `notificationEntriesProvider`, `unreadNotificationCountProvider`.
- Single source of truth: nothing here owns data; it reads each feature's own.

# Placeholders and limits

The group table, the seeded trips and the friend requests are seeded data, so those notifications are too; round and achievement notifications come from rounds the golfer really plays. There is no push, no history of past notifications and no swipe-to-dismiss.
