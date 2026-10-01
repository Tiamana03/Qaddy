# Search Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Search feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

---

## Real Backend Search

Querying an actual user/course/trip/group/round database instead of matching against in-memory placeholder lists.

Depends on Supabase and Authentication.

---

## Search Filters and Sort

Filtering by category, date range, or relevance; sorting results.

---

## Recent and Saved Searches

Remembering a user's last few queries, or letting them pin a search.

Depends on persistence, which depends on Authentication.

---

## Full Per-Item Detail Screens

Friends, Groups and Trips each currently have only one "detailed" item with a real detail screen. Once Release 2+ gives every friend/group/trip its own detail screen, every Search result becomes tappable, not just the one canonical item per category — see `docs/features/search-feature-integration.md`'s "Partial Detail Data."

---

## Courses as a Real Entity

A genuine Courses feature/model (location, par, holes, reviews) that Search could index directly, rather than reading course names that happen to already exist on Profile and Trips.

---

## Search Across Statistics, Golf Bag, Notifications and Settings

Not named in Sprint 11's goal. Revisit only if a genuine product need emerges — see `search-engineering-decisions.md`'s "Source of Truth."

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `search-data-model.md` — a Purpose section, a data model table (once one is needed), business rules, and a Do Not Build / Out of Scope section for whatever remains deferred at that time.

---

# Related Documents

- search-data-model.md
- search-engineering-decisions.md
- docs/features/search-feature-integration.md

---

**End of Document**
