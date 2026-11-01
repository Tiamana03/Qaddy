import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/logic/stats_story.dart';

const RoundPlayer _alex = RoundPlayer(name: 'Alex', handicap: 0);
const RoundPlayer _tom = RoundPlayer(name: 'Tom', handicap: 0);

/// Alex birdies [birdies] of the first six holes; Tom pars them all.
Round _round(int day, int birdies) {
  final start = Round.start(
    id: 'r$day',
    course: 'Richmond Golf Club',
    format: 'Stableford',
    holes: richmondHoles,
    players: const <RoundPlayer>[_alex, _tom],
    now: DateTime(2026, 10, day, 8),
  );
  List<int?> pad(List<int> v) => <int?>[
    ...v,
    ...List<int?>.filled(richmondHoles.length - v.length, null),
  ];
  return start.copyWith(
    scores: <String, List<int?>>{
      'Alex': pad(<int>[
        for (var h = 0; h < 6; h++)
          h < birdies ? richmondHoles[h].par - 1 : richmondHoles[h].par,
      ]),
      'Tom': pad(<int>[for (var h = 0; h < 6; h++) richmondHoles[h].par]),
    },
    status: RoundStatus.completed,
    completedAt: DateTime(2026, 10, day, 12),
  );
}

CareerStats _stats(List<int> birdiesPerRound) => CareerStats.of(<Round>[
  for (final (i, b) in birdiesPerRound.indexed) _round(i + 1, b),
], you: 'Alex')!;

void main() {
  group('formStory', () {
    test('counts down to a form guide', () {
      expect(
        formStory(_stats(<int>[1])),
        '3 more rounds and your form guide starts.',
      );
      expect(
        formStory(_stats(<int>[1, 1, 1])),
        'One more round and your form guide starts.',
      );
    });

    test('is upbeat when the form is rising', () {
      expect(
        formStory(_stats(<int>[0, 0, 0, 3, 3, 3])),
        'On the up: 9 points a round better over your last three.',
      );
    });

    test('is kind when the form is falling', () {
      expect(
        formStory(_stats(<int>[3, 3, 3, 0, 0, 0])),
        'A quiet patch: 9 points a round down over your last three.',
      );
    });

    test('is calm when nothing has changed', () {
      expect(
        formStory(_stats(<int>[1, 1, 1, 1])),
        'Steady: right on your usual numbers.',
      );
    });
  });

  test('the small phrases read well', () {
    final stats = _stats(<int>[2, 2]);

    expect(parOrBetterLine(stats.mix), 'Par or better on 100% of holes');
    expect(roundsLabel(1), '1 round');
    expect(roundsLabel(12), '12 rounds');
    expect(pointsAverage(2.449), '2.4');
    expect(winRateLabel(stats), '100%');
  });
}
