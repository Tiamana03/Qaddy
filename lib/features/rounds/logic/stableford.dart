/// Stableford scoring and the words golfers use for a score.
///
/// Pure functions, so every rule is tested without a screen.
library;

/// The shots a player is given on a hole: their playing handicap spread over
/// the course, hardest holes first. A handicap of 20 gives one shot on every
/// hole and a second on the two hardest.
int shotsReceived({required int playingHandicap, required int strokeIndex}) {
  if (playingHandicap <= 0) {
    return 0;
  }
  final full = playingHandicap ~/ 18;
  final extra = strokeIndex <= playingHandicap % 18 ? 1 : 0;
  return full + extra;
}

/// Stableford points for [gross] strokes on a hole of [par] where the player
/// is given [shots]: 2 for a net par, one more for each shot better, and
/// nothing for a net double bogey or worse. Picking up ([gross] of 0) scores
/// nothing.
int stablefordPoints({
  required int gross,
  required int par,
  required int shots,
}) {
  if (gross <= 0) {
    return 0;
  }
  final points = 2 + par - (gross - shots);
  return points < 0 ? 0 : points;
}

/// How a score compares with par, in a golfer's words.
enum ScoreKind {
  pickedUp,
  ace,
  albatross,
  eagle,
  birdie,
  par,
  bogey,
  double,
  worse,
}

/// Classifies [gross] against [par].
ScoreKind scoreKind(int gross, int par) {
  if (gross <= 0) {
    return ScoreKind.pickedUp;
  }
  if (gross == 1) {
    return ScoreKind.ace;
  }
  return switch (gross - par) {
    <= -3 => ScoreKind.albatross,
    -2 => ScoreKind.eagle,
    -1 => ScoreKind.birdie,
    0 => ScoreKind.par,
    1 => ScoreKind.bogey,
    2 => ScoreKind.double,
    _ => ScoreKind.worse,
  };
}

/// The word for a score: "Birdie", "Par", "Double bogey", "+4".
String scoreLabel(int gross, int par) {
  return switch (scoreKind(gross, par)) {
    ScoreKind.pickedUp => 'Picked up',
    ScoreKind.ace => 'Hole in one!',
    ScoreKind.albatross => 'Albatross',
    ScoreKind.eagle => 'Eagle',
    ScoreKind.birdie => 'Birdie',
    ScoreKind.par => 'Par',
    ScoreKind.bogey => 'Bogey',
    ScoreKind.double => 'Double bogey',
    ScoreKind.worse => '+${gross - par}',
  };
}

/// Whether a score is worth celebrating: a birdie or better.
bool isCelebration(int gross, int par) => switch (scoreKind(gross, par)) {
  ScoreKind.ace ||
  ScoreKind.albatross ||
  ScoreKind.eagle ||
  ScoreKind.birdie => true,
  _ => false,
};
