/// Simple, display-only types for Group Details' Season Summary,
/// Leaderboard and Upcoming Group Round sections — see
/// `docs/architecture/group-details.md`'s "Screen Contents".
///
/// These are deliberately not the full `Season` model documented in
/// `docs/architecture/group-season-model.md` — per
/// `docs/architecture/friends-engineering-decisions.md`'s "Two New Models
/// Only", Group Details displays "a simple derived value," not a new
/// formal Season/Leaderboard architecture. That full model remains
/// reserved for a future Seasons feature.
library;

/// One named member of a Group, with their handicap — see
/// `docs/standards/placeholder-group-data.md`'s "Members" table.
class GroupMember {
  const GroupMember({required this.name, required this.handicap});

  /// The member's display name.
  final String name;

  /// The member's golf handicap.
  final double handicap;
}

/// A Group's current season summary.
class GroupSeasonSummary {
  const GroupSeasonSummary({
    required this.season,
    required this.roundsCompleted,
    required this.roundsRemaining,
    required this.leader,
    required this.averageAttendance,
  });

  /// The season's name, e.g. "2026 Season".
  final String season;

  /// Rounds completed so far this season.
  final int roundsCompleted;

  /// Rounds remaining this season.
  final int roundsRemaining;

  /// The current standings leader's name.
  final String leader;

  /// Average attendance per round.
  final double averageAttendance;
}

/// One row of a Group's season leaderboard.
class GroupLeaderboardEntry {
  const GroupLeaderboardEntry({
    required this.rank,
    required this.player,
    required this.points,
  });

  /// The player's rank (1 is first place).
  final int rank;

  /// The player's name.
  final String player;

  /// The player's season points.
  final int points;
}

/// A Group's next scheduled round.
class GroupUpcomingRound {
  const GroupUpcomingRound({
    required this.course,
    required this.date,
    required this.teeTime,
    required this.competition,
    required this.players,
    required this.sideGames,
  });

  /// The course being played.
  final String course;

  /// The round's date, as display text (e.g. "Saturday").
  final String date;

  /// The tee time, as display text (e.g. "8:20 AM").
  final String teeTime;

  /// The competition format, e.g. "Stableford".
  final String competition;

  /// How many players are confirmed.
  final int players;

  /// The configured side games, as display text.
  final String sideGames;
}
