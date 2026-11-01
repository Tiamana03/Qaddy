import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

const RoundPlayer _alex = RoundPlayer(name: 'Alex', handicap: 0);
const RoundPlayer _tom = RoundPlayer(name: 'Tom', handicap: 0);
const RoundPlayer _ben = RoundPlayer(name: 'Ben', handicap: 0);

/// Richmond's holes 1–6 are par 4, 5, 3, 4, 4, 5.
/// A finished round with the given strokes (name → strokes from hole 1).
Round _finished(
  Map<String, List<int>> grosses, {
  required DateTime day,
  List<RoundPlayer> players = const <RoundPlayer>[_alex, _tom],
}) {
  final start = Round.start(
    id: day.toIso8601String(),
    course: 'Richmond Golf Club',
    format: 'Stableford',
    holes: richmondHoles,
    players: players,
    now: day,
  );
  final scores = <String, List<int?>>{
    for (final p in players)
      p.name: <int?>[
        ...?grosses[p.name],
        ...List<int?>.filled(
          richmondHoles.length - (grosses[p.name]?.length ?? 0),
          null,
        ),
      ],
  };
  return start.copyWith(
    scores: scores,
    status: RoundStatus.completed,
    completedAt: day.add(const Duration(hours: 4)),
  );
}

DateTime _day(int n) => DateTime(2026, 10, n, 8);

void main() {
  group('with nothing to go on', () {
    test('no rounds gives no stats', () {
      expect(CareerStats.of(<Round>[], you: 'Alex'), isNull);
    });

    test('a round without the golfer in it is ignored', () {
      final round = _finished(
        <String, List<int>>{
          'Tom': <int>[4, 5, 3],
          'Ben': <int>[4, 5, 3],
        },
        day: _day(1),
        players: const <RoundPlayer>[_tom, _ben],
      );

      expect(CareerStats.of(<Round>[round], you: 'Alex'), isNull);
    });

    test('a round with no hole played is ignored', () {
      final round = _finished(<String, List<int>>{}, day: _day(1));

      expect(CareerStats.of(<Round>[round], you: 'Alex'), isNull);
    });
  });

  group('the headline numbers', () {
    final win = _finished(<String, List<int>>{
      'Alex': <int>[3, 5, 3], // birdie, par, par = 3 + 2 + 2
      'Tom': <int>[5, 6, 4], // bogey ×3 = 3
    }, day: _day(1));
    final loss = _finished(<String, List<int>>{
      'Alex': <int>[5, 6, 4], // 3 points
      'Tom': <int>[4, 5, 3], // 6 points
    }, day: _day(2));

    test('counts rounds, wins and the win rate', () {
      final stats = CareerStats.of(<Round>[loss, win], you: 'Alex')!;

      expect(stats.rounds, 2);
      expect(stats.wins, 1);
      expect(stats.winRate, 0.5);
    });

    test(
      'scales the average to eighteen holes, whatever the history order',
      () {
        final stats = CareerStats.of(<Round>[loss, win], you: 'Alex')!;

        // 7 points over 3 holes and 3 over 3: 42 and 18 per eighteen.
        expect(stats.averagePoints, closeTo(30, 0.0001));
        expect(stats.chronological.first.round, same(win));
        expect(stats.chronological.last.round, same(loss));
      },
    );

    test('the best round is the one with the most points per eighteen', () {
      final stats = CareerStats.of(<Round>[loss, win], you: 'Alex')!;

      expect(stats.bestRound.round, same(win));
      expect(stats.bestRound.points, 7);
      expect(stats.bestRound.pointsPer18, closeTo(42, 0.0001));
    });

    test('a round on your own is never a win', () {
      final solo = _finished(
        <String, List<int>>{
          'Alex': <int>[4, 5, 3],
        },
        day: _day(1),
        players: const <RoundPlayer>[_alex],
      );

      expect(CareerStats.of(<Round>[solo], you: 'Alex')!.wins, 0);
    });

    test('the form guide is the last few rounds, oldest first', () {
      final rounds = <Round>[
        for (var i = 1; i <= 10; i++)
          _finished(<String, List<int>>{
            'Alex': <int>[4, 5, 3],
            'Tom': <int>[4, 5, 3],
          }, day: _day(i)),
      ];
      final stats = CareerStats.of(rounds, you: 'Alex')!;

      expect(stats.form(), hasLength(8));
      expect(stats.form(3).first.date, _day(8).add(const Duration(hours: 4)));
      expect(stats.form(3).last.date, _day(10).add(const Duration(hours: 4)));
    });
  });

  group('how the holes broke down', () {
    test('sorts every hole into eagle, birdie, par, bogey and worse', () {
      final round = _finished(<String, List<int>>{
        'Alex': <int>[
          2,
          4,
          3,
          5,
          6,
          0,
        ], // eagle, birdie, par, bogey, dbl, pick up
        'Tom': <int>[4, 5, 3, 4, 4, 5],
      }, day: _day(1));
      final mix = CareerStats.of(<Round>[round], you: 'Alex')!.mix;

      expect(mix.eagleOrBetter, 1);
      expect(mix.birdies, 1);
      expect(mix.pars, 1);
      expect(mix.bogeys, 1);
      expect(mix.doubleOrWorse, 1);
      expect(mix.pickedUp, 1);
      expect(mix.total, 6);
      expect(mix.parOrBetter, 3);
      expect(mix.parOrBetterRate, 0.5);
    });

    test('finds the favourite and the toughest hole', () {
      final round = _finished(<String, List<int>>{
        'Alex': <int>[
          3,
          7,
          3,
          4,
        ], // birdie (3 pts), 7 on a par 5 (0), par 3 (2), par (2)
        'Tom': <int>[4, 5, 3, 4],
      }, day: _day(1));
      final stats = CareerStats.of(<Round>[round], you: 'Alex')!;

      expect(stats.favouriteHole!.number, 1);
      expect(stats.favouriteHole!.averagePoints, 3);
      expect(stats.toughestHole!.number, 2);
      expect(stats.toughestHole!.averagePoints, 0);
    });

    test('needs a handful of holes before naming favourites', () {
      final round = _finished(<String, List<int>>{
        'Alex': <int>[3, 5],
        'Tom': <int>[4, 5],
      }, day: _day(1));
      final stats = CareerStats.of(<Round>[round], you: 'Alex')!;

      expect(stats.favouriteHole, isNull);
      expect(stats.toughestHole, isNull);
    });

    test('averages by par type and by nine', () {
      final round = _finished(<String, List<int>>{
        'Alex': <int>[4, 5, 3, 4], // pars on 4, 5, 3, 4
        'Tom': <int>[4, 5, 3, 4],
      }, day: _day(1));
      final stats = CareerStats.of(<Round>[round], you: 'Alex')!;

      expect(stats.parThreeAverage, 2);
      expect(stats.parFourAverage, 2);
      expect(stats.parFiveAverage, 2);
      expect(stats.frontNineAverage, 2);
      expect(stats.backNineAverage, isNull);
    });
  });

  group('form and records', () {
    List<Round> series(List<int> birdiesPerRound) => <Round>[
      for (final (i, birdies) in birdiesPerRound.indexed)
        _finished(<String, List<int>>{
          'Alex': <int>[
            for (var h = 0; h < 6; h++)
              h < birdies ? richmondHoles[h].par - 1 : richmondHoles[h].par,
          ],
          'Tom': <int>[for (var h = 0; h < 6; h++) richmondHoles[h].par],
        }, day: _day(i + 1)),
    ];

    test('no trend until there are four rounds to compare', () {
      expect(
        CareerStats.of(series(<int>[0, 1, 2]), you: 'Alex')!.formTrend,
        isNull,
      );
    });

    test('the trend compares the last three with the three before', () {
      // Points per six holes: 12, +1 per birdie. Before: 0,0,0 → 12 each.
      // Recent: 3,3,3 → 15 each. Difference is 3 points per six holes, which
      // is 9 per eighteen.
      final stats = CareerStats.of(
        series(<int>[0, 0, 0, 3, 3, 3]),
        you: 'Alex',
      )!;

      expect(stats.formTrend, closeTo(9, 0.0001));
    });

    test('a slump shows as a negative trend', () {
      final stats = CareerStats.of(
        series(<int>[3, 3, 3, 0, 0, 0]),
        you: 'Alex',
      )!;

      expect(stats.formTrend, lessThan(0));
    });

    test('remembers the most birdies in a round', () {
      final stats = CareerStats.of(series(<int>[1, 4, 2]), you: 'Alex')!;

      expect(stats.mostBirdiesInARound, 4);
    });

    test('a shared win keeps a streak going', () {
      // Round 3 is level on points, which shares the win.
      final stats = CareerStats.of(series(<int>[1, 1, 0, 1]), you: 'Alex')!;

      expect(stats.longestWinStreak, 4);
    });

    test('a loss ends it', () {
      Round round(int day, List<int> alex) => _finished(<String, List<int>>{
        'Alex': alex,
        'Tom': <int>[4, 5, 3],
      }, day: _day(day));

      final stats = CareerStats.of(<Round>[
        round(1, <int>[3, 5, 3]),
        round(2, <int>[3, 5, 3]),
        round(3, <int>[6, 8, 6]),
        round(4, <int>[3, 5, 3]),
      ], you: 'Alex')!;

      expect(stats.longestWinStreak, 2);
    });
  });

  group('rivals', () {
    test('keeps a head-to-head record against each playing partner', () {
      final rounds = <Round>[
        _finished(
          <String, List<int>>{
            'Alex': <int>[3, 5, 3],
            'Tom': <int>[4, 5, 3],
            'Ben': <int>[5, 6, 4],
          },
          day: _day(1),
          players: const <RoundPlayer>[_alex, _tom, _ben],
        ),
        _finished(
          <String, List<int>>{
            'Alex': <int>[4, 5, 3],
            'Tom': <int>[3, 5, 3],
            'Ben': <int>[4, 5, 3],
          },
          day: _day(2),
          players: const <RoundPlayer>[_alex, _tom, _ben],
        ),
        _finished(<String, List<int>>{
          'Alex': <int>[4, 5, 3],
          'Tom': <int>[4, 5, 3],
        }, day: _day(3)),
      ];

      final rivals = CareerStats.of(rounds, you: 'Alex')!.rivals;
      final tom = rivals.firstWhere((r) => r.name == 'Tom');
      final ben = rivals.firstWhere((r) => r.name == 'Ben');

      expect(tom.together, 3);
      expect((tom.youWon, tom.theyWon, tom.halved), (1, 1, 1));
      expect(ben.together, 2);
      expect((ben.youWon, ben.theyWon, ben.halved), (1, 0, 1));
      // Most rounds together first.
      expect(rivals.first.name, 'Tom');
    });
  });
}
