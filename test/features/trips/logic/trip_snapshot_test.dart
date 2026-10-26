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
    expect(byLabel['Saturday forecast']!.value, 'Sunny, 24°C');
    expect(byLabel['Expenses']!.value, contains('outstanding'));
    expect(snapshot.squad, hasLength(8));
    expect(snapshot.squad.first, 'Tiamana');
    expect(snapshot.latestUpdate, 'Luke: See everyone Saturday morning.');
  });
}
