import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/achievements/logic/achievements.dart';
import 'package:qaddy/features/achievements/models/achievement.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

const RoundPlayer _alex = RoundPlayer(name: 'Alex', handicap: 0);

/// A finished round on [day]: Alex plays [alex] strokes from hole 1 against
/// partners who card par on those holes.
Round _round(
  int day,
  List<int> alex, {
  List<String> partners = const <String>['Tom'],
}) {
  final players = <RoundPlayer>[
    _alex,
    for (final name in partners) RoundPlayer(name: name, handicap: 0),
  ];
  final start = Round.start(
    id: 'r$day',
    course: 'Richmond Golf Club',
    format: 'Stableford',
    holes: richmondHoles,
    players: players,
    now: DateTime(2026, 10, day, 8),
  );
  List<int?> pad(List<int> v) => <int?>[
    ...v,
    ...List<int?>.filled(richmondHoles.length - v.length, null),
  ];
  return start.copyWith(
    scores: <String, List<int?>>{
      'Alex': pad(alex),
      for (final name in partners)
        name: pad(<int>[
          for (var h = 0; h < alex.length; h++) richmondHoles[h].par,
        ]),
    },
    status: RoundStatus.completed,
    completedAt: DateTime(2026, 10, day, 12),
  );
}

List<int> _pars(int holes) => <int>[
  for (var h = 0; h < holes; h++) richmondHoles[h].par,
];

Achievement _find(List<Achievement> all, String id) =>
    all.firstWhere((a) => a.id == id);

void main() {
  group('before any round', () {
    test('nothing is earned and everything is in reach', () {
      final all = achievementsFor(null);

      expect(all, hasLength(8));
      expect(all.every((a) => !a.unlocked), isTrue);
      expect(all.every((a) => a.progress == 0), isTrue);
    });
  });

  group('progress', () {
    test('the first round earns First Round', () {
      final stats = CareerStats.of(<Round>[_round(1, _pars(4))], you: 'Alex');
      final all = achievementsFor(stats);

      expect(_find(all, 'first-round').unlocked, isTrue);
      expect(_find(all, 'first-round').progressLabel, 'Earned');
      expect(_find(all, 'regular').progress, 1);
      expect(_find(all, 'regular').progressLabel, '1 of 10');
    });

    test('only a full eighteen earns Full Eighteen', () {
      final short = achievementsFor(
        CareerStats.of(<Round>[_round(1, _pars(9))], you: 'Alex'),
      );
      final full = achievementsFor(
        CareerStats.of(<Round>[_round(1, _pars(18))], you: 'Alex'),
      );

      expect(_find(short, 'full-eighteen').unlocked, isFalse);
      expect(_find(full, 'full-eighteen').unlocked, isTrue);
    });

    test('birdies and eagles both count towards Birdie Hunter', () {
      // A birdie, an eagle, then a par on holes 1–3.
      final stats = CareerStats.of(<Round>[
        _round(1, <int>[3, 3, 3]),
      ], you: 'Alex');
      final all = achievementsFor(stats);

      expect(_find(all, 'birdie-hunter').progress, 2);
      expect(_find(all, 'eagle-eye').unlocked, isTrue);
    });

    test('a win earns Winner and a streak of three On a Roll', () {
      final wins = <Round>[
        for (var day = 1; day <= 3; day++) _round(day, <int>[3, 4, 2]),
      ];
      final all = achievementsFor(CareerStats.of(wins, you: 'Alex'));

      expect(_find(all, 'winner').unlocked, isTrue);
      expect(_find(all, 'on-a-roll').unlocked, isTrue);
    });

    test('Social Golfer counts different playing partners', () {
      final two = achievementsFor(
        CareerStats.of(<Round>[
          _round(1, _pars(3), partners: <String>['Tom', 'Ben']),
        ], you: 'Alex'),
      );
      final three = achievementsFor(
        CareerStats.of(<Round>[
          _round(1, _pars(3), partners: <String>['Tom', 'Ben', 'Luke']),
        ], you: 'Alex'),
      );

      expect(_find(two, 'social-golfer').progress, 2);
      expect(_find(two, 'social-golfer').unlocked, isFalse);
      expect(_find(three, 'social-golfer').unlocked, isTrue);
    });

    test('progress never exceeds the target', () {
      final rounds = <Round>[
        for (var day = 1; day <= 12; day++) _round(day, _pars(3)),
      ];
      final regular = _find(
        achievementsFor(CareerStats.of(rounds, you: 'Alex')),
        'regular',
      );

      expect(regular.progress, 10);
      expect(regular.fraction, 1);
      expect(regular.unlocked, isTrue);
    });
  });

  group('newlyUnlocked', () {
    test('lists what the round just played earned', () {
      final first = _round(1, <int>[4, 5, 3]);

      final earned = newlyUnlocked(<Round>[first], first, you: 'Alex');

      // Level with Tom, so a shared first place counts as a win.
      expect(earned.map((a) => a.id), <String>['first-round', 'winner']);
    });

    test('does not repeat what was already earned', () {
      final first = _round(1, <int>[4, 5, 3]);
      final second = _round(2, <int>[4, 5, 3]);

      final earned = newlyUnlocked(<Round>[second, first], second, you: 'Alex');

      expect(earned, isEmpty);
    });

    test('a birdie round can earn several at once', () {
      final first = _round(1, <int>[2, 4, 3]);

      final ids = newlyUnlocked(
        <Round>[first],
        first,
        you: 'Alex',
      ).map((a) => a.id).toList();

      expect(ids, containsAll(<String>['first-round', 'eagle-eye', 'winner']));
    });
  });

  group('nextUp', () {
    test('is the unearned achievement closest to done', () {
      final stats = CareerStats.of(<Round>[
        _round(1, <int>[3, 4, 3]), // 2 birdies of 5, eagle none
      ], you: 'Alex');

      final next = nextUp(achievementsFor(stats))!;

      expect(next.id, isNot('first-round'));
      expect(next.unlocked, isFalse);
    });

    test('is null when everything has been earned', () {
      final all = <Achievement>[
        const Achievement(
          id: 'a',
          title: 'A',
          blurb: 'A',
          progress: 1,
          target: 1,
        ),
      ];

      expect(nextUp(all), isNull);
    });
  });
}
