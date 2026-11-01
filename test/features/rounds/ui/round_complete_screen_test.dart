import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/motion/qaddy_confetti.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/screens/round_complete_screen.dart';

import '../../../support/app_test_harness.dart';

/// Plays three holes for the golfer (a birdie, a par, a bogey) against Tom and
/// Ben, who card par every hole, then finishes.
void _playThreeHoles(RoundsController store) {
  store
    ..startRound(upcomingRoundInvitees.take(3).map((i) => i.player).toList())
    ..nudgeScore(upcomingRoundInvitees.first.player.name, -1)
    ..nextHole()
    ..nextHole()
    ..nudgeScore(upcomingRoundInvitees.first.player.name, 1)
    ..nextHole()
    ..finishRound();
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  void Function(RoundsController store)? play = _playThreeHoles,
  Size size = const Size(400, 2600),
  ThemeData? theme,
}) async {
  useScreen(tester, size);
  final container = friendsContainer();
  if (play != null) {
    play(container.read(roundsProvider.notifier));
  }
  final router = GoRouter(
    initialLocation: '/rounds/complete',
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (context, state) => const Text('Go: /home'),
      ),
      GoRoute(
        path: '/rounds',
        builder: (context, state) => const Text('Go: /rounds'),
        routes: <RouteBase>[
          GoRoute(
            path: 'complete',
            builder: (context, state) => const RoundCompleteScreen(),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: theme ?? QaddyTheme.dark,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
  return container;
}

void main() {
  testWidgets('crowns the winner', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('ROUND COMPLETE'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsWidgets);
    // Birdie, par, bogey = 3 + 2 + 1 points; Tom and Ben get 2 each hole
    // (Ben has a shot on SI 11 hole 1, so 3).
    expect(find.text('You win!'), findsNothing);
    expect(find.textContaining('wins'), findsWidgets);
    expect(find.textContaining('points'), findsWidgets);
  });

  testWidgets("shows the golfer's own round", (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('YOUR ROUND'), findsOneWidget);
    expect(find.text('Birdies or better'), findsOneWidget);
    expect(find.text('Pars'), findsOneWidget);
    expect(find.text('Bogeys or worse'), findsOneWidget);
    expect(find.text('Front nine pts'), findsOneWidget);
    expect(find.text('Back nine pts'), findsOneWidget);
    expect(find.textContaining('Best hole'), findsOneWidget);
  });

  testWidgets('lists the final standings', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('Final standings'), findsOneWidget);
    expect(find.text('Tom'), findsWidgets);
    expect(find.text('Ben'), findsWidgets);
  });

  testWidgets('shares the result', (tester) async {
    final container = await _pump(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Share the result'));
    await tester.tap(find.text('Share the result'));
    await tester.pumpAndSettle();

    final shared = shareOf(container).shared;
    expect(shared, hasLength(1));
    expect(shared.single, contains('at Richmond Golf Club!'));
    expect(shared.single, endsWith('Played with Qaddy.'));
  });

  testWidgets('Back to Home and the close button go home', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Back to Home'));
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Go: /home'), findsOneWidget);
  });

  testWidgets('the close button goes home', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Go: /home'), findsOneWidget);
  });

  testWidgets('confetti falls once and then stops', (tester) async {
    await _pump(tester);

    expect(find.byType(QaddyConfetti), findsOneWidget);
    // pumpAndSettle fails if anything keeps animating.
    await tester.pumpAndSettle();
  });

  testWidgets('reduce motion turns the confetti off', (tester) async {
    useScreen(tester, const Size(400, 2600));
    final container = friendsContainer();
    _playThreeHoles(container.read(roundsProvider.notifier));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: QaddyTheme.dark,
            home: const RoundCompleteScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('last place gets a good-natured wooden spoon', (tester) async {
    await _pump(
      tester,
      play: (store) {
        final names = upcomingRoundInvitees.take(3).map((i) => i.player.name);
        store
          ..startRound(
            upcomingRoundInvitees.take(3).map((i) => i.player).toList(),
          )
          ..setScore(names.first, 2)
          ..setScore(names.last, 7)
          ..nextHole()
          ..finishRound();
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Wooden spoon'), findsOneWidget);
  });

  testWidgets('no wooden spoon in a twosome, or when last place is level', (
    tester,
  ) async {
    await _pump(
      tester,
      play: (store) => store
        ..startRound(
          upcomingRoundInvitees.take(2).map((i) => i.player).toList(),
        )
        ..setScore(upcomingRoundInvitees.first.player.name, 2)
        ..nextHole()
        ..finishRound(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wooden spoon'), findsNothing);
  });

  testWidgets('your points count up to the final figure', (tester) async {
    await _pump(
      tester,
      play: (store) => store
        ..startRound(
          upcomingRoundInvitees.take(3).map((i) => i.player).toList(),
        )
        ..setScore(upcomingRoundInvitees.first.player.name, 2)
        ..nextHole()
        ..finishRound(),
    );
    // The figure is still counting up shortly after arrival, and settles.
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('4'), findsWidgets);
  });

  testWidgets('with no finished round, says so', (tester) async {
    await _pump(tester, play: null);

    expect(find.text('No finished round yet'), findsOneWidget);
    await tester.tap(find.text('Go to Rounds'));
    await tester.pumpAndSettle();
    expect(find.text('Go: /rounds'), findsOneWidget);
  });

  for (final width in <double>[320, 400, 820, 1280]) {
    for (final (name, theme) in <(String, ThemeData)>[
      ('dark', QaddyTheme.dark),
      ('light', QaddyTheme.light),
    ]) {
      testWidgets('lays out at $width px in $name mode', (tester) async {
        await _pump(tester, size: Size(width, 3000), theme: theme);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
