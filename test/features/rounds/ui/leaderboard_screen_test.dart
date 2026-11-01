import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/screens/leaderboard_screen.dart';

import '../../../support/app_test_harness.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  void Function(RoundsController store)? play,
  Size size = const Size(400, 1600),
}) async {
  useScreen(tester, size);
  final container = friendsContainer();
  final store = container.read(roundsProvider.notifier)
    ..startRound(upcomingRoundInvitees.take(3).map((i) => i.player).toList());
  play?.call(store);
  final router = GoRouter(
    initialLocation: '/rounds/leaderboard',
    routes: <RouteBase>[
      GoRoute(
        path: '/rounds',
        builder: (context, state) => const Text('Go: /rounds'),
        routes: <RouteBase>[
          GoRoute(
            path: 'leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('before a hole is played, everyone is level', (tester) async {
    await _pump(tester);

    expect(find.text('All square'), findsOneWidget);
    expect(find.textContaining('WAITING FOR THE FIRST HOLE'), findsOneWidget);
    expect(find.text('Not started'), findsNWidgets(3));
  });

  testWidgets('ranks by Stableford points and names the leader', (
    tester,
  ) async {
    await _pump(
      tester,
      play: (store) {
        store
          ..nudgeScore('Tom', -1) // birdie
          ..nextHole();
      },
    );

    expect(find.text('Tom leads'), findsOneWidget);
    expect(find.textContaining('AFTER 1 HOLE'), findsOneWidget);
    expect(find.text('1 pt behind Ben'), findsOneWidget);
    // Tom first, then the others.
    expect(
      tester.getTopLeft(find.text('Tom')).dy,
      lessThan(tester.getTopLeft(find.text('You')).dy),
    );
  });

  testWidgets('shows how far through and the score against par', (
    tester,
  ) async {
    await _pump(
      tester,
      play: (store) {
        store
          ..nudgeScore('Tom', 1)
          ..nextHole();
      },
    );

    expect(find.textContaining('+1 · 5 strokes'), findsOneWidget);
    expect(find.textContaining('E · 4 strokes'), findsWidgets);
  });

  testWidgets('shows the last round when none is being played', (tester) async {
    await _pump(
      tester,
      play: (store) {
        store
          ..nextHole()
          ..finishRound();
      },
    );

    expect(find.textContaining('FINAL · 1 HOLES'), findsOneWidget);
    expect(find.textContaining('leads'), findsNothing);
    expect(find.textContaining('win'), findsOneWidget);
  });

  testWidgets('with no round at all, says so', (tester) async {
    useScreen(tester, const Size(400, 900));
    final container = friendsContainer();
    final router = GoRouter(
      initialLocation: '/rounds/leaderboard',
      routes: <RouteBase>[
        GoRoute(
          path: '/rounds',
          builder: (context, state) => const Text('Go: /rounds'),
          routes: <RouteBase>[
            GoRoute(
              path: 'leaderboard',
              builder: (context, state) => const LeaderboardScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No round yet'), findsOneWidget);
    await tester.tap(find.text('Go to Rounds'));
    await tester.pumpAndSettle();
    expect(find.text('Go: /rounds'), findsOneWidget);
  });

  for (final width in <double>[320, 400, 820, 1280]) {
    testWidgets('lays out at $width px with eight players', (tester) async {
      useScreen(tester, Size(width, 2600));
      final container = friendsContainer();
      container.read(roundsProvider.notifier)
        ..startRound(upcomingRoundInvitees.map((i) => i.player).toList())
        ..nudgeScore('Tom', -1)
        ..nextHole();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: QaddyTheme.light,
            home: const LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
