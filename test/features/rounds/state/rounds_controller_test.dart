import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/rounds/repositories/rounds_storage.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

const RoundPlayer _alex = RoundPlayer(name: 'Alex', handicap: 8.4);
const RoundPlayer _tom = RoundPlayer(name: 'Tom', handicap: 8);

/// Remembers the document so a second store can "restart" from it.
class _MemoryStorage implements RoundsStorage {
  String? document;

  @override
  String? read() => document;

  @override
  Future<void> write(String document) async => this.document = document;
}

ProviderContainer _container([RoundsStorage? storage]) {
  final container = ProviderContainer(
    overrides: <Override>[
      roundsClockProvider.overrideWithValue(() => DateTime(2026, 11, 7, 8, 20)),
      if (storage != null) roundsStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

RoundsController _store(ProviderContainer c) => c.read(roundsProvider.notifier);

void main() {
  group('starting', () {
    test('begins on the first tee with nothing scored', () {
      final c = _container();

      _store(c).startRound(<RoundPlayer>[_alex, _tom]);
      final round = c.read(liveRoundProvider)!;

      expect(round.currentHole, 0);
      expect(round.players, hasLength(2));
      expect(round.holesPlayed, 0);
      expect(round.course, 'Richmond Golf Club');
      expect(round.isCompleted, isFalse);
    });

    test('ignores a second start while one is being played', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);
      final first = c.read(liveRoundProvider)!.id;

      _store(c).startRound(<RoundPlayer>[_alex, _tom]);

      expect(c.read(liveRoundProvider)!.id, first);
      expect(c.read(liveRoundProvider)!.players, hasLength(1));
    });

    test('needs at least one player', () {
      final c = _container();

      _store(c).startRound(<RoundPlayer>[]);

      expect(c.read(liveRoundProvider), isNull);
    });
  });

  group('scoring', () {
    test('a score starts from par and moves a stroke at a time', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);

      _store(c).nudgeScore('Alex', 1); // hole 1 is par 4
      expect(c.read(liveRoundProvider)!.grossAt('Alex', 0), 5);

      _store(c).nudgeScore('Alex', -2);
      expect(c.read(liveRoundProvider)!.grossAt('Alex', 0), 3);
    });

    test('a score can be set outright and cannot go out of range', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);

      _store(c).setScore('Alex', 99);
      expect(c.read(liveRoundProvider)!.grossAt('Alex', 0), maxStrokes);

      _store(c).setScore('Alex', -3);
      expect(c.read(liveRoundProvider)!.grossAt('Alex', 0), 0);
    });

    test('ignores a player who is not in the round', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);

      _store(c).nudgeScore('Ghost', 1);

      expect(c.read(liveRoundProvider)!.scores.containsKey('Ghost'), isFalse);
    });

    test('next hole gives par to anyone not yet scored', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex, _tom]);
      _store(c).setScore('Alex', 3);

      _store(c).nextHole();
      final round = c.read(liveRoundProvider)!;

      expect(round.currentHole, 1);
      expect(round.grossAt('Alex', 0), 3);
      expect(round.grossAt('Tom', 0), 4);
      expect(round.isHolePlayed(0), isTrue);
      expect(round.holesPlayed, 1);
    });

    test('going back or jumping about does not score the hole left', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);
      _store(c).nextHole();

      _store(c).previousHole();
      _store(c).goToHole(5);

      final round = c.read(liveRoundProvider)!;
      expect(round.currentHole, 5);
      expect(round.hasScore('Alex', 5), isFalse);
      expect(round.hasScore('Alex', 0), isTrue);
    });

    test('cannot move past the first or last hole', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);

      _store(c).previousHole();
      expect(c.read(liveRoundProvider)!.currentHole, 0);

      _store(c).goToHole(17);
      _store(c).nextHole();
      expect(c.read(liveRoundProvider)!.currentHole, 17);
      _store(c).goToHole(40);
      expect(c.read(liveRoundProvider)!.currentHole, 17);
    });
  });

  group('finishing', () {
    test('on the last hole it counts that hole and files the round away', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);
      _store(c).goToHole(17);

      _store(c).finishRound();

      expect(c.read(liveRoundProvider), isNull);
      final done = c.read(completedRoundProvider)!;
      expect(done.status, RoundStatus.completed);
      expect(done.hasScore('Alex', 17), isTrue);
      expect(done.completedAt, DateTime(2026, 11, 7, 8, 20));
    });

    test('finishing early counts only the holes everyone played', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex, _tom]);
      _store(c).nextHole();
      _store(c).nextHole();
      _store(c).setScore('Alex', 3); // hole 3 half-way through

      _store(c).finishRound();

      expect(c.read(completedRoundProvider)!.holesPlayed, 2);
    });

    test('discarding a round keeps the last finished one', () {
      final c = _container();
      _store(c).startRound(<RoundPlayer>[_alex]);
      _store(c).finishRound();
      _store(c).startRound(<RoundPlayer>[_alex, _tom]);

      _store(c).discardRound();

      expect(c.read(liveRoundProvider), isNull);
      expect(c.read(completedRoundProvider), isNotNull);
    });
  });

  group('who is playing', () {
    test('starts with just the golfer; they add the mates they play with', () {
      final c = _container();

      final picked = c.read(selectedPlayersProvider).map((p) => p.name);

      expect(picked, <String>[upcomingRoundInvitees.first.player.name]);
    });

    test('a friend can be added and removed', () {
      final c = _container();

      c.read(roundSetupProvider.notifier).toggle('Josh');
      expect(
        c.read(selectedPlayersProvider).map((p) => p.name),
        contains('Josh'),
      );

      c.read(roundSetupProvider.notifier).toggle('Josh');
      expect(
        c.read(selectedPlayersProvider).map((p) => p.name),
        isNot(contains('Josh')),
      );
    });

    test('a whole group can be picked at once', () {
      final c = _container();

      c.read(roundSetupProvider.notifier).pick(<String>[
        'Tom',
        'Luke',
        'Stranger',
      ]);

      expect(
        c.read(selectedPlayersProvider).map((p) => p.name).toSet(),
        <String>{upcomingRoundInvitees.first.player.name, 'Tom', 'Luke'},
      );
    });

    test('the golfer cannot be taken out of their own round', () {
      final c = _container();
      final you = upcomingRoundInvitees.first.player.name;

      c.read(roundSetupProvider.notifier).toggle(you);

      expect(c.read(selectedPlayersProvider).first.name, you);
    });
  });

  group('history', () {
    test('keeps every finished round, newest first', () {
      final c = _container();
      final store = _store(c);

      for (var i = 0; i < 3; i++) {
        store
          ..startRound(<RoundPlayer>[_alex])
          ..nextHole()
          ..finishRound();
      }

      final history = c.read(roundHistoryProvider);
      expect(history, hasLength(3));
      expect(history.every((r) => r.isCompleted), isTrue);
      expect(c.read(completedRoundProvider), same(history.first));
    });

    test('a discarded round is not history', () {
      final c = _container();
      _store(c)
        ..startRound(<RoundPlayer>[_alex])
        ..discardRound();

      expect(c.read(roundHistoryProvider), isEmpty);
    });

    test('only the most recent rounds are kept', () {
      final c = _container();
      final store = _store(c);

      for (var i = 0; i < maxHistory + 5; i++) {
        store
          ..startRound(<RoundPlayer>[_alex])
          ..finishRound();
      }

      expect(c.read(roundHistoryProvider), hasLength(maxHistory));
    });

    test('the whole history survives a restart', () async {
      final storage = _MemoryStorage();
      final first = _container(storage);
      for (var i = 0; i < 3; i++) {
        _store(first)
          ..startRound(<RoundPlayer>[_alex])
          ..finishRound();
      }
      await Future<void>.delayed(Duration.zero);

      final second = _container(storage);

      expect(second.read(roundHistoryProvider), hasLength(3));
    });

    test('a version 1 document (one finished round) still loads', () {
      final storage = _MemoryStorage()
        ..document = jsonEncode(<String, Object?>{
          'version': 1,
          'live': null,
          'completed': <String, Object?>{
            'id': 'old',
            'course': 'Richmond Golf Club',
            'format': 'Stableford',
            'players': <Object?>[
              <String, Object?>{'name': 'Alex', 'handicap': 8.4},
            ],
            'scores': <String, Object?>{'Alex': List<int?>.filled(18, 4)},
            'currentHole': 17,
            'status': 'completed',
            'startedAt': '2026-10-01T08:00:00.000',
            'completedAt': '2026-10-01T12:00:00.000',
          },
        });

      final c = _container(storage);

      expect(c.read(roundHistoryProvider), hasLength(1));
      expect(c.read(completedRoundProvider)!.id, 'old');
    });
  });

  group('surviving a restart', () {
    test('a round in progress comes back with its scores', () async {
      final storage = _MemoryStorage();
      final first = _container(storage);
      _store(first).startRound(<RoundPlayer>[_alex, _tom]);
      _store(first).setScore('Alex', 3);
      _store(first).nextHole();
      _store(first).nudgeScore('Tom', 2);
      await Future<void>.delayed(Duration.zero);

      final second = _container(storage);
      final round = second.read(liveRoundProvider)!;

      expect(round.currentHole, 1);
      expect(round.grossAt('Alex', 0), 3);
      expect(round.grossAt('Tom', 0), 4);
      expect(round.grossAt('Tom', 1), 7);
      expect(round.players.map((p) => p.handicap), <double>[8.4, 8]);
    });

    test('a finished round comes back too', () async {
      final storage = _MemoryStorage();
      final first = _container(storage);
      _store(first).startRound(<RoundPlayer>[_alex]);
      _store(first).finishRound();
      await Future<void>.delayed(Duration.zero);

      final second = _container(storage);

      expect(second.read(liveRoundProvider), isNull);
      expect(second.read(completedRoundProvider)!.isCompleted, isTrue);
    });

    test('an unreadable document starts fresh instead of crashing', () {
      final storage = _MemoryStorage()..document = '{not json';

      final c = _container(storage);

      expect(c.read(liveRoundProvider), isNull);
      expect(c.read(completedRoundProvider), isNull);
    });
  });
}
