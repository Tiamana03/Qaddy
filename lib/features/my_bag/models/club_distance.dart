/// The Club Distance model — see `docs/architecture/golf-bag-data-model.md`'s
/// "Club Distance Model" section.
library;

/// A club's average carry distance.
class ClubDistance {
  const ClubDistance({
    required this.clubName,
    required this.averageDistanceMetres,
  });

  /// The club category, matching an existing Equipment entry (e.g. "Driver").
  final String clubName;

  /// Average carry distance for this club, in metres.
  final double averageDistanceMetres;
}
