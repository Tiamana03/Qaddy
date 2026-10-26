/// What the Trips hero can say about a trip beyond its name and dates.
///
/// Everything here is read from the trip's own plan (courses, weather,
/// expenses, members, chat) — nothing is invented, and a section the golfer
/// hasn't filled in simply doesn't appear. A brand-new trip therefore yields
/// an empty snapshot, and the hero shows only its countdown and dates.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

/// One labelled fact on the hero, e.g. "First tee — Kingston Heath · 8:10 AM".
class TripHighlight {
  const TripHighlight({
    required this.icon,
    required this.label,
    required this.value,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Whether the fact needs a full row (long values) rather than half of one.
  final bool wide;
}

/// The hero's supporting facts for one trip.
class TripSnapshot {
  const TripSnapshot({
    required this.highlights,
    required this.squad,
    this.latestUpdate,
  });

  /// Short facts: first tee time, forecast, expenses.
  final List<TripHighlight> highlights;

  /// Names of the confirmed players ("who's going").
  final List<String> squad;

  /// The most recent chat message, as "Sender: message".
  final String? latestUpdate;

  /// Whether there is anything to show.
  bool get isEmpty =>
      highlights.isEmpty && squad.isEmpty && latestUpdate == null;
}

/// The snapshot for a trip with the given [plan].
TripSnapshot tripSnapshot(TripPlan plan) {
  final courses = [...plan.courses]
    ..sort((a, b) => a.teeTime.compareTo(b.teeTime));
  final summary = summariseExpenses(plan.expenses);

  return TripSnapshot(
    highlights: <TripHighlight>[
      if (courses.isNotEmpty)
        TripHighlight(
          icon: Icons.golf_course_outlined,
          label: 'First tee',
          value:
              '${courses.first.name} · '
              '${courses.first.teeTime.toFriendlyTime()}',
          wide: true,
        ),
      if (plan.weather.isNotEmpty)
        TripHighlight(
          icon: plan.weather.first.condition.icon,
          label: '${plan.weather.first.day} forecast',
          value:
              '${plan.weather.first.forecast}, ${plan.weather.first.highLabel}',
        ),
      if (plan.expenses.isNotEmpty)
        TripHighlight(
          icon: Icons.receipt_long_outlined,
          label: 'Expenses',
          value: summary.isSettled
              ? 'All settled'
              : '${formatMoney(summary.outstanding)} outstanding',
        ),
    ],
    squad: <String>[
      for (final member in plan.confirmedMembers) member.displayName,
    ],
    latestUpdate: plan.messages.isEmpty
        ? null
        : '${plan.messages.last.sender}: ${plan.messages.last.text}',
  );
}
