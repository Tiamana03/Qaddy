/// A Trip's final results — see placeholder-trip-data.md's "Trip Results"
/// section.
library;

/// One award and its winner.
class TripAward {
  const TripAward({required this.award, required this.winner});

  /// The award's name (e.g. "Trip Champion").
  final String award;

  /// The winner's name.
  final String winner;
}
