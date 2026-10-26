/// The canonical Trip model — see `docs/architecture/trip-data-model.md`'s
/// "Trip Model" and "Trip Status" sections.
library;

import 'package:qaddy/core/utils/date_extensions.dart';

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

/// Who can discover a trip. Release 1 stores the choice only; there is no
/// public trip directory yet.
enum TripVisibility { private, public }

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
    this.visibility = TripVisibility.private,
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

  /// The key of the chosen cover preset (see `trip_covers.dart`). `null`
  /// renders the default cover.
  final String? coverImage;

  /// Optional trip description.
  final String? description;

  /// Who can discover the trip.
  final TripVisibility visibility;

  /// The trip's duration in days, inclusive of both the start and end date.
  int get durationInDays => startDate.calendarDaysUntil(endDate) + 1;

  /// Days remaining until [startDate], for a countdown display. Negative
  /// once the trip has started.
  int get daysUntilStart => DateTime.now().calendarDaysUntil(startDate);

  /// Whether the trip is still to be played (not finished, cancelled or
  /// archived).
  bool get isUpcoming =>
      status == TripStatus.planning ||
      status == TripStatus.inviting ||
      status == TripStatus.confirmed ||
      status == TripStatus.inProgress;

  /// A copy with the given fields replaced. Pass `clearDescription: true` to
  /// remove the description.
  Trip copyWith({
    String? name,
    String? destination,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    String? organiserId,
    int? playerCount,
    String? coverImage,
    String? description,
    bool clearDescription = false,
    TripVisibility? visibility,
    String? id,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      organiserId: organiserId ?? this.organiserId,
      playerCount: playerCount ?? this.playerCount,
      coverImage: coverImage ?? this.coverImage,
      description: clearDescription ? null : (description ?? this.description),
      visibility: visibility ?? this.visibility,
    );
  }
}
