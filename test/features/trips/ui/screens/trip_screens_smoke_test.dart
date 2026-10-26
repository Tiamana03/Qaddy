import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/ui/screens/trip_accommodation_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_chat_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_details_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_expenses_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_flights_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_golf_schedule_screen.dart';
import 'package:qaddy/features/trips/ui/screens/trip_planning_screen.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

import '../../trips_test_harness.dart';

void main() {
  testWidgets('details shows destination, countdown and members', (
    tester,
  ) async {
    await pumpTrips(tester, const TripDetailsScreen(tripId: melbourneId));

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Melbourne, Australia'), findsOneWidget);
    expect(find.text('Countdown'), findsOneWidget);
    expect(find.text('Tiamana'), findsWidgets);
  });

  testWidgets('planning shows the daily timeline', (tester) async {
    await pumpTrips(tester, const TripPlanningScreen(tripId: melbourneId));

    expect(find.textContaining('Kingston Heath'), findsWidgets);
  });

  testWidgets('flights shows both legs', (tester) async {
    await pumpTrips(tester, const TripFlightsScreen(tripId: melbourneId));

    expect(find.textContaining('QF431'), findsWidgets);
    expect(find.textContaining('QF438'), findsWidgets);
  });

  testWidgets('accommodation shows the hotel', (tester) async {
    await pumpTrips(tester, const TripAccommodationScreen(tripId: melbourneId));

    expect(find.text('RACV Healesville Resort'), findsWidgets);
  });

  testWidgets('golf schedule shows the courses', (tester) async {
    await pumpTrips(tester, const TripGolfScheduleScreen(tripId: melbourneId));

    expect(find.textContaining('Kingston Heath'), findsWidgets);
  });

  testWidgets('expenses shows the trip cost', (tester) async {
    await pumpTrips(tester, const TripExpensesScreen(tripId: melbourneId));

    expect(find.text('Trip Cost'), findsOneWidget);
    expect(find.text(r'$11,500'), findsOneWidget);
  });

  testWidgets('chat shows the seeded messages', (tester) async {
    await pumpTrips(tester, const TripChatScreen(tripId: melbourneId));

    expect(find.text('Looking forward to this trip!'), findsOneWidget);
  });

  testWidgets('an unknown trip id shows the not-found state', (tester) async {
    await pumpTrips(tester, const TripDetailsScreen(tripId: 'nope'));

    expect(find.byType(TripNotFound), findsOneWidget);
  });
}
