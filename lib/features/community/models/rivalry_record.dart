/// The Rivalry Record model — see `docs/architecture/rivalries.md`'s
/// "Rivalry Record Model" section.
library;

/// A head-to-head record against a single friend.
class RivalryRecord {
  const RivalryRecord({
    required this.friendName,
    required this.roundsPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.lastResult,
  });

  /// The rival friend's name.
  final String friendName;

  /// Total rounds played together.
  final int roundsPlayed;

  /// Rounds the current user won.
  final int wins;

  /// Rounds the current user lost.
  final int losses;

  /// Rounds that ended level.
  final int draws;

  /// Description of the most recent result.
  final String lastResult;
}
