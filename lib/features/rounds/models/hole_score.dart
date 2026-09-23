/// A single hole's course data and in-progress score.
///
/// See `docs/architecture/round-data-model.md`'s "HoleScore" section. Only
/// the fields Sprint 2.3 ("Live Scoring") actually uses are implemented —
/// `netScore`, `stablefordPoints`, `putts`, `fairwayHit` and
/// `greenInRegulation` require handicap or Stableford calculations, both
/// explicitly out of scope for this sprint's "Do Not Build" list.
library;

/// One hole's static course data (par, stroke index, distance) plus the
/// player's current gross score for that hole.
class HoleScore {
  const HoleScore({
    required this.holeNumber,
    required this.par,
    required this.strokeIndex,
    required this.distance,
    required this.grossScore,
  });

  /// The hole number (1-18).
  final int holeNumber;

  /// The hole's par.
  final int par;

  /// The hole's stroke index (difficulty ranking, 1-18).
  final int strokeIndex;

  /// The hole's distance, in metres.
  final int distance;

  /// The player's current gross score for this hole.
  ///
  /// Defaults to [par] until the player records a score — see
  /// round-data-model.md's "Hole Score Initial State".
  final int grossScore;

  /// Returns a copy with [grossScore] replaced.
  HoleScore copyWithGrossScore(int grossScore) {
    return HoleScore(
      holeNumber: holeNumber,
      par: par,
      strokeIndex: strokeIndex,
      distance: distance,
      grossScore: grossScore,
    );
  }
}
