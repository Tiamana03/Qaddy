/// A Trip's local transport — see `docs/architecture/trip-data-model.md`'s
/// "Transport" section and placeholder-trip-data.md's "Transport" section.
library;

/// One scheduled transport leg.
class TripTransportLeg {
  const TripTransportLeg({
    required this.date,
    required this.type,
    required this.details,
    required this.time,
  });

  /// The date, as sourced (e.g. "28 Nov").
  final String date;

  /// The transport type (e.g. "Airport Transfer", "Rental Car").
  final String type;

  /// A description of the leg (e.g. "Melbourne Airport → RACV Healesville").
  final String details;

  /// The scheduled time, as sourced (e.g. "12:15 PM").
  final String time;
}
