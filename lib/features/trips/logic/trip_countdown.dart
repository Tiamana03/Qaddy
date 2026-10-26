/// The countdown shown on the Trips hero: how a trip's dates relate to today.
///
/// Pure logic (takes `now` as a parameter) so it can be tested without
/// depending on the real calendar.
library;

import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/trips/models/trip.dart';

/// A headline value and its caption, e.g. "33" / "days to go".
class TripCountdown {
  const TripCountdown({required this.value, required this.label});

  /// The large figure or word ("33", "Today", "Now").
  final String value;

  /// The short caption beneath/beside it ("days to go").
  final String label;
}

/// Describes [trip]'s timing relative to [now] (defaults to the real now).
TripCountdown tripCountdown(Trip trip, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final daysToStart = today.calendarDaysUntil(trip.startDate);

  if (daysToStart > 1) {
    return TripCountdown(value: '$daysToStart', label: 'days to go');
  }
  if (daysToStart == 1) {
    return const TripCountdown(value: '1', label: 'day to go');
  }
  if (daysToStart == 0) {
    return const TripCountdown(value: 'Today', label: 'your trip starts');
  }
  if (today.calendarDaysUntil(trip.endDate) >= 0) {
    return const TripCountdown(value: 'Now', label: 'trip underway');
  }
  return const TripCountdown(value: 'Done', label: 'trip finished');
}
