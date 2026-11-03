/// A test world where golfers have already played rounds: a container whose
/// store has a history, so Statistics, Profile and the Dashboard have a story
/// to tell.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

import 'app_test_harness.dart';

/// Plays rounds into a fresh container, one finished round at a time.
class PlayedRounds {
  PlayedRounds({List<Override> overrides = const <Override>[]}) {
    container = friendsContainer(
      overrides: <Override>[
        roundsClockProvider.overrideWithValue(() => _now),
        ...overrides,
      ],
    );
  }

  /// The container to pump an app or screen with.
  late final ProviderContainer container;

  DateTime _now = DateTime(2026, 10, 1, 8);

  /// Plays a round on [day] of October with [partners] (default: Tom), the
  /// golfer scoring [golfer] strokes on the first holes and the partners
  /// carding par. Then finishes it.
  void play(
    int day,
    List<int> golfer, {
    List<String> partners = const <String>['Tom'],
  }) {
    _now = DateTime(2026, 10, day, 8);
    final names = <String>[currentUserName, ...partners];
    final store = container.read(roundsProvider.notifier)
      ..startRound(<RoundPlayer>[
        for (final invitee in upcomingRoundInvitees)
          if (names.contains(invitee.player.name)) invitee.player,
      ]);
    for (final strokes in golfer) {
      store
        ..setScore(currentUserName, strokes)
        ..nextHole();
    }
    store.finishRound();
  }
}
