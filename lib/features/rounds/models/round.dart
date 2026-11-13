/// A round of golf: who is playing, how every hole went and where the group
/// has got to.
///
/// A round is immutable; the store replaces it with a changed copy. Scores are
/// kept per player per hole as gross strokes. `null` means "not scored yet",
/// and `0` means the player picked up (no score, no points).
library;

import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

/// Where a round is in its life.
enum RoundStatus {
  /// Being played.
  inProgress,

  /// Finished; the results are final.
  completed,
}

/// A round being played, or one that has been finished.
class Round {
  const Round({
    required this.id,
    required this.course,
    required this.format,
    required this.holes,
    required this.players,
    required this.scores,
    required this.currentHole,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.courseId,
  });

  /// Starts a round on [holes] for [players] at [now], on the first tee.
  factory Round.start({
    required String id,
    required String course,
    required String format,
    required List<CourseHole> holes,
    required List<RoundPlayer> players,
    required DateTime now,
    String? courseId,
  }) => Round(
    id: id,
    course: course,
    format: format,
    holes: holes,
    players: players,
    scores: <String, List<int?>>{
      for (final player in players)
        player.name: List<int?>.filled(holes.length, null),
    },
    currentHole: 0,
    status: RoundStatus.inProgress,
    startedAt: now,
    courseId: courseId,
  );

  /// A unique id.
  final String id;

  /// The course's name.
  final String course;

  /// The course catalogue's id for the course, or `null` when the round was
  /// played on the standard layout with no course chosen. It lets a played
  /// round find its course (and the forecast and pictures) again.
  final String? courseId;

  /// The scoring format, e.g. "Stableford".
  final String format;

  /// Every hole, in playing order.
  final List<CourseHole> holes;

  /// The golfers, the one keeping the score first.
  final List<RoundPlayer> players;

  /// Gross strokes by player name, one entry per hole.
  final Map<String, List<int?>> scores;

  /// The zero-based index of the hole being played.
  final int currentHole;

  /// Whether the round is being played or is over.
  final RoundStatus status;

  /// When the round started.
  final DateTime startedAt;

  /// When it finished, once it has.
  final DateTime? completedAt;

  /// Whether the round is over.
  bool get isCompleted => status == RoundStatus.completed;

  /// The hole being played.
  CourseHole get hole => holes[currentHole];

  /// Whether [player] has a score recorded on the hole at [index].
  bool hasScore(String player, int index) => scores[player]![index] != null;

  /// [player]'s recorded gross on the hole at [index], or `null`.
  int? grossAt(String player, int index) => scores[player]![index];

  /// Whether every player has a score on the hole at [index].
  bool isHolePlayed(int index) =>
      players.every((player) => hasScore(player.name, index));

  /// How many holes have been played by everyone.
  int get holesPlayed => <int>[
    for (var i = 0; i < holes.length; i++)
      if (isHolePlayed(i)) i,
  ].length;

  /// The player named [name], or `null`.
  RoundPlayer? playerNamed(String name) {
    for (final player in players) {
      if (player.name == name) {
        return player;
      }
    }
    return null;
  }

  /// Returns a changed copy.
  Round copyWith({
    Map<String, List<int?>>? scores,
    int? currentHole,
    RoundStatus? status,
    DateTime? completedAt,
  }) => Round(
    id: id,
    course: course,
    format: format,
    holes: holes,
    players: players,
    scores: scores ?? this.scores,
    currentHole: currentHole ?? this.currentHole,
    status: status ?? this.status,
    startedAt: startedAt,
    completedAt: completedAt ?? this.completedAt,
    courseId: courseId,
  );
}
