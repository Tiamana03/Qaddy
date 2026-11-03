/// An achievement the golfer can earn by playing, and how close they are.
library;

/// One achievement and the golfer's progress towards it.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.blurb,
    required this.progress,
    required this.target,
  });

  /// A stable id ("first-round").
  final String id;

  /// The name shown to the golfer ("Birdie Hunter").
  final String title;

  /// How to earn it, in a sentence ("Make 5 birdies or better").
  final String blurb;

  /// How far along they are, capped at [target].
  final int progress;

  /// What it takes.
  final int target;

  /// Whether it has been earned.
  bool get unlocked => progress >= target;

  /// Progress as a fraction (0–1).
  double get fraction => target == 0 ? 1 : progress / target;

  /// "7 of 10", or "Earned".
  String get progressLabel => unlocked ? 'Earned' : '$progress of $target';
}
