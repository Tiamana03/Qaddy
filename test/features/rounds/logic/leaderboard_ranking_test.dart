import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/logic/leaderboard_ranking.dart';
import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';

void main() {
  test('sorts by relative to par, ascending', () {
    const entries = <LeaderboardEntry>[
      LeaderboardEntry(
        name: 'Sam',
        grossScore: 84,
        relativeToPar: 12,
        throughHole: 18,
      ),
      LeaderboardEntry(
        name: 'Tom',
        grossScore: 70,
        relativeToPar: -2,
        throughHole: 18,
      ),
    ];

    final ranked = rankLeaderboard(entries);

    expect(ranked[0].entry.name, 'Tom');
    expect(ranked[0].position, '1');
    expect(ranked[1].entry.name, 'Sam');
    expect(ranked[1].position, '2');
  });

  test('players tied on relative to par and gross score share a T-prefixed '
      'position, skipping the next plain rank', () {
    const entries = <LeaderboardEntry>[
      LeaderboardEntry(
        name: 'Tom',
        grossScore: 70,
        relativeToPar: -2,
        throughHole: 18,
      ),
      LeaderboardEntry(
        name: 'Tiamana',
        grossScore: 70,
        relativeToPar: -2,
        throughHole: 18,
      ),
      LeaderboardEntry(
        name: 'Josh',
        grossScore: 75,
        relativeToPar: 3,
        throughHole: 18,
      ),
    ];

    final ranked = rankLeaderboard(entries);

    expect(ranked.map((r) => r.position).toList(), <String>['T1', 'T1', '3']);
    expect(ranked[0].isLeader, isTrue);
    expect(ranked[1].isLeader, isTrue);
    expect(ranked[2].isLeader, isFalse);
  });

  test('ties on relative to par break by lowest gross score', () {
    const entries = <LeaderboardEntry>[
      LeaderboardEntry(
        name: 'HigherGross',
        grossScore: 80,
        relativeToPar: 0,
        throughHole: 18,
      ),
      LeaderboardEntry(
        name: 'LowerGross',
        grossScore: 78,
        relativeToPar: 0,
        throughHole: 18,
      ),
    ];

    final ranked = rankLeaderboard(entries);

    expect(ranked[0].entry.name, 'LowerGross');
    expect(ranked[1].entry.name, 'HigherGross');
  });

  test('remaining ties break by furthest hole completed, then original '
      'order', () {
    const entries = <LeaderboardEntry>[
      LeaderboardEntry(
        name: 'First',
        grossScore: 40,
        relativeToPar: 0,
        throughHole: 9,
      ),
      LeaderboardEntry(
        name: 'Furthest',
        grossScore: 40,
        relativeToPar: 0,
        throughHole: 12,
      ),
    ];

    final ranked = rankLeaderboard(entries);

    expect(ranked[0].entry.name, 'Furthest');
    expect(ranked[1].entry.name, 'First');
  });
}
