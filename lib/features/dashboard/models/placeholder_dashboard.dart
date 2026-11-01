/// The Dashboard feature's shared placeholder data.
///
/// See `docs/standards/placeholder-data.md`'s "Statistics" section.
/// Previously these three values existed only as private literals inside
/// `dashboard_screen.dart`'s `_StatisticsPreview`, with Profile forced to
/// redeclare matching literals of its own because nothing public existed to
/// import (see `docs/reviews/technical-debt.md`'s TD-005 and
/// `profile-engineering-decisions.md`'s "Friends, Groups and Rounds-Played
/// Counts Are Computed, Not Duplicated"). Exposing them here lets Profile
/// read them directly instead.
library;

/// Rounds played — see placeholder-data.md's "Statistics".
const int dashboardRoundsPlayed = 68;

/// Average score — see placeholder-data.md's "Statistics".
const int dashboardAverageScore = 83;

/// Best round score — see placeholder-data.md's "Statistics".
const int dashboardBestRound = 74;

/// The most recent completed round — see placeholder-data.md's "Recent
/// Round".
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

  /// When it was played, as sourced (e.g. "Last Saturday").
  final String when;

  /// Gross score.
  final int score;

  /// Stableford points.
  final int stableford;

  /// Finishing position, as sourced (e.g. "1st").
  final String position;
}

/// The Dunes Golf Links, last Saturday — see placeholder-data.md's "Recent
/// Round".
const DashboardLastRound dashboardLastRound = DashboardLastRound(
  course: 'The Dunes Golf Links',
  when: 'Last Saturday',
  score: 78,
  stableford: 37,
  position: '1st',
);
