// Verifies Sprint 2.5's Round Complete screen: winner(s), summary, final
// leaderboard, and that the two actions navigate to the existing /home and
// /rounds routes rather than doing nothing or inventing a new route.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/ui/screens/round_complete_screen.dart';

Future<void> _pumpWithRouter(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/round-complete',
    routes: <RouteBase>[
      GoRoute(
        path: '/round-complete',
        builder: (context, state) => const RoundCompleteScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Text('Home')),
      GoRoute(
        path: '/rounds',
        builder: (context, state) => const Text('Rounds'),
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
  );
}

void main() {
  testWidgets(
    'uses QaddyScaffold and shows the tied winners, summary and leaderboard',
    (tester) async {
      await _pumpWithRouter(tester);

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Round Complete'), findsOneWidget);
      expect(find.text('Winners'), findsOneWidget);
      expect(find.text('Round Summary'), findsOneWidget);
      expect(find.text('Richmond Golf Club'), findsWidgets);
      expect(find.text('Final Leaderboard'), findsOneWidget);
      // Tom and Tiamana appear twice each: once in the Winner Card, once in
      // the Final Leaderboard.
      expect(find.text('Tom'), findsNWidgets(2));
      expect(find.text('Tiamana'), findsNWidgets(2));
    },
  );

  testWidgets('Return Home navigates to the existing /home route', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Return Home'));
    await tester.tap(find.text('Return Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Start New Round navigates to the existing /rounds route', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    await tester.ensureVisible(find.text('Start New Round'));
    await tester.tap(find.text('Start New Round'));
    await tester.pumpAndSettle();

    expect(find.text('Rounds'), findsOneWidget);
  });
}
