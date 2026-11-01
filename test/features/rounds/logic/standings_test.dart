import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';

const RoundPlayer _alex = RoundPlayer(name: 'Alex', handicap: 0);
const RoundPlayer _tom = RoundPlayer(name: 'Tom', handicap: 18);
const RoundPlayer _ben = RoundPlayer(name: 'Ben', handicap: 0);

/// A round with [grosses] (name → strokes per hole, from hole 1) recorded.
Round _round(
  Map<String, List<int?>> grosses, {
  List<RoundPlayer> players = const <RoundPlayer>[_alex, _tom, _ben],
}) {
  final start = Round.start(
    id: 'r',
    course: 'Richmond Golf Club',
    format: 'Stableford',
    holes: richmondHoles,
    players: players,
    now: DateTime(2026, 11, 7, 8, 20),
  );
  final scores = <String, List<int?>>{
    for (final entry in start.scores.entries)
      entry.key: <int?>[
        ...?grosses[entry.key],
        ...List<int?>.filled(
          richmondHoles.length - (grosses[entry.key]?.length ?? 0),
          null,
        ),
      ],
  };
  return start.copyWith(scores: scores);
}

void main() {
  // Richmond's first three holes are par 4, 5, 3.
  group('standingsOf', () {
    test('ranks by Stableford points', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4, 5, 3], // 2 + 2 + 2 = 6
        'Tom': <int?>[3, 5, 3], // 18 handicap: a shot a hole → 4 + 3 + 3 = 10
        'Ben': <int?>[5, 6, 4], // 1 + 1 + 1 = 3
      });

      final table = standingsOf(round);

      expect(table.map((s) => s.player.name), <String>['Tom', 'Alex', 'Ben']);
      expect(table.map((s) => s.points), <int>[10, 6, 3]);
      expect(table.map((s) => s.position), <String>['1', '2', '3']);
      expect(table.first.isLeader, isTrue);
      expect(table.last.isLeader, isFalse);
    });

    test('counts only holes everyone has played', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4, 5, 3],
        'Tom': <int?>[4, 5],
        'Ben': <int?>[4, 5],
      });

      final table = standingsOf(round);

      // Hole 3 has only one score, so it does not count yet.
      expect(round.holesPlayed, 2);
      expect(table.every((s) => s.gross > 0 && s.gross <= 9 + 9), isTrue);
      expect(table.firstWhere((s) => s.player.name == 'Alex').gross, 9);
    });

    test('breaks a points tie on the lower score against par', () {
      // Both players get 6 points; Ben (0 handicap) needs par to do it,
      // Tom (18 handicap) needs bogey on every hole.
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4, 5, 3],
        'Tom': <int?>[5, 6, 4],
        'Ben': <int?>[4, 5, 3],
      });

      final table = standingsOf(round);

      expect(table.first.points, table[1].points);
      expect(table.first.toPar, lessThanOrEqualTo(table[1].toPar));
    });

    test('players who are level share a T position', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4, 5, 3],
        'Tom': <int?>[5, 6, 4], // net par each hole → 6 points, +3
        'Ben': <int?>[4, 5, 3], // 6 points, level par
      });

      final table = standingsOf(round);
      final alex = table.firstWhere((s) => s.player.name == 'Alex');
      final ben = table.firstWhere((s) => s.player.name == 'Ben');

      expect(alex.position, 'T1');
      expect(ben.position, 'T1');
      expect(table.last.position, '3');
      expect(leadersOf(table), hasLength(2));
    });

    test('before any hole is played everyone is level', () {
      final table = standingsOf(_round(<String, List<int?>>{}));

      expect(table.every((s) => s.points == 0), isTrue);
      expect(table.every((s) => s.position == 'T1'), isTrue);
    });

    test('a hole picked up scores nothing and adds no strokes', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[0],
        'Tom': <int?>[4],
        'Ben': <int?>[4],
      });

      final you = standingsOf(round).firstWhere((s) => s.player.name == 'Alex');

      expect(you.points, 0);
      expect(you.gross, 0);
      expect(you.toPar, 0);
    });

    test('counts birdies', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[3, 4, 2], // birdie, birdie, birdie
        'Tom': <int?>[4, 5, 3],
        'Ben': <int?>[4, 5, 3],
      });

      expect(
        standingsOf(round).firstWhere((s) => s.player.name == 'Alex').birdies,
        3,
      );
    });
  });

  group('winnersHeadline', () {
    test('names a single winner, or says "You"', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[3, 4, 2],
        'Tom': <int?>[4, 5, 3],
        'Ben': <int?>[4, 5, 3],
      });
      final table = standingsOf(round);

      expect(winnersHeadline(table, you: 'Alex'), 'You win!');
      expect(winnersHeadline(table, you: 'Ben'), 'Alex wins');
    });

    test('shares the win when level', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4, 5, 3],
        'Tom': <int?>[5, 6, 4],
        'Ben': <int?>[4, 5, 3],
      });

      expect(winnersHeadline(standingsOf(round)), 'Alex and Ben share the win');
    });
  });

  group('winnersHeadline while the round is on', () {
    test('says who leads, not who wins', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[3, 4, 2],
        'Tom': <int?>[4, 5, 3],
        'Ben': <int?>[4, 5, 3],
      });
      final table = standingsOf(round);

      expect(winnersHeadline(table, you: 'Alex', finished: false), 'You lead');
      expect(winnersHeadline(table, you: 'Ben', finished: false), 'Alex leads');
    });

    test('says who is level at the top', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4, 5, 3],
        'Tom': <int?>[5, 6, 4],
        'Ben': <int?>[4, 5, 3],
      });

      expect(
        winnersHeadline(standingsOf(round), finished: false),
        'Alex and Ben lead',
      );
    });
  });

  group('holeResultLine', () {
    test('names who took the hole and with what', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[2],
        'Tom': <int?>[4],
        'Ben': <int?>[4],
      });

      expect(
        holeResultLine(round, 0, you: 'Alex'),
        'You win the hole with an eagle',
      );
      expect(
        holeResultLine(round, 0, you: 'Ben'),
        'Alex wins the hole with an eagle',
      );
    });

    test('says when the hole is shared', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[3],
        'Tom': <int?>[5],
        'Ben': <int?>[3],
      });

      expect(
        holeResultLine(round, 0, you: 'Alex'),
        'You and Ben share the hole',
      );
    });

    test('counts handicap shots, so a net score can win the hole', () {
      // Tom plays off 18, so his par is worth a point more than a gross par.
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4],
        'Tom': <int?>[4],
        'Ben': <int?>[5],
      });

      expect(
        holeResultLine(round, 0, you: 'Alex'),
        'Tom wins the hole with a net birdie',
      );
    });

    test('has nothing to say when everyone ties', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[4],
        'Tom': <int?>[5],
        'Ben': <int?>[4],
      });

      expect(holeResultLine(round, 0, you: 'Alex'), isNull);
      final pair = _round(
        <String, List<int?>>{
          'Alex': <int?>[4],
          'Tom': <int?>[5],
        },
        players: const <RoundPlayer>[_alex, _tom],
      );
      expect(holeResultLine(pair, 0, you: 'Alex'), isNull);
    });

    test('waits until everyone has a score', () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[3],
      });

      expect(holeResultLine(round, 0, you: 'Alex'), isNull);
    });
  });

  group('recapOf', () {
    test("summarises one golfer's round", () {
      final round = _round(<String, List<int?>>{
        'Alex': <int?>[3, 5, 4, 4, 6, 5, 4, 3, 4, 3], // 10 holes
        'Tom': List<int?>.filled(10, 4),
        'Ben': List<int?>.filled(10, 4),
      });

      final recap = recapOf(round, 'Alex')!;

      expect(recap.pars, greaterThan(0));
      expect(recap.frontNine + recap.backNine, recap.standing.points);
      expect(recap.bestHole, isNotNull);
      expect(recap.bestHoleLabel, isNotEmpty);
    });

    test('is null for someone who did not play', () {
      expect(recapOf(_round(<String, List<int?>>{}), 'Nobody'), isNull);
    });
  });

  test('the result message names the winner, the course and the top three', () {
    final round = _round(<String, List<int?>>{
      'Alex': <int?>[3, 4, 2],
      'Tom': <int?>[4, 5, 3],
      'Ben': <int?>[4, 5, 3],
    });

    final message = roundResultMessage(round, you: 'Alex');

    expect(message, startsWith('You win! at Richmond Golf Club!'));
    expect(message, contains('1. Alex'));
    expect(message, endsWith('Played with Qaddy.'));
  });
}
