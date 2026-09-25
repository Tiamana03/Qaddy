import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/screens/trip_complete_screen.dart';

Future<void> _pumpWithRouter(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/complete',
    routes: <RouteBase>[
      GoRoute(
        path: '/complete',
        builder: (context, state) => const TripCompleteScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Text('Home')),
      GoRoute(path: '/trips', builder: (context, state) => const Text('Trips')),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
  );
}

void main() {
  testWidgets('shows summary, courses played, winners and expenses', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    expect(find.text('Trip Summary'), findsOneWidget);
    expect(find.text('Courses Played'), findsOneWidget);
    expect(find.text('Kingston Heath'), findsOneWidget);
    expect(find.text('Winners'), findsOneWidget);
    expect(find.text('Trip Champion'), findsOneWidget);
    expect(find.text('Tiamana'), findsWidgets);
  });

  testWidgets('Return Home navigates to /home', (tester) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Return Home'));
    await tester.tap(find.text('Return Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Archive Trip navigates to /trips', (tester) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Archive Trip'));
    await tester.tap(find.text('Archive Trip'));
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsOneWidget);
  });
}
