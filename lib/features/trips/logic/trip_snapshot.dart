/// What the Trips hero can say about a trip beyond its name and dates.
///
/// Everything here is read from the trip's existing placeholder data
/// (members, courses, weather, expenses, chat) — nothing is invented. Only
/// the shared placeholder trip (Melbourne Golf Weekend) has that detail
/// data, so every other trip returns `null`, mirroring how the Trips list
/// only opens details for that one trip.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';

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
}

/// The snapshot for [trip], or `null` when it has no detail data.
TripSnapshot? tripSnapshot(Trip trip) {
  if (trip.id != melbourneGolfWeekend.id) {
    return null;
  }

  final firstCourse = melbourneGolfWeekendCourses.first;
  final firstForecast = melbourneGolfWeekendWeather.first;
  const outstanding = melbourneGolfWeekendOutstandingBalance;
  final latest = melbourneGolfWeekendMessages.last;

  return TripSnapshot(
    highlights: <TripHighlight>[
      TripHighlight(
        icon: Icons.golf_course_outlined,
        label: 'First tee',
        value: '${firstCourse.name} · ${firstCourse.teeTime}',
        wide: true,
      ),
      TripHighlight(
        icon: Icons.wb_sunny_outlined,
        label: '${firstForecast.day} forecast',
        value: '${firstForecast.forecast}, ${firstForecast.high}',
      ),
      TripHighlight(
        icon: Icons.receipt_long_outlined,
        label: 'Expenses',
        value: outstanding == 0
            ? 'All settled'
            : '\$${outstanding.toStringAsFixed(0)} outstanding',
      ),
    ],
    squad: <String>[
      for (final member in melbourneGolfWeekendMembers)
        if (member.status == ParticipantStatus.confirmed) member.displayName,
    ],
    latestUpdate: '${latest.sender}: ${latest.message}',
  );
}
