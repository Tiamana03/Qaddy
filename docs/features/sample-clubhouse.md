# Sample Clubhouse

**Status:** Implemented (November 2026)

**Philosophy:** Qaddy never pretends Tom, Ben or the Saturday Boys are real unless the golfer created them. What the app comes with is a **Sample Clubhouse** — pretend mates, a group, a trip, a rivalry, a season table and a Saturday round, there so a new golfer can see what Qaddy does. It is always labelled Sample, and the golfer can **keep it, edit it or remove it**.

---

# The experience

- **Onboarding** has a page for it: *"Meet your Sample Clubhouse"* — pretend mates, a group and a trip, "always labelled Sample", "keep it, edit it or remove it later".
- **Setup ("Who's teeing off?")** has a switch, on by default: *"Start with a Sample Clubhouse"*. Switched off, the golfer starts with an empty clubhouse.
- **Settings → Sample Clubhouse** says whether it is on, what is in it, and lets the golfer **remove** it (after a confirmation that their own rounds, trips and bag stay) or **bring it back**.
- The choice is kept on the phone (`qaddy.sample.v1`); a returning golfer gets what they chose.

# How it is labelled

Wherever sample content appears it says so, and a test enforces it for every screen that shows any:

| Where | Label |
|---|---|
| Friends Home | A **Sample Clubhouse** banner ("pretend, so you can see how Qaddy works… Keep it, edit it or remove it in Settings"); "5 sample mates"; "SAMPLE ROUND" and "SAMPLE RIVALRY" |
| Friend cards and profiles | SAMPLE badge |
| Groups list and a group | Banner, SAMPLE badge |
| Trips | SAMPLE badge on a sample trip's card, hero and details; the golfer's own trips carry none |
| Home | "SAMPLE ROUND · …" on the hero; "From your sample mates"; the season line says "(sample)" |
| Rounds | "SAMPLE ROUND · FIRST TEE"; mates are "Sample mate · HCP …"; "On the course (sample)" |
| Search | "Sample mate / group / trip / round" in each result |
| Notifications | A SAMPLE badge on notifications that come from sample content; the welcome says the Sample Clubhouse is ready |

# What an empty clubhouse looks like

Honest invitations rather than pretend people: Home says **"Ready when you are"** with *Start a round*, and *Your mates* with **Invite a mate**; Rounds is just the golfer; Friends says **"Build your squad"**; Groups says **"No groups yet"**; Trips is empty; Notifications has no friends, groups or trips in it. Nothing from the sample world appears anywhere — a test walks every screen and fails on any sample name, group, trip or course.

# Rounds are the golfer's own

A round now starts with **just the golfer**; they add the mates they are actually playing with (sample mates are labelled). Hole pars and distances still come from one sample 18-hole layout, and the Rounds screen says so ("until course search arrives").

# "Add Friend" is gone

Search Friends listed the seeded mates with an **Add Friend** button that did nothing. With no accounts there is no one to add, so the screen is now an honest **Invite a mate**: a message about Qaddy, sent through the share sheet.

# How it is built

- `core/user/sample_clubhouse.dart` — the switch (`sampleClubhouseOn`, set at start-up like the golfer's identity), `SampleChoice`, `sampleClubhouseProvider`, `sampleOnProvider`.
- Every seeded list answers to it: `friends`, `friendRequests`, `friendActivityFeed`, `groups`, `upcomingRound` (unplanned when off), `upcomingRoundInvitees`, `upcomingRoundSideGames` are getters; `FriendsController.setSample` and `TripsController.setSample` add and remove the sample mates and trips without touching the golfer's own (`TripsController.isSample`).
- `SampleBadge` and `SampleBanner` (`core/widgets/`) are the shared labels.
- Turning it off or on in Settings also restarts the app's navigation so every screen shows what is now true.

# Review of every seeded piece of data

| Seeded | Treatment |
|---|---|
| Friends (Tom, Ben, Luke, Josh, Nick, Sam, Liam, Jack), requests, activity, the 6–5 rivalry | Sample; labelled; gone when off |
| Groups (Saturday Boys…), members, season table, upcoming group round | Sample; labelled; gone when off |
| Trips (Melbourne, Gold Coast, Tasmania, Queenstown) and their plans, chat, expenses, awards | Sample; labelled; removable without touching the golfer's trips |
| Saturday round at Richmond (tee time, weather, 8 players, side games) | Sample; labelled; off = an unplanned "Ready when you are" round at the golfer's home course |
| Rounds' 18-hole layout | Sample; the Rounds screen says so |
| Golf bag (14 starter clubs, carries, notes) | **Still unlabelled — a known gap**, see the Release Candidate audit |
| Dashboard highlights, notifications | Derived from real state; sample-sourced ones are labelled |
| Hints in forms ("Melbourne Golf Weekend") | Replaced with neutral hints |

# Limits

The Sample Clubhouse is the same for every golfer, and some sample people still appear in places a golfer can act on (inviting "Tom" to a sample round). That is intended: it is the demonstration. The next step (Release 2) is real mates, groups and trips created by the golfer.
