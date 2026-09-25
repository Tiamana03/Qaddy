/// A Trip's day-by-day schedule — see placeholder-trip-data.md's "Upcoming
/// Trip Schedule" section and `docs/architecture/trip-data-model.md`'s
/// "Itinerary Item" section.
library;

/// One day's scheduled activity.
class TripItineraryEntry {
  const TripItineraryEntry({
    required this.date,
    required this.activity,
    required this.time,
  });

  /// The date, as sourced (e.g. "28 Nov").
  final String date;

  /// The activity description (e.g. "Golf - Kingston Heath").
  final String activity;

  /// The scheduled time, as sourced (e.g. "8:10 AM").
  final String time;
}
