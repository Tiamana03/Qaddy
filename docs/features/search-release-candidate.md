# Search — Release Candidate Polish

**Status:** Implemented (November 2026)

**Governed by:** `docs/ai/release_candidate_master_prompt.md` and `docs/standards/shared-ui-patterns.md`.

**Scope:** the global Search screen (`/home/search`, reached from the Dashboard).

---

# Why

Search was a bare search box over five plain headings and rows. Only one friend (Tom) opened anywhere; every other friend was a dead row, and pending or declined friends showed up as if they were mates.

# The screen

- **"Find anything"** with a one-line pulse beneath: "Mates, rounds, trips, groups and courses", then "3 results for “tom”" as you type (nothing found says so).
- **Results by category**, each under the shared section heading with a count. Rows have a coloured icon badge per category (rounds teal, trips sky, groups in the group's own colour, courses orange) or the mate's face, a subtitle that says something ("HCP 8 · Richmond Golf Club", "Next round · Saturday, 8:20 AM", "8 members · 2026 Season", "On Melbourne Golf Weekend") and a chevron. The part of the title that matched is picked out in **gold**, so the golfer sees why it was found.
- Rows arrive one after another as they appear.
- **Every result opens something:** a mate opens their card (the Friends peek sheet), the next round opens Rounds, a trip its page, a group its clubhouse, a course its page on the trip or Profile.
- **Nothing found** is friendly ("Nothing on the fairway for “zzz”…") with a **Clear search** button.

# How it is built

- Friends come from `confirmedFriendsProvider`, so only mates who said yes appear and an accepted friend shows straight away (this is one step of TD-014).
- `SearchResult` gained an optional `accent` for the icon badge. Search still owns no data; every field is built at display time from the feature that owns it.
- Reused: `QaddySectionHeading`, `QaddyCard`, `QaddyIconBadge`, `QaddyAvatar`, `QaddyEmptyState`, `QaddyFadeSlideIn`, `showFriendPeek`, `handicapLabel`, `accentForGroup`.

# Placeholders and limits

- The Rounds category finds the upcoming round's course only; finished rounds are not searched.
- Courses come from Profile's favourite courses and the courses on trips. There is no course directory.
- Matching is a case-insensitive "contains" on the name; there is no ranking or history of recent searches.
