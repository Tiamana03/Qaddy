/// What a round can say for itself once it is played: who won, how the golfer
/// did, their best hole and a message to send the group.
library;

import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/features/rounds/logic/stableford.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/round.dart';

/// "Tiamana wins", "Tom and Ben share the win" — the winners, in words. While
/// the round is still [finished]=false it says who leads instead: "Tom leads",
/// "You and Ben lead".
String winnersHeadline(
  List<PlayerStanding> standings, {
  String? you,
  bool finished = true,
}) {
  final leaders = leadersOf(standings);
  if (leaders.isEmpty) {
    return 'No scores yet';
  }
  final names = <String>[
    for (final leader in leaders)
      leader.player.name == you ? 'You' : leader.player.name,
  ];
  if (names.length == 1) {
    final isYou = names.single == 'You';
    if (finished) {
      return isYou ? 'You win!' : '${names.single} wins';
    }
    return isYou ? 'You lead' : '${names.single} leads';
  }
  final last = names.removeLast();
  final together = '${names.join(', ')} and $last';
  return finished ? '$together share the win' : '$together lead';
}

/// One golfer's round in numbers.
class RoundRecap {
  const RoundRecap({
    required this.standing,
    required this.pars,
    required this.bogeysOrWorse,
    required this.frontNine,
    required this.backNine,
    required this.bestHole,
    required this.bestHoleLabel,
  });

  /// The golfer's row in the table.
  final PlayerStanding standing;

  /// Holes played in par.
  final int pars;

  /// Holes played at bogey or worse (picked-up holes included).
  final int bogeysOrWorse;

  /// Stableford points on holes 1–9.
  final int frontNine;

  /// Stableford points on holes 10–18.
  final int backNine;

  /// The hole that earned the most points (the earliest, if several did), or
  /// `null` when no hole has been played.
  final int? bestHole;

  /// What the golfer scored there: "Birdie", "Par"…
  final String? bestHoleLabel;
}

/// The recap of [name]'s round, or `null` when they are not in it.
RoundRecap? recapOf(Round round, String name) {
  final player = round.playerNamed(name);
  if (player == null) {
    return null;
  }
  final standing = standingsOf(round).firstWhere((s) => s.player.name == name);

  var pars = 0;
  var bad = 0;
  var front = 0;
  var back = 0;
  int? best;
  var bestPoints = -1;
  for (var i = 0; i < round.holes.length; i++) {
    if (!round.isHolePlayed(i)) {
      continue;
    }
    final gross = round.grossAt(name, i)!;
    final par = round.holes[i].par;
    final points = pointsAt(round, player, i);
    switch (scoreKind(gross, par)) {
      case ScoreKind.par:
        pars++;
      case ScoreKind.bogey ||
          ScoreKind.double ||
          ScoreKind.worse ||
          ScoreKind.pickedUp:
        bad++;
      case ScoreKind.ace ||
          ScoreKind.albatross ||
          ScoreKind.eagle ||
          ScoreKind.birdie:
        break;
    }
    if (i < 9) {
      front += points;
    } else {
      back += points;
    }
    if (points > bestPoints) {
      bestPoints = points;
      best = i;
    }
  }

  return RoundRecap(
    standing: standing,
    pars: pars,
    bogeysOrWorse: bad,
    frontNine: front,
    backNine: back,
    bestHole: best == null ? null : round.holes[best].number,
    bestHoleLabel: best == null
        ? null
        : scoreLabel(round.grossAt(name, best)!, round.holes[best].par),
  );
}

/// A message with the result, ready for the share sheet.
String roundResultMessage(Round round, {required String you}) {
  final standings = standingsOf(round);
  final top = standings.take(3).toList();
  String line(PlayerStanding s) =>
      '${s.position}. ${s.player.name} — ${s.points} pts '
      '(${formatScore(s.toPar)})';
  final lines = <String>[for (final s in top) line(s)];
  return '${winnersHeadline(standings, you: you)} at ${round.course}! '
      '${lines.join(' · ')}. Played with Qaddy.';
}

/// Where [you] stand against your neighbour in the table: "3 pts behind
/// Tom", "2 pts clear of Ben", "Level with Tom". `null` when [you] are not in
/// the round or there is nobody to compare with.
String? chaseLine(List<PlayerStanding> standings, String you) {
  final index = standings.indexWhere((s) => s.player.name == you);
  if (index < 0 || standings.length < 2) {
    return null;
  }
  final mine = standings[index];
  String points(int n) => n == 1 ? '1 pt' : '$n pts';

  if (index > 0) {
    final ahead = standings[index - 1];
    final gap = ahead.points - mine.points;
    return gap == 0
        ? 'Level on points with ${ahead.player.name}'
        : '${points(gap)} behind ${ahead.player.name}';
  }
  final behind = standings[1];
  final gap = mine.points - behind.points;
  return gap == 0
      ? 'Level on points with ${behind.player.name}'
      : '${points(gap)} clear of ${behind.player.name}';
}
