import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

void main() {
  test('an empty plan has an empty snapshot', () {
    expect(tripSnapshot(TripPlan.empty).isEmpty, isTrue);
  });

  test("is built from the trip's own plan", () {
    final snapshot = tripSnapshot(melbourneGolfWeekendPlan);

    expect(snapshot.isEmpty, isFalse);
    expect(snapshot.firstTee!.course, 'Kingston Heath');
    expect(snapshot.firstTee!.time, '8:10 AM');
    expect(snapshot.firstTee!.day, 'Sun 29 Nov');
    expect(snapshot.firstTee!.weather!.forecast, 'Partly Cloudy');
    expect(snapshot.squad, hasLength(8));
    expect(snapshot.squad.first, 'Tiamana');
    expect(snapshot.pendingInvites, 1);
  });

  test('says how far planning has got and what is next', () {
    final snapshot = tripSnapshot(melbourneGolfWeekendPlan);

    expect(snapshot.planningProgress, 0.5);
    expect(snapshot.tasksDone, 3);
    expect(snapshot.tasksTotal, 6);
    expect(snapshot.nextTask, 'Reserve Sunday dinner');
  });

  test('says what the viewer owes next, and nothing when they owe nothing', () {
    final mine = tripSnapshot(melbourneGolfWeekendPlan);
    expect(mine.upcomingPayment, r'You owe Ben $730');
    expect(mine.paymentFor, 'Green fees — 3 rounds');

    final nobody = tripSnapshot(melbourneGolfWeekendPlan, viewer: 'Nobody');
    expect(nobody.upcomingPayment, isNull);
    expect(nobody.paymentFor, isNull);
  });

  test('reports budget progress and the latest news', () {
    final snapshot = tripSnapshot(melbourneGolfWeekendPlan);

    expect(snapshot.budgetProgress, closeTo(5960 / 11500, 0.0001));
    expect(snapshot.budgetLabel, r'52% paid · $5,540 to go');
    expect(snapshot.latestMessage, 'Luke: See everyone Saturday morning.');
    expect(snapshot.latestUpdate, 'Royal Melbourne tee time moved to 8:00 AM');
  });

  group('up next', () {
    TripUpNext? upNextAt(DateTime now) => tripSnapshot(
      melbourneGolfWeekendPlan,
      trip: melbourneGolfWeekend,
      now: now,
    ).upNext;

    test('is the first thing still to come', () {
      final next = upNextAt(DateTime(2026, 11));

      expect(next!.title, 'Qantas QF431');
      expect(next.when, 'Sat 28 Nov · 8:30 AM');
      expect(next.icon, Icons.flight_outlined);
    });

    test('moves on as events pass', () {
      expect(upNextAt(DateTime(2026, 11, 28, 9))!.title, 'Airport Transfer');
      expect(
        upNextAt(DateTime(2026, 11, 29, 7, 30))!.title,
        'Golf · Kingston Heath',
      );
    });

    test('says Today and Tomorrow instead of the date', () {
      expect(upNextAt(DateTime(2026, 11, 28, 6))!.when, 'Today, 8:30 AM');
      expect(upNextAt(DateTime(2026, 11, 27, 20))!.when, 'Tomorrow, 8:30 AM');
    });

    test('is absent once everything has happened', () {
      expect(upNextAt(DateTime(2027)), isNull);
    });

    test('is absent when no trip or time is given', () {
      expect(tripSnapshot(melbourneGolfWeekendPlan).upNext, isNull);
    });
  });

  test('leaves out what the plan does not have', () {
    final snapshot = tripSnapshot(TripPlan.empty.copyWith(notes: 'Just notes'));

    expect(snapshot.planningProgress, isNull);
    expect(snapshot.nextTask, isNull);
    expect(snapshot.budgetProgress, isNull);
    expect(snapshot.latestMessage, isNull);
    expect(snapshot.firstTee, isNull);
  });

  group('countdown wording', () {
    TripCountdown c(String value) => TripCountdown(value: value, label: '');

    test('builds anticipation as the trip nears', () {
      expect(tripCountdownEyebrow(c('33')), 'NEXT TRIP');
      expect(tripCountdownEyebrow(c('7')), 'GET READY');
      expect(tripCountdownEyebrow(c('1')), 'GET READY');
      expect(tripCountdownEyebrow(c('Today')), "IT'S TRIP DAY");
      expect(tripCountdownEyebrow(c('Now')), 'LIVE NOW');
    });

    test('only a close trip glows', () {
      expect(tripCountdownIsImminent(c('33')), isFalse);
      expect(tripCountdownIsImminent(c('8')), isFalse);
      expect(tripCountdownIsImminent(c('7')), isTrue);
      expect(tripCountdownIsImminent(c('Today')), isTrue);
      expect(tripCountdownIsImminent(c('Now')), isTrue);
      expect(tripCountdownIsImminent(c('Done')), isFalse);
    });
  });
}
