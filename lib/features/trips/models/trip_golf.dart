/// A Trip's golf schedule — see placeholder-trip-data.md's "Golf Courses,"
/// "Playing Groups" and "Side Games" sections, and
/// `docs/architecture/trip-data-model.md`'s "Golf Courses" section.
library;

/// One golf course played on the trip.
class TripCourse {
  const TripCourse({required this.name, required this.teeTime});

  /// The course name.
  final String name;

  /// The scheduled tee time, as sourced (e.g. "8:10 AM").
  final String teeTime;
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
