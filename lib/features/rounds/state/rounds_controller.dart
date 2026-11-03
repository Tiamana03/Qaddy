/// The store behind every Rounds screen.
///
/// There is at most one round being played and one most recently finished
/// round. Release 1 has no backend, so both live on the device: the store
/// loads them at start-up and saves after every change (see `RoundsStorage`),
/// which means a round in progress survives the app being closed. Screens
/// read through the providers below and change a round only through
/// [RoundsController].
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/rounds/repositories/rounds_codec.dart';
import 'package:qaddy/features/rounds/repositories/rounds_storage.dart';

/// The round being played and every round finished before it.
class RoundsState {
  const RoundsState({this.live, this.history = const <Round>[]});

  /// The round in progress, or `null`.
  final Round? live;

  /// Every finished round, newest first.
  final List<Round> history;

  /// The most recently finished round, or `null`.
  Round? get completed => history.isEmpty ? null : history.first;
}

/// The clock rounds are stamped with. Tests override it.
final roundsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// The most strokes a golfer can record on one hole.
const int maxStrokes = 15;

/// How many finished rounds are kept.
const int maxHistory = 200;

/// The rounds store.
final roundsProvider = NotifierProvider<RoundsController, RoundsState>(
  RoundsController.new,
);

/// The round in progress, or `null`.
final liveRoundProvider = Provider<Round?>(
  (ref) => ref.watch(roundsProvider.select((state) => state.live)),
);

/// The last finished round, or `null`.
final completedRoundProvider = Provider<Round?>(
  (ref) => ref.watch(roundsProvider.select((state) => state.completed)),
);

/// Every finished round, newest first. This is what Statistics tells the story
/// of.
final roundHistoryProvider = Provider<List<Round>>(
  (ref) => ref.watch(roundsProvider.select((state) => state.history)),
);

/// Who has been picked for the next round: the golfer's own place is always
/// kept; they add the mates they are playing with.
final roundSetupProvider = NotifierProvider<RoundSetupController, Set<String>>(
  RoundSetupController.new,
);

/// The players picked for the next round, in invitation order.
final selectedPlayersProvider = Provider<List<RoundPlayer>>((ref) {
  final picked = ref.watch(roundSetupProvider);
  return <RoundPlayer>[
    for (final invitee in upcomingRoundInvitees)
      if (picked.contains(invitee.player.name)) invitee.player,
  ];
});

/// Chooses who plays the next round.
class RoundSetupController extends Notifier<Set<String>> {
  @override
  // Just the golfer: they add the mates they are actually playing with.
  Set<String> build() => <String>{currentUserName};

  /// Adds or removes [name]. The golfer cannot be removed from their own
  /// round.
  void toggle(String name) {
    if (name == currentUserName) {
      return;
    }
    state = state.contains(name)
        ? (<String>{...state}..remove(name))
        : <String>{...state, name};
  }

  /// Picks exactly [names] (those who are invited to the round) plus the
  /// golfer, who is always in. Used to start a round with a whole group.
  void pick(Iterable<String> names) {
    final invited = <String>{
      for (final invitee in upcomingRoundInvitees) invitee.player.name,
    };
    state = <String>{
      currentUserName,
      for (final name in names)
        if (invited.contains(name)) name,
    };
  }
}

/// Starts, scores and finishes rounds.
class RoundsController extends Notifier<RoundsState> {
  int _sequence = 0;

  DateTime get _now => ref.read(roundsClockProvider)();

  @override
  RoundsState build() {
    final storage = ref.read(roundsStorageProvider);
    // Save after every change from here on (the starting state is not a
    // change).
    listenSelf((previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(
        storage.write(encodeRounds(live: next.live, history: next.history)),
      );
    });

    final stored = storage.read();
    final restored = stored == null ? null : decodeRounds(stored);
    return RoundsState(
      live: restored?.live,
      history: restored?.history ?? const <Round>[],
    );
  }

  /// Starts a round for [players] on the first tee. Does nothing if one is
  /// already being played.
  void startRound(List<RoundPlayer> players) {
    if (state.live != null || players.isEmpty) {
      return;
    }
    state = RoundsState(
      live: Round.start(
        id: 'round-${_now.microsecondsSinceEpoch}-${_sequence++}',
        course: upcomingRound.course,
        format: upcomingRound.format,
        holes: upcomingRoundHoles,
        players: players,
        now: _now,
      ),
      history: state.history,
    );
  }

  /// Adds [delta] strokes to [player]'s score on the current hole. A score not
  /// yet touched starts from par.
  void nudgeScore(String player, int delta) {
    final round = state.live;
    if (round == null || !round.scores.containsKey(player)) {
      return;
    }
    final par = round.hole.par;
    final current = round.grossAt(player, round.currentHole) ?? par;
    _setScore(round, player, (current + delta).clamp(0, maxStrokes));
  }

  /// Sets [player]'s score on the current hole to [gross] (0 = picked up).
  void setScore(String player, int gross) {
    final round = state.live;
    if (round == null || !round.scores.containsKey(player)) {
      return;
    }
    _setScore(round, player, gross.clamp(0, maxStrokes));
  }

  void _setScore(Round round, String player, int gross) {
    final scores = <String, List<int?>>{
      for (final entry in round.scores.entries)
        entry.key: List<int?>.of(entry.value),
    };
    scores[player]![round.currentHole] = gross;
    _emit(round.copyWith(scores: scores));
  }

  /// Moves to the hole at [index] without scoring the one being left.
  void goToHole(int index) {
    final round = state.live;
    if (round == null || index < 0 || index >= round.holes.length) {
      return;
    }
    _emit(round.copyWith(currentHole: index));
  }

  /// Moves on to the next hole. Anyone not yet scored on the hole being left
  /// is given par — the golfer's "par for the course" default.
  void nextHole() {
    final round = state.live;
    if (round == null || round.currentHole >= round.holes.length - 1) {
      return;
    }
    final committed = _withParForUnscored(round);
    _emit(committed.copyWith(currentHole: round.currentHole + 1));
  }

  /// Moves back a hole.
  void previousHole() {
    final round = state.live;
    if (round == null || round.currentHole == 0) {
      return;
    }
    _emit(round.copyWith(currentHole: round.currentHole - 1));
  }

  /// Finishes the round. On the last hole the current hole counts (unscored
  /// players get par); finishing earlier counts only the holes everyone has
  /// played.
  void finishRound() {
    final round = state.live;
    if (round == null) {
      return;
    }
    final onLastHole = round.currentHole == round.holes.length - 1;
    final base = onLastHole ? _withParForUnscored(round) : round;
    final finished = base.copyWith(
      status: RoundStatus.completed,
      completedAt: _now,
    );
    state = RoundsState(
      history: <Round>[finished, ...state.history].take(maxHistory).toList(),
    );
  }

  /// Forgets every finished round (a round in progress is left alone).
  void clearHistory() {
    if (state.history.isEmpty) {
      return;
    }
    state = RoundsState(live: state.live);
  }

  /// Throws the round away, keeping the last finished one.
  void discardRound() {
    if (state.live == null) {
      return;
    }
    state = RoundsState(history: state.history);
  }

  Round _withParForUnscored(Round round) {
    final scores = <String, List<int?>>{
      for (final entry in round.scores.entries)
        entry.key: List<int?>.of(entry.value),
    };
    for (final player in round.players) {
      scores[player.name]![round.currentHole] ??= round.hole.par;
    }
    return round.copyWith(scores: scores);
  }

  void _emit(Round round) {
    state = RoundsState(live: round, history: state.history);
  }
}
