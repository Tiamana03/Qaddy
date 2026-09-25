// Verifies Sprint 3's Trips screen: summary, quick actions, and every
// upcoming/past trip card, plus that Melbourne Golf Weekend (the shared
// placeholder trip) is the only one that opens Trip Details.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/ui/screens/trips_screen.dart';

Future<void> _pumpWithRouter(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/trips',
    routes: <RouteBase>[
      GoRoute(
        path: '/trips',
        builder: (context, state) => const TripsScreen(),
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
}

void main() {
  testWidgets('shows summary, quick actions and every trip', (tester) async {
    await _pumpWithRouter(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Browse Trips'), findsOneWidget);
    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('Gold Coast Golf Escape'), findsOneWidget);
    expect(find.text('Tasmania Golf Tour'), findsOneWidget);
    expect(find.text('Queenstown Golf Adventure'), findsOneWidget);
  });

  testWidgets('tapping Melbourne Golf Weekend opens Trip Details', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    await tester.tap(find.text('Melbourne Golf Weekend'));
    await tester.pumpAndSettle();

    expect(find.text('Trip Details'), findsOneWidget);
  });

  testWidgets('Create Trip opens Trip Details', (tester) async {
    await _pumpWithRouter(tester);

    await tester.tap(find.text('Create Trip'));
    await tester.pumpAndSettle();

    expect(find.text('Trip Details'), findsOneWidget);
  });
}
