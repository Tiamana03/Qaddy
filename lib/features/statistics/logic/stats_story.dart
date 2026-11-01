/// The words Statistics uses to tell the golfer's story. Pure, so every
/// sentence is tested without a screen.
library;

import 'package:qaddy/features/statistics/logic/career_stats.dart';

/// How many rounds it takes before form can be compared.
const int roundsForForm = 4;

/// One line about how the golfer is playing lately.
String formStory(CareerStats stats) {
  final trend = stats.formTrend;
  if (trend == null) {
    final more = roundsForForm - stats.rounds;
    return more == 1
        ? 'One more round and your form guide starts.'
        : '$more more rounds and your form guide starts.';
  }
  final points = trend.abs().round();
  if (trend >= 1.5) {
    return 'On the up: $points ${points == 1 ? 'point' : 'points'} a round '
        'better over your last three.';
  }
  if (trend <= -1.5) {
    return 'A quiet patch: $points ${points == 1 ? 'point' : 'points'} a '
        'round down over your last three.';
  }
  return 'Steady: right on your usual numbers.';
}

/// "Par or better on 54% of holes."
String parOrBetterLine(ScoreMix mix) =>
    'Par or better on ${(mix.parOrBetterRate * 100).round()}% of holes';

/// "42%" — the share of rounds won.
String winRateLabel(CareerStats stats) => '${(stats.winRate * 100).round()}%';

/// "1 round" / "12 rounds".
String roundsLabel(int rounds) => rounds == 1 ? '1 round' : '$rounds rounds';

/// One decimal place for an average of points: "2.4".
String pointsAverage(double value) => value.toStringAsFixed(1);
