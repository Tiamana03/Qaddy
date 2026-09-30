# Statistics Future Roadmap

**Version:** 1.0

**Status:** Active

---

# Purpose

This document consolidates future features for the Statistics feature that are documented but explicitly not implemented in Release 1.

None of the items below should be implemented until a future sprint document authorises them.

---

## Multi-Point Historical Trends

Real time-series data (month-by-month or round-by-round) for Handicap, Average Score and other statistics, rendered as a line chart.

Depends on a historical rounds dataset that does not exist yet — see `statistics-engineering-decisions.md`'s "Trends Use Two-Point Deltas, Not Time Series." Release 1's two-point deltas are the placeholder-data-safe stand-in.

---

## A Charting Library

Line charts, bar charts and pie charts for scoring distribution, fairways/GIR trends and season standings over time.

Depends on selecting and approving a charting package (e.g. `fl_chart` or similar) — a genuine dependency decision, not something introduced inside a documentation pass. See `statistics-engineering-decisions.md`'s "No Charting Library in Release 1."

---

## Custom Date Range Filtering

Viewing statistics for a specific month, season or custom range rather than lifetime totals only.

---

## Per-Course Statistics

Breaking down scoring statistics by individual golf course (e.g. average score at Richmond Golf Club specifically).

Depends on a per-course round history that does not exist yet.

---

## Round-by-Round History Log

A detailed, scrollable log of every completed round contributing to these totals.

Depends on Rounds maintaining a history of completed rounds, which Release 1 does not — `round-data-model.md`'s placeholder data is a single current/upcoming round only.

---

## Comparing Statistics Against Friends

Head-to-head statistical comparison beyond the single Rivalry Performance record already shown (e.g. comparing Average Score or Fairways Hit against any friend, not only Tom).

---

## Export and Sharing

Exporting statistics as an image or PDF, or sharing a season summary card.

---

## AI-Driven Insights

Automated observations about scoring trends, strengths and weaknesses — part of Qaddy's longer-term Golf IQ / AI direction referenced in `founder-blueprint.md` and `product-specification.md`.

---

# Engineering Note

Each future feature above should, when scheduled, receive its own architecture document following the same structure as `statistics-data-model.md` — a Purpose section, a data model table, business rules, and a Do Not Build / Out of Scope section for whatever remains deferred at that time.

---

# Related Documents

- statistics-data-model.md
- statistics-engineering-decisions.md
- docs/features/statistics-feature-integration.md

---

**End of Document**
