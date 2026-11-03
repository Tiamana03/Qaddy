/// The Dashboard's "Your game" last-round model.
///
/// Despite the file's name there is no placeholder data left: the last round
/// comes from the golfer's own finished rounds (see `lastRoundFrom` in
/// `logic/dashboard_insights.dart`). Only the shape is kept here.
library;

/// The most recent finished round, as the "Your game" card shows it.
class DashboardLastRound {
  const DashboardLastRound({
    required this.course,
    required this.when,
    required this.score,
    required this.stableford,
    required this.position,
  });

  /// The course played.
  final String course;

  /// When it was played ("Today", "Yesterday", "3 days ago").
  final String when;

  /// Gross score.
  final int score;

  /// Stableford points.
  final int stableford;

  /// Finishing position ("1st", "2nd").
  final String position;
}
