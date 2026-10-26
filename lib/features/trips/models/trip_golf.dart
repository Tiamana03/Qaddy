/// A Trip's golf schedule — see `docs/architecture/trip-data-model.md`'s
/// "Golf Courses," "Playing Groups" and "Side Games" sections.
library;

/// One golf course booked on the trip, with everything a golfer needs to
/// turn up: where it is, how to contact it, what it plays like, when they
/// tee off and what it costs.
///
/// Release 1 has no course database or maps service, so every field is
/// entered (or seeded) placeholder data.
class TripCourse {
  const TripCourse({
    required this.id,
    required this.name,
    required this.teeTime,
    this.address = '',
    this.phone = '',
    this.website = '',
    this.courseRating,
    this.slope,
    this.players = const <String>[],
    this.greenFee,
    this.dressCode = '',
    this.notes = '',
  });

  /// Unique identifier within the trip.
  final String id;

  /// The course name.
  final String name;

  /// The booked tee time (local date and time).
  final DateTime teeTime;

  /// Street address.
  final String address;

  /// Contact phone number.
  final String phone;

  /// Website address.
  final String website;

  /// USGA/Golf Australia style course rating (e.g. 73.5), when known.
  final double? courseRating;

  /// Slope rating (e.g. 133), when known.
  final int? slope;

  /// Names of the players booked on this tee time.
  final List<String> players;

  /// Green fee per player, when known.
  final double? greenFee;

  /// The course's dress code, if any.
  final String dressCode;

  /// Free-form notes.
  final String notes;

  /// Total green fees for the booked players, when a fee is set.
  double? get totalGreenFees =>
      greenFee == null ? null : greenFee! * players.length;

  /// A copy with the given fields replaced.
  TripCourse copyWith({
    String? name,
    DateTime? teeTime,
    String? address,
    String? phone,
    String? website,
    double? courseRating,
    int? slope,
    List<String>? players,
    double? greenFee,
    String? dressCode,
    String? notes,
    bool clearRating = false,
    bool clearSlope = false,
    bool clearGreenFee = false,
  }) {
    return TripCourse(
      id: id,
      name: name ?? this.name,
      teeTime: teeTime ?? this.teeTime,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      courseRating: clearRating ? null : (courseRating ?? this.courseRating),
      slope: clearSlope ? null : (slope ?? this.slope),
      players: players ?? this.players,
      greenFee: clearGreenFee ? null : (greenFee ?? this.greenFee),
      dressCode: dressCode ?? this.dressCode,
      notes: notes ?? this.notes,
    );
  }
}

/// One playing group for a round.
class TripPlayingGroup {
  const TripPlayingGroup({required this.name, required this.players});

  /// The group's label (e.g. "Group 1").
  final String name;

  /// The players in this group.
  final List<String> players;
}

/// One side game configured for the trip.
class TripSideGame {
  const TripSideGame({required this.name, required this.hole});

  /// The side game's name (e.g. "Longest Drive").
  final String name;

  /// The hole it's configured on.
  final int hole;
}
