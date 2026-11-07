/// What the Dashboard can say about today, worked out from the clock and the
/// golfer's own data — nothing is invented.
library;

import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/features/dashboard/models/placeholder_dashboard.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/round.dart';

/// "Good morning", "Good afternoon" or "Good evening" for [now].
String greetingFor(DateTime now) {
  if (now.hour < 12) {
    return 'Good morning';
  }
  if (now.hour < 17) {
    return 'Good afternoon';
  }
  return 'Good evening';
}

/// How many days from [now] until the next [weekdayName] ("Saturday"): 0 when
/// it is that day today. `null` when the name is not a weekday.
int? daysUntilWeekday(DateTime now, String weekdayName) {
  const names = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final index = names.indexOf(weekdayName);
  if (index < 0) {
    return null;
  }
  return (index + 1 - now.weekday) % 7;
}

/// The headline of the next-round card: a big figure, what it counts and a
/// small line above that changes as the day gets closer.
class RoundCountdown {
  const RoundCountdown({
    required this.value,
    required this.label,
    required this.eyebrow,
  });

  /// The large figure or word: "6", "1" or "Today".
  final String value;

  /// What it counts: "days to tee-off".
  final String label;

  /// The line above: "Next round", "Get ready" or "It's round day".
  final String eyebrow;
}

/// The countdown to a round on [weekdayName] (e.g. "Saturday"), seen from
/// [now]. `null` when the day is not a weekday name.
RoundCountdown? roundCountdown(DateTime now, String weekdayName) {
  final days = daysUntilWeekday(now, weekdayName);
  if (days == null) {
    return null;
  }
  if (days == 0) {
    return const RoundCountdown(
      value: 'Today',
      label: 'you tee off',
      eyebrow: "It's round day",
    );
  }
  if (days == 1) {
    return const RoundCountdown(
      value: '1',
      label: 'day to tee-off',
      eyebrow: 'Get ready',
    );
  }
  return RoundCountdown(
    value: '$days',
    label: 'days to tee-off',
    eyebrow: days <= 3 ? 'Get ready' : 'Next round',
  );
}

/// The date line under the golfer's name: "Sunday 1 November".
String dateLine(DateTime now) => now.toWeekdayAndDate();

/// The golfer's most recent finished round, as the "Your game" card shows it.
///
/// The golfer is [you]; when they were not in the round, `null`. [now] is the
/// moment "when" is measured from.
DashboardLastRound? lastRoundFrom(Round round, String you, DateTime now) {
  final standing = standingsOf(
    round,
  ).where((s) => s.player.name == you).firstOrNull;
  if (standing == null) {
    return null;
  }
  final rank = int.tryParse(standing.position.replaceAll('T', '')) ?? 1;
  return DashboardLastRound(
    course: round.course,
    when: _whenLabel(
      (round.completedAt ?? round.startedAt).calendarDaysUntil(now),
    ),
    score: standing.gross,
    stableford: standing.points,
    position: ordinal(rank),
  );
}

String _whenLabel(int daysAgo) {
  if (daysAgo <= 0) {
    return 'Today';
  }
  if (daysAgo == 1) {
    return 'Yesterday';
  }
  return '$daysAgo days ago';
}
