import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';

void main() {
  test('only the shared placeholder trip has a snapshot', () {
    expect(tripSnapshot(melbourneGolfWeekend), isNotNull);
    expect(tripSnapshot(goldCoastGolfEscape), isNull);
    expect(tripSnapshot(tasmaniaGolfTour), isNull);
  });

  test("is built from the trip's own placeholder data", () {
    final snapshot = tripSnapshot(melbourneGolfWeekend)!;
    final byLabel = {for (final h in snapshot.highlights) h.label: h};

    expect(byLabel['First tee']!.value, 'Kingston Heath · 8:10 AM');
    expect(byLabel['First tee']!.wide, isTrue);
    expect(byLabel['Saturday forecast']!.value, 'Sunny, 24°C');
    expect(byLabel['Expenses']!.value, 'All settled');
    expect(snapshot.squad, hasLength(8));
    expect(snapshot.squad.first, 'Tiamana');
    expect(snapshot.latestUpdate, 'Luke: See everyone Saturday morning.');
  });
}
