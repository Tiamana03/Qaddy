import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/dashboard/logic/dashboard_insights.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

// 2026-11-01 is a Sunday.
final DateTime _sunday = DateTime(2026, 11, 1, 9);

void main() {
  group('greetingFor', () {
    test('changes at noon and at five', () {
      expect(greetingFor(DateTime(2026, 11, 1, 6)), 'Good morning');
      expect(greetingFor(DateTime(2026, 11, 1, 11, 59)), 'Good morning');
      expect(greetingFor(DateTime(2026, 11, 1, 12)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 11, 1, 16, 59)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 11, 1, 17)), 'Good evening');
      expect(greetingFor(DateTime(2026, 11, 1, 23)), 'Good evening');
    });
  });

  group('daysUntilWeekday', () {
    test('counts forward to the next one', () {
      expect(daysUntilWeekday(_sunday, 'Saturday'), 6);
      expect(daysUntilWeekday(_sunday, 'Monday'), 1);
      expect(daysUntilWeekday(DateTime(2026, 11, 6), 'Saturday'), 1);
    });

    test('is zero on the day itself, whatever the hour', () {
      expect(daysUntilWeekday(DateTime(2026, 11, 7, 23, 30), 'Saturday'), 0);
      expect(daysUntilWeekday(_sunday, 'Sunday'), 0);
    });

    test('is null for something that is not a day', () {
      expect(daysUntilWeekday(_sunday, 'Soon'), isNull);
    });
  });

  group('roundCountdown', () {
    test('counts the days to a round', () {
      final countdown = roundCountdown(_sunday, 'Saturday')!;

      expect(countdown.value, '6');
      expect(countdown.label, 'days to tee-off');
      expect(countdown.eyebrow, 'NEXT ROUND');
    });

    test('says "get ready" in the last three days', () {
      expect(
        roundCountdown(DateTime(2026, 11, 4), 'Saturday')!.eyebrow,
        'GET READY',
      );
      expect(
        roundCountdown(DateTime(2026, 11, 3), 'Saturday')!.eyebrow,
        'NEXT ROUND',
      );
    });

    test('speaks of one day in the singular', () {
      final countdown = roundCountdown(DateTime(2026, 11, 6), 'Saturday')!;

      expect(countdown.value, '1');
      expect(countdown.label, 'day to tee-off');
    });

    test('announces round day', () {
      final countdown = roundCountdown(DateTime(2026, 11, 7), 'Saturday')!;

      expect(countdown.value, 'Today');
      expect(countdown.eyebrow, "IT'S ROUND DAY");
    });

    test('has nothing to say about a day it cannot place', () {
      expect(roundCountdown(_sunday, 'Whenever'), isNull);
    });
  });

  test('dateLine is the weekday and date', () {
    expect(dateLine(_sunday), 'Sunday 1 November');
  });

  test('a round share message says when, where and who is in', () {
    expect(
      roundShareMessage(upcomingRound, 'Tiamana'),
      'Saturday at 8:20 AM, Richmond Golf Club (Stableford, 18 holes, '
      "21°C Sunny). Who's in? – Tiamana",
    );
  });
}
