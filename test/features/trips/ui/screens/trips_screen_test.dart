// Verifies the Trips screen: the next trip leads as a countdown hero, then a
// compact summary, quick actions and the remaining upcoming and past trips,
// and that every trip opens its own details page. A fixed `now` keeps the
// countdown independent of today's date.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/screens/trips_screen.dart';

import '../../trips_test_harness.dart';

final DateTime _now = DateTime(2026, 10, 26);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  double width = 400,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 900);

  final container = await pumpTripsRouter(
    tester,
    initialLocation: '/trips',
    routes: <RouteBase>[
      GoRoute(
        path: '/trips',
        builder: (context, state) => TripsScreen(now: _now),
        routes: <RouteBase>[
          GoRoute(
            path: 'create',
            builder: (context, state) => const Text('Create Trip Form'),
          ),
          GoRoute(
            path: ':tripId',
            builder: (context, state) =>
                Text('Details of ${state.pathParameters['tripId']}'),
          ),
        ],
      ),
    ],
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('leads with the next trip, then summary, actions and lists', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);

    // Hero: the next trip, with its countdown.
    expect(find.text('NEXT TRIP'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);
    expect(find.text('days to go'), findsOneWidget);
    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);

    // Compact summary and quick actions.
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past'), findsOneWidget);
    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Browse Trips'), findsOneWidget);

    // The rest of the upcoming trips, then the past ones — the featured trip
    // is not repeated in the list.
    expect(find.text('Upcoming Trips'), findsOneWidget);
    expect(find.text('Gold Coast Golf Escape'), findsOneWidget);
    expect(find.text('Past Trips'), findsOneWidget);
    expect(find.text('Tasmania Golf Tour'), findsOneWidget);
    expect(find.text('Queenstown Golf Adventure'), findsOneWidget);
  });

  testWidgets('tapping the hero opens that trip', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Melbourne Golf Weekend'));
    await tester.pumpAndSettle();

    expect(find.text('Details of $melbourneId'), findsOneWidget);
  });

  testWidgets('every trip opens its own details, not just Melbourne', (
    tester,
  ) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Gold Coast Golf Escape'));
    await tester.tap(find.text('Gold Coast Golf Escape'));
    await tester.pumpAndSettle();

    expect(find.text('Details of gold-coast-golf-escape'), findsOneWidget);
  });

  testWidgets('Create Trip opens the create form, not an existing trip', (
    tester,
  ) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Create Trip'));
    await tester.tap(find.text('Create Trip'));
    await tester.pumpAndSettle();

    expect(find.text('Create Trip Form'), findsOneWidget);
  });

  testWidgets('Browse Trips scrolls down to the trip lists', (tester) async {
    await _pump(tester);
    final before = tester.getTopLeft(find.text('Upcoming Trips')).dy;

    await tester.ensureVisible(find.text('Browse Trips'));
    await tester.tap(find.text('Browse Trips'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Upcoming Trips')).dy, lessThan(before));
  });

  testWidgets('a newly created trip appears under Upcoming Trips', (
    tester,
  ) async {
    final container = await _pump(tester);

    container
        .read(tripsProvider.notifier)
        .createTrip(
          NewTripDraft(
            name: 'Barossa Valley Weekend',
            destination: 'Barossa Valley, Australia',
            startDate: DateTime(2027, 3, 12),
            endDate: DateTime(2027, 3, 14),
          ),
        );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Barossa Valley Weekend'));
    expect(find.text('Barossa Valley Weekend'), findsOneWidget);
    expect(find.text('Upcoming Trips'), findsOneWidget);
  });

  testWidgets('shows an empty state instead of a hero with no trips', (
    tester,
  ) async {
    final container = await _pump(tester);

    for (final trip in List<Trip>.of(container.read(tripsProvider).trips)) {
      container.read(tripsProvider.notifier).deleteTrip(trip.id);
    }
    await tester.pumpAndSettle();

    // A welcome, not an empty list.
    expect(find.text('Plan your next golf trip'), findsOneWidget);
    expect(find.text('Plan every day'), findsOneWidget);
    expect(find.text('Split costs fairly'), findsOneWidget);
    expect(find.text('Create your first trip'), findsOneWidget);
    expect(find.text('NEXT TRIP'), findsNothing);
    expect(find.text('Upcoming Trips'), findsNothing);
    expect(find.text('Past Trips'), findsNothing);
  });

  testWidgets('shows the lists in more columns on a desktop-width screen', (
    tester,
  ) async {
    await _pump(tester, width: 1200);

    final tasmania = tester.getTopLeft(find.text('Tasmania Golf Tour'));
    final queenstown = tester.getTopLeft(
      find.text('Queenstown Golf Adventure'),
    );
    expect(queenstown.dy, tasmania.dy);
  });
}
