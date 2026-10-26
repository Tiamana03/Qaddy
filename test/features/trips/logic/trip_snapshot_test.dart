import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

void main() {
  test('an empty plan has an empty snapshot', () {
    expect(tripSnapshot(TripPlan.empty).isEmpty, isTrue);
  });

  test("is built from the trip's own plan", () {
    final snapshot = tripSnapshot(melbourneGolfWeekendPlan);
    final byLabel = {for (final h in snapshot.highlights) h.label: h};

    expect(snapshot.isEmpty, isFalse);
    expect(byLabel['First tee']!.value, 'Kingston Heath · 8:10 AM');
    expect(byLabel['First tee']!.wide, isTrue);
    expect(byLabel['First tee']!.isCourse, isTrue);
    expect(byLabel['Saturday forecast']!.value, 'Sunny, 24°C');
    expect(snapshot.squad, hasLength(8));
    expect(snapshot.squad.first, 'Tiamana');
    expect(snapshot.pendingInvites, 1);
  });

  test('says how far planning has got and what is next', () {
    final snapshot = tripSnapshot(melbourneGolfWeekendPlan);

    expect(snapshot.planningProgress, 0.5);
    expect(snapshot.nextTask, 'Reserve Sunday dinner');
  });

  test('says what the viewer owes next, and nothing when they owe nothing', () {
    final mine = tripSnapshot(melbourneGolfWeekendPlan);
    expect(mine.upcomingPayment, contains('You owe Ben'));
    expect(mine.upcomingPayment, contains('Green fees'));

    // Ben paid for the golf and is owed, but owes the others nothing here.
    final ben = tripSnapshot(melbourneGolfWeekendPlan, viewer: 'Ben');
    expect(ben.upcomingPayment, contains('You owe'));
    final nobody = tripSnapshot(melbourneGolfWeekendPlan, viewer: 'Nobody');
    expect(nobody.upcomingPayment, isNull);
  });

  test('reports budget progress and the latest news', () {
    final snapshot = tripSnapshot(melbourneGolfWeekendPlan);

    expect(snapshot.budgetProgress, closeTo(5960 / 11500, 0.0001));
    expect(snapshot.budgetLabel, r'52% paid · $5,540 to go');
    expect(snapshot.latestMessage, 'Luke: See everyone Saturday morning.');
    expect(snapshot.latestUpdate, 'Royal Melbourne tee time moved to 8:00 AM');
  });

  test('leaves out what the plan does not have', () {
    final snapshot = tripSnapshot(TripPlan.empty.copyWith(notes: 'Just notes'));

    expect(snapshot.planningProgress, isNull);
    expect(snapshot.nextTask, isNull);
    expect(snapshot.budgetProgress, isNull);
    expect(snapshot.latestMessage, isNull);
    expect(snapshot.highlights, isEmpty);
  });
}
