/// What the Dashboard can say about today, worked out from the clock and the
/// golfer's own data — nothing is invented.
library;

import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

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

  /// The line above: "NEXT ROUND", "GET READY" or "IT'S ROUND DAY".
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
      eyebrow: "IT'S ROUND DAY",
    );
  }
  if (days == 1) {
    return const RoundCountdown(
      value: '1',
      label: 'day to tee-off',
      eyebrow: 'GET READY',
    );
  }
  return RoundCountdown(
    value: '$days',
    label: 'days to tee-off',
    eyebrow: days <= 3 ? 'GET READY' : 'NEXT ROUND',
  );
}

/// The date line under the golfer's name: "Sunday 1 November".
String dateLine(DateTime now) => now.toWeekdayAndDate();

/// A message telling the group about [round], ready for the share sheet.
String roundShareMessage(UpcomingRound round, String yourName) =>
    '${round.date} at ${round.teeTime}, ${round.course} '
    "(${round.format}, ${round.holes} holes, ${round.weather}). Who's in? "
    '– $yourName';
