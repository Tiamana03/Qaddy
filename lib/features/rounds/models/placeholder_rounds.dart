/// The Rounds feature's shared placeholder data.
///
/// See `docs/standards/placeholder-data.md`'s "Upcoming Round" section.
/// Extracted from `rounds_screen.dart`'s own private literals — previously
/// duplicated across its Upcoming Round Card and Round Information Card —
/// so Search (`docs/architecture/search-data-model.md`) can read the same
/// round without duplicating it. See
/// `docs/architecture/search-engineering-decisions.md`.
library;

/// The single Release 1 upcoming round — see placeholder-data.md's
/// "Upcoming Round".
class UpcomingRound {
  const UpcomingRound({
    required this.course,
    required this.date,
    required this.teeTime,
    required this.players,
    required this.weather,
    required this.format,
    required this.holes,
  });

  /// The course being played.
  final String course;

  /// The round's date, as sourced (e.g. "Saturday").
  final String date;

  /// The scheduled tee time, as sourced (e.g. "8:20 AM").
  final String teeTime;

  /// How many players are confirmed/pending.
  final int players;

  /// The forecast conditions, as sourced (e.g. "21°C Sunny").
  final String weather;

  /// The scoring format.
  final String format;

  /// Number of holes.
  final int holes;
}

/// Richmond Golf Club, Saturday 8:20 AM — the shared placeholder round.
const upcomingRound = UpcomingRound(
  course: 'Richmond Golf Club',
  date: 'Saturday',
  teeTime: '8:20 AM',
  players: 8,
  weather: '21°C Sunny',
  format: 'Stableford',
  holes: 18,
);
