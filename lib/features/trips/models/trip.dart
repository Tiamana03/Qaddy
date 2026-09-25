/// The canonical Trip model — see `docs/architecture/trip-data-model.md`'s
/// "Trip Model" and "Trip Status" sections.
library;

/// A Trip's lifecycle status.
enum TripStatus {
  planning,
  inviting,
  confirmed,
  inProgress,
  completed,
  cancelled,
  archived,
}

/// A golf trip.
class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.organiserId,
    required this.playerCount,
    this.coverImage,
    this.description,
  });

  /// Unique trip identifier.
  final String id;

  /// The trip's name.
  final String name;

  /// The trip's destination.
  final String destination;

  /// The country the destination is in.
  final String country;

  /// The trip's start date.
  final DateTime startDate;

  /// The trip's end date.
  final DateTime endDate;

  /// The trip's current lifecycle status.
  final TripStatus status;

  /// The organiser's display name (Release 1 has no user-id lookup, so this
  /// stores the name directly rather than a real userId).
  final String organiserId;

  /// How many players are participating.
  final int playerCount;

  /// Optional cover image reference. `null` renders a placeholder.
  final String? coverImage;

  /// Optional trip description.
  final String? description;

  /// The trip's duration in days, inclusive of both the start and end date.
  int get durationInDays => endDate.difference(startDate).inDays + 1;

  /// Days remaining until [startDate], for a countdown display. Negative
  /// once the trip has started.
  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;
}
