/// A single player's raw standing on the live leaderboard.
///
/// See `docs/standards/placeholder-data.md`'s "Leaderboard" section and
/// `docs/sprints/sprint-02-04-leaderboard.md`'s "Leaderboard Layout".
library;

/// One player's gross score, relative-to-par and hole progress, before
/// ranking is computed.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.grossScore,
    required this.relativeToPar,
    required this.throughHole,
  });

  /// The player's name.
  final String name;

  /// The player's total gross score.
  final int grossScore;

  /// The player's score relative to par (negative = under par).
  final int relativeToPar;

  /// How many holes the player has completed.
  final int throughHole;
}

/// A [LeaderboardEntry] with its computed leaderboard position.
class RankedLeaderboardEntry {
  const RankedLeaderboardEntry({
    required this.position,
    required this.entry,
    required this.isLeader,
  });

  /// The player's position (e.g. "1", "T1", "3") — see
  /// `docs/sprints/sprint-02-04-leaderboard.md`'s "Tie Handling" section.
  final String position;

  /// The underlying player standing.
  final LeaderboardEntry entry;

  /// Whether this player holds (or shares) first place.
  final bool isLeader;
}
