/// Which achievements the golfer has earned — worked out from the rounds they
/// have actually played, never stored or assumed.
library;

import 'package:qaddy/features/achievements/models/achievement.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

class _Definition {
  const _Definition(this.id, this.title, this.blurb, this.target, this.measure);

  final String id;
  final String title;
  final String blurb;
  final int target;
  final int Function(CareerStats stats) measure;
}

final List<_Definition> _definitions = <_Definition>[
  _Definition(
    'first-round',
    'First Round',
    'Finish your first round',
    1,
    (s) => s.rounds,
  ),
  _Definition(
    'full-eighteen',
    'Full Eighteen',
    'Play all 18 holes in a round',
    1,
    (s) => s.chronological.where((r) => r.holes >= 18).length,
  ),
  _Definition(
    'birdie-hunter',
    'Birdie Hunter',
    'Make 5 birdies or better',
    5,
    (s) => s.mix.birdies + s.mix.eagleOrBetter,
  ),
  _Definition(
    'eagle-eye',
    'Eagle Eye',
    'Make an eagle or better',
    1,
    (s) => s.mix.eagleOrBetter,
  ),
  _Definition(
    'winner',
    'Winner',
    'Win a round against your mates',
    1,
    (s) => s.wins,
  ),
  _Definition(
    'on-a-roll',
    'On a Roll',
    'Win 3 rounds in a row',
    3,
    (s) => s.longestWinStreak,
  ),
  _Definition(
    'social-golfer',
    'Social Golfer',
    'Play with 3 different golfers',
    3,
    (s) => s.rivals.length,
  ),
  _Definition('regular', 'Regular', 'Play 10 rounds', 10, (s) => s.rounds),
];

/// Every achievement with the golfer's progress. [stats] is `null` before
/// their first round, when nothing has been earned.
List<Achievement> achievementsFor(CareerStats? stats) => <Achievement>[
  for (final def in _definitions)
    Achievement(
      id: def.id,
      title: def.title,
      blurb: def.blurb,
      target: def.target,
      progress: stats == null ? 0 : def.measure(stats).clamp(0, def.target),
    ),
];

/// The achievements that [round] earned: unlocked with it in [history] but not
/// without it. [history] must include [round].
List<Achievement> newlyUnlocked(
  List<Round> history,
  Round round, {
  required String you,
}) {
  final without = <Round>[
    for (final r in history)
      if (r.id != round.id) r,
  ];
  final before = achievementsFor(CareerStats.of(without, you: you));
  final after = achievementsFor(CareerStats.of(history, you: you));
  return <Achievement>[
    for (var i = 0; i < after.length; i++)
      if (after[i].unlocked && !before[i].unlocked) after[i],
  ];
}

/// The one to chase next: the unearned achievement closest to done.
Achievement? nextUp(List<Achievement> achievements) {
  Achievement? best;
  for (final a in achievements) {
    if (a.unlocked) {
      continue;
    }
    if (best == null || a.fraction > best.fraction) {
      best = a;
    }
  }
  return best;
}
