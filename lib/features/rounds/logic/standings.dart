/// The leaderboard of a round: Stableford points, gross strokes, score against
/// par — and who is winning.
///
/// Only holes that everyone has played count, so the table is always fair
/// mid-round. Players are ranked by Stableford points; ties on points are
/// broken by the lower score against par, and players still level share a
/// "T" position (1, T2, T2, 4).
library;

import 'package:qaddy/features/rounds/logic/stableford.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

/// One player's place in the table.
class PlayerStanding {
  const PlayerStanding({
    required this.player,
    required this.position,
    required this.isLeader,
    required this.points,
    required this.gross,
    required this.toPar,
    required this.birdies,
  });

  /// The golfer.
  final RoundPlayer player;

  /// "1", "T2", "4"…
  final String position;

  /// Whether the player holds (or shares) first place.
  final bool isLeader;

  /// Stableford points over the holes played.
  final int points;

  /// Gross strokes over the holes played (holes picked up excluded).
  final int gross;

  /// Gross against par over the holes played (holes picked up excluded).
  final int toPar;

  /// Birdies or better.
  final int birdies;
}

/// Stableford points for [player] on the hole at [index]; `0` when the hole
/// has not been scored.
int pointsAt(Round round, RoundPlayer player, int index) {
  final gross = round.grossAt(player.name, index);
  if (gross == null) {
    return 0;
  }
  final hole = round.holes[index];
  return stablefordPoints(
    gross: gross,
    par: hole.par,
    shots: shotsReceived(
      playingHandicap: player.playingHandicap,
      strokeIndex: hole.strokeIndex,
    ),
  );
}

/// The standings of [round], best first.
List<PlayerStanding> standingsOf(Round round) {
  final played = <int>[
    for (var i = 0; i < round.holes.length; i++)
      if (round.isHolePlayed(i)) i,
  ];

  final rows =
      <({RoundPlayer player, int points, int gross, int toPar, int birdies})>[
        for (final player in round.players)
          (
            player: player,
            points: played.fold<int>(
              0,
              (sum, i) => sum + pointsAt(round, player, i),
            ),
            gross: played.fold<int>(0, (sum, i) {
              final gross = round.grossAt(player.name, i)!;
              return gross > 0 ? sum + gross : sum;
            }),
            toPar: played.fold<int>(0, (sum, i) {
              final gross = round.grossAt(player.name, i)!;
              return gross > 0 ? sum + gross - round.holes[i].par : sum;
            }),
            birdies: played.where((i) {
              final gross = round.grossAt(player.name, i)!;
              return gross > 0 && isCelebration(gross, round.holes[i].par);
            }).length,
          ),
      ];

  // `sort` is not stable, so the original order breaks any remaining tie.
  final indexed =
      <
          (
            int,
            ({
              RoundPlayer player,
              int points,
              int gross,
              int toPar,
              int birdies,
            }),
          )
        >[for (final (index, row) in rows.indexed) (index, row)]
        ..sort((a, b) {
          final byPoints = b.$2.points.compareTo(a.$2.points);
          if (byPoints != 0) {
            return byPoints;
          }
          final byToPar = a.$2.toPar.compareTo(b.$2.toPar);
          return byToPar != 0 ? byToPar : a.$1.compareTo(b.$1);
        });

  bool level(int a, int b) =>
      indexed[a].$2.points == indexed[b].$2.points &&
      indexed[a].$2.toPar == indexed[b].$2.toPar;

  final standings = <PlayerStanding>[];
  var rank = 0;
  for (var i = 0; i < indexed.length; i++) {
    final tiedWithPrevious = i > 0 && level(i, i - 1);
    final tiedWithNext = i < indexed.length - 1 && level(i, i + 1);
    if (!tiedWithPrevious) {
      rank = i + 1;
    }
    final row = indexed[i].$2;
    standings.add(
      PlayerStanding(
        player: row.player,
        position: tiedWithPrevious || tiedWithNext ? 'T$rank' : '$rank',
        isLeader: rank == 1,
        points: row.points,
        gross: row.gross,
        toPar: row.toPar,
        birdies: row.birdies,
      ),
    );
  }
  return standings;
}

/// Who is winning: the standings' leaders (more than one when level).
List<PlayerStanding> leadersOf(List<PlayerStanding> standings) =>
    <PlayerStanding>[
      for (final standing in standings)
        if (standing.isLeader) standing,
    ];
