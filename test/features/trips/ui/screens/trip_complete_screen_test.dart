import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/screens/trip_complete_screen.dart';

import '../../trips_test_harness.dart';

Future<void> _pumpWithRouter(WidgetTester tester) async {
  await pumpTripsRouter(
    tester,
    initialLocation: '/complete',
    routes: <RouteBase>[
      GoRoute(
        path: '/complete',
        builder: (context, state) =>
            const TripCompleteScreen(tripId: melbourneId),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Text('Home')),
      GoRoute(path: '/trips', builder: (context, state) => const Text('Trips')),
    ],
  );
}

void main() {
  testWidgets('celebrates the champion and the other awards', (tester) async {
    await _pumpWithRouter(tester);

    expect(find.text("That's a wrap"), findsOneWidget);
    expect(find.text('Trip Champion'), findsOneWidget);
    expect(find.text('Tiamana'), findsOneWidget);
    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('Runner Up'), findsOneWidget);
    expect(find.text('Longest Drive'), findsOneWidget);
    expect(find.text('Nearest The Pin'), findsOneWidget);
    expect(find.text('Winners'), findsNothing);
    expect(find.text('Memories'), findsNothing);
  });

  testWidgets('lists the courses played and the bill', (tester) async {
    await _pumpWithRouter(tester);

    expect(find.text('Courses played'), findsOneWidget);
    expect(find.text('Kingston Heath'), findsOneWidget);
    expect(find.text('Royal Melbourne'), findsOneWidget);
    expect(find.text('The bill'), findsOneWidget);
    expect(find.text('Total cost'), findsOneWidget);
    expect(find.text('each'), findsOneWidget);
  });

  testWidgets('a trip with no results shows no empty awards', (tester) async {
    await pumpTripsRouter(
      tester,
      initialLocation: '/complete',
      routes: <RouteBase>[
        GoRoute(
          path: '/complete',
          builder: (context, state) =>
              const TripCompleteScreen(tripId: 'gold-coast-golf-escape'),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text("That's a wrap"), findsOneWidget);
    expect(find.text('Trip Champion'), findsNothing);
    expect(find.text('The bill'), findsOneWidget);
  });

  testWidgets('Return Home navigates to /home', (tester) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Return home'));
    await tester.tap(find.text('Return home'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Archive Trip archives the trip and returns to /trips', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Archive trip'));
    await tester.tap(find.text('Archive trip'));
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsOneWidget);
  });

  testWidgets('Archive Trip moves the trip into the archive', (tester) async {
    await _pumpWithRouter(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TripCompleteScreen)),
    );

    await tester.ensureVisible(find.text('Archive trip'));
    await tester.tap(find.text('Archive trip'));
    await tester.pumpAndSettle();

    expect(
      container.read(archivedTripsProvider).map((trip) => trip.id),
      contains(melbourneId),
    );
  });
}
