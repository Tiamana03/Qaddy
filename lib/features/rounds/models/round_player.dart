/// A golfer playing a round, with the handicap they play off.
library;

/// A player in a round.
class RoundPlayer {
  const RoundPlayer({required this.name, required this.handicap});

  /// The player's name (unique within a round).
  final String name;

  /// The handicap index, e.g. 8.4.
  final double handicap;

  /// The whole number of shots the player is given over eighteen holes: the
  /// handicap, rounded.
  int get playingHandicap => handicap.round();
}
