import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/screens/rounds_screen.dart';

import '../../../support/app_test_harness.dart';

List<RouteBase> _routes() => <RouteBase>[
  GoRoute(path: '/rounds', builder: (context, state) => const RoundsScreen()),
  for (final path in <String>[
    '/rounds/scorecard',
    '/rounds/leaderboard',
    '/rounds/complete',
  ])
    GoRoute(path: path, builder: (context, state) => Text('Go: $path')),
];

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Size size = const Size(400, 3200),
  void Function(ProviderContainer container)? before,
}) async {
  useScreen(tester, size);
  final container = friendsContainer();
  before?.call(container);
  final router = GoRouter(initialLocation: '/rounds', routes: _routes());
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

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  group('before the round', () {
    testWidgets('is an invitation to the first tee', (tester) async {
      await _pump(tester);

      expect(find.text('Rounds'), findsOneWidget);
      expect(find.text('FIRST TEE'), findsOneWidget);
      expect(find.text('Saturday, 8:20 AM'), findsOneWidget);
      expect(find.text('Richmond Golf Club'), findsWidgets);
      expect(find.text('21°C Sunny'), findsOneWidget);
      expect(find.text('Stableford'), findsOneWidget);
      expect(find.text('18 holes'), findsOneWidget);
      expect(find.textContaining('7 playing'), findsOneWidget);
    });

    testWidgets('has no disabled or administrative buttons left', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Edit Round'), findsNothing);
      expect(find.text('Cancel Round'), findsNothing);
      expect(find.text('Round Information'), findsNothing);
      for (final button in tester.widgetList<FilledButton>(
        find.byType(FilledButton),
      )) {
        expect(button.onPressed, isNotNull);
      }
    });

    testWidgets('lists who is playing, with the golfer always in', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text("Who's playing"), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('Tom'), findsOneWidget);
      expect(find.text('HCP 8.4'), findsOneWidget);
      expect(find.textContaining('Waiting to reply'), findsOneWidget);
    });

    testWidgets('a friend can be taken out and put back', (tester) async {
      final container = await _pump(tester);
      expect(container.read(selectedPlayersProvider), hasLength(7));

      await _tap(tester, find.text('Tom'));
      expect(container.read(selectedPlayersProvider), hasLength(6));
      expect(find.textContaining('6 playing'), findsOneWidget);

      await _tap(tester, find.text('Tom'));
      expect(container.read(selectedPlayersProvider), hasLength(7));
    });

    testWidgets('someone who has not replied can be added', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('Josh'));

      expect(
        container.read(selectedPlayersProvider).map((p) => p.name),
        contains('Josh'),
      );
      expect(find.textContaining('8 playing'), findsOneWidget);
    });

    testWidgets('the golfer cannot take themselves out', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('You'));

      expect(container.read(selectedPlayersProvider), hasLength(7));
    });

    testWidgets('shows the side games and their holes', (tester) async {
      await _pump(tester);

      expect(find.text('On the course'), findsOneWidget);
      for (final game in upcomingRoundSideGames) {
        expect(find.text(game.name), findsOneWidget);
        expect(find.text('Hole ${game.hole}'), findsOneWidget);
      }
    });

    testWidgets('Start round begins the round and opens the scorecard', (
      tester,
    ) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('Start round'));

      final round = container.read(liveRoundProvider)!;
      expect(round.players, hasLength(7));
      expect(round.players.first.name, upcomingRoundInvitees.first.player.name);
      expect(find.text('Go: /rounds/scorecard'), findsOneWidget);
    });

    testWidgets('the round starts with whoever was picked', (tester) async {
      final container = await _pump(tester);
      await _tap(tester, find.text('Tom'));
      await _tap(tester, find.text('Josh'));

      await _tap(tester, find.text('Start round'));

      final names = container
          .read(liveRoundProvider)!
          .players
          .map((p) => p.name);
      expect(names, isNot(contains('Tom')));
      expect(names, contains('Josh'));
    });
  });

  group('during the round', () {
    void startRound(ProviderContainer c) {
      c
          .read(roundsProvider.notifier)
          .startRound(
            upcomingRoundInvitees.take(3).map((i) => i.player).toList(),
          );
    }

    testWidgets('says the round is under way and offers to continue', (
      tester,
    ) async {
      await _pump(tester, before: startRound);

      expect(find.text('ROUND IN PROGRESS'), findsOneWidget);
      expect(find.text('Hole 1 of 18'), findsOneWidget);
      expect(find.text('Continue round'), findsOneWidget);
      expect(find.text('Start round'), findsNothing);
      expect(find.text("Who's playing"), findsNothing);
    });

    testWidgets('Continue round returns to the scorecard', (tester) async {
      await _pump(tester, before: startRound);

      await _tap(tester, find.text('Continue round'));

      expect(find.text('Go: /rounds/scorecard'), findsOneWidget);
    });

    testWidgets('shows where the golfer stands once a hole is played', (
      tester,
    ) async {
      await _pump(
        tester,
        before: (c) {
          startRound(c);
          c.read(roundsProvider.notifier).nextHole();
        },
      );

      expect(find.textContaining('LEADERBOARD · AFTER 1 HOLE'), findsOneWidget);
      await _tap(tester, find.textContaining('LEADERBOARD'));
      expect(find.text('Go: /rounds/leaderboard'), findsOneWidget);
    });
  });

  group('after the round', () {
    testWidgets('keeps the result one tap from the celebration', (
      tester,
    ) async {
      await _pump(
        tester,
        before: (c) {
          c.read(roundsProvider.notifier)
            ..startRound(
              upcomingRoundInvitees.take(3).map((i) => i.player).toList(),
            )
            ..nextHole()
            ..finishRound();
        },
      );

      expect(find.text('LAST ROUND'), findsOneWidget);
      expect(find.text('Start round'), findsOneWidget);

      await _tap(tester, find.text('LAST ROUND'));

      expect(find.text('Go: /rounds/complete'), findsOneWidget);
    });
  });

  group('lays out everywhere', () {
    for (final width in <double>[320, 400, 820, 1280]) {
      for (final (name, theme) in <(String, ThemeData)>[
        ('dark', QaddyTheme.dark),
        ('light', QaddyTheme.light),
      ]) {
        testWidgets('at $width px in $name mode', (tester) async {
          useScreen(tester, Size(width, 3400));
          final container = friendsContainer();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(theme: theme, home: const RoundsScreen()),
            ),
          );
          await tester.pump(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('settles without animating forever', (tester) async {
      await _pump(tester);

      await tester.pumpAndSettle();
    });
  });
}
