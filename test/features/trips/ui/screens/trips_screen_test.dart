// Verifies the Trips screen: the next trip leads as a countdown hero, then a
// compact summary, quick actions and the remaining upcoming and past trips,
// plus that Melbourne Golf Weekend (the shared placeholder trip) is the only
// one that opens Trip Details. A fixed `now` keeps the countdown independent
// of today's date.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/ui/screens/trips_screen.dart';

final DateTime _now = DateTime(2026, 10, 26);

Future<void> _pumpWithRouter(
  WidgetTester tester, {
  List<Trip>? upcoming,
  List<Trip>? past,
  double width = 400,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 900);

  final router = GoRouter(
    initialLocation: '/trips',
    routes: <RouteBase>[
      GoRoute(
        path: '/trips',
        builder: (context, state) =>
            TripsScreen(upcoming: upcoming, past: past, now: _now),
        routes: <RouteBase>[
          GoRoute(
            path: 'details',
            builder: (context, state) => const Text('Trip Details'),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('leads with the next trip, then summary, actions and lists', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

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
    expect(find.text('2'), findsNWidgets(3));
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Browse Trips'), findsOneWidget);

    // The rest of the upcoming trips, then the past ones — the featured trip
    // is not repeated in the list.
    expect(find.text('Coming Up'), findsOneWidget);
    expect(find.text('Gold Coast Golf Escape'), findsOneWidget);
    expect(find.text('Past Trips'), findsOneWidget);
    expect(find.text('Tasmania Golf Tour'), findsOneWidget);
    expect(find.text('Queenstown Golf Adventure'), findsOneWidget);
  });

  testWidgets('tapping the hero opens Trip Details', (tester) async {
    await _pumpWithRouter(tester);

    await tester.tap(find.text('Melbourne Golf Weekend'));
    await tester.pumpAndSettle();

    expect(find.text('Trip Details'), findsOneWidget);
  });

  testWidgets('trips without detail data are not tappable', (tester) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Gold Coast Golf Escape'));
    await tester.tap(find.text('Gold Coast Golf Escape'));
    await tester.pumpAndSettle();

    expect(find.text('Trip Details'), findsNothing);
    expect(find.text('Gold Coast Golf Escape'), findsOneWidget);
  });

  testWidgets('Create Trip opens Trip Details', (tester) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Create Trip'));
    await tester.tap(find.text('Create Trip'));
    await tester.pumpAndSettle();

    expect(find.text('Trip Details'), findsOneWidget);
  });

  testWidgets('Browse Trips scrolls down to the trip lists', (tester) async {
    await _pumpWithRouter(tester);
    final before = tester.getTopLeft(find.text('Coming Up')).dy;

    await tester.ensureVisible(find.text('Browse Trips'));
    await tester.tap(find.text('Browse Trips'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Coming Up')).dy, lessThan(before));
  });

  testWidgets('shows an empty state instead of a hero with no trips', (
    tester,
  ) async {
    await _pumpWithRouter(tester, upcoming: <Trip>[], past: <Trip>[]);

    expect(find.text('No trips planned yet'), findsOneWidget);
    expect(find.text('NEXT TRIP'), findsNothing);
    expect(find.text('Coming Up'), findsNothing);
    expect(find.text('Past Trips'), findsNothing);
    expect(find.text('Create Trip'), findsOneWidget);
  });

  testWidgets('shows the lists in more columns on a desktop-width screen', (
    tester,
  ) async {
    await _pumpWithRouter(tester, width: 1200);

    final tasmania = tester.getTopLeft(find.text('Tasmania Golf Tour'));
    final queenstown = tester.getTopLeft(
      find.text('Queenstown Golf Adventure'),
    );
    expect(queenstown.dy, tasmania.dy);
  });
}
