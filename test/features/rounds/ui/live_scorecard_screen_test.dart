import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/motion/qaddy_confetti.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/screens/live_scorecard_screen.dart';

import '../../../support/app_test_harness.dart';

List<RouteBase> _routes() => <RouteBase>[
  GoRoute(
    path: '/rounds',
    builder: (context, state) => const Text('Go: /rounds'),
    routes: <RouteBase>[
      GoRoute(
        path: 'scorecard',
        builder: (context, state) => const LiveScorecardScreen(),
      ),
      GoRoute(
        path: 'leaderboard',
        builder: (context, state) => const Text('Go: /rounds/leaderboard'),
      ),
      GoRoute(
        path: 'complete',
        builder: (context, state) => const Text('Go: /rounds/complete'),
      ),
    ],
  ),
];

/// Opens the scorecard on top of a stub Rounds page, so there is somewhere to
/// go back to. Three players: the golfer, Tom and Ben.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool start = true,
  Size size = const Size(400, 1400),
}) async {
  useScreen(tester, size);
  final container = friendsContainer();
  if (start) {
    container
        .read(roundsProvider.notifier)
        .startRound(
          upcomingRoundInvitees.take(3).map((i) => i.player).toList(),
        );
  }
  final router = GoRouter(initialLocation: '/rounds', routes: _routes());
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(router.push<void>('/rounds/scorecard'));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  group('the hole', () {
    testWidgets('shows the course, the hole, par and the strip of holes', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Richmond Golf Club'), findsOneWidget);
      expect(find.text('Live scoring'), findsOneWidget);
      expect(find.text('Hole 1'), findsOneWidget);
      expect(find.text('Par 4'), findsOneWidget);
      expect(find.text('352 m'), findsWidgets);
      expect(find.text('SI 11'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Front nine')), findsOneWidget);
      expect(find.text('Enter scores'), findsOneWidget);
      expect(find.bySemanticsLabel('Hole 5, not played yet'), findsOneWidget);
      expect(find.bySemanticsLabel('Hole 1, current hole'), findsOneWidget);
    });

    testWidgets('a side game is flagged on its hole', (tester) async {
      final container = await _pump(tester);
      container.read(roundsProvider.notifier).goToHole(4);
      await tester.pumpAndSettle();

      expect(find.text('Longest Drive on this hole'), findsOneWidget);
    });

    testWidgets('the strip jumps to any hole', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.bySemanticsLabel('Hole 6, not played yet'));

      expect(container.read(liveRoundProvider)!.currentHole, 5);
      expect(find.text('Hole 6'), findsOneWidget);
    });
  });

  group('scoring', () {
    testWidgets('everyone starts on par, you first', (tester) async {
      await _pump(tester);

      expect(find.text('You'), findsOneWidget);
      expect(find.text('Tom'), findsOneWidget);
      expect(find.text('Ben'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(', Par, ')), findsNWidgets(3));
      expect(
        tester.getTopLeft(find.text('You')).dy,
        lessThan(tester.getTopLeft(find.text('Tom')).dy),
      );
    });

    testWidgets('the plus and minus move a score and name it', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.byTooltip('Take a stroke off Tom'));
      expect(find.bySemanticsLabel(RegExp('^Tom: 3, Birdie')), findsOneWidget);
      expect(container.read(liveRoundProvider)!.grossAt('Tom', 0), 3);

      await _tap(tester, find.byTooltip('Add a stroke for Ben'));
      await _tap(tester, find.byTooltip('Add a stroke for Ben'));
      expect(
        find.bySemanticsLabel(RegExp('^Ben: 6, Double bogey')),
        findsOneWidget,
      );
      expect(container.read(liveRoundProvider)!.grossAt('Ben', 0), 6);
    });

    testWidgets('shows the points a score earns and the shots received', (
      tester,
    ) async {
      await _pump(tester);

      // Stroke index 11: Ben (off 12) gets a shot here, the others do not.
      expect(find.bySemanticsLabel('Tom: 4, Par, 2 points'), findsOneWidget);
      expect(find.bySemanticsLabel('Ben: 4, Par, 3 points'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(find.bySemanticsLabel('1 shot given'), findsOneWidget);

      await _tap(tester, find.byTooltip('Take a stroke off Tom'));
      expect(find.bySemanticsLabel('Tom: 3, Birdie, 3 points'), findsOneWidget);
    });

    testWidgets('a hole can be picked up', (tester) async {
      final container = await _pump(tester);

      for (var i = 0; i < 4; i++) {
        await _tap(tester, find.byTooltip('Take a stroke off Ben'));
      }

      expect(container.read(liveRoundProvider)!.grossAt('Ben', 0), 0);
      expect(
        find.bySemanticsLabel(RegExp('^Ben: picked up, Picked up')),
        findsOneWidget,
      );
      // The dash is in Ben's stepper (the hole view has a few of its own).
      expect(find.text('–'), findsWidgets);
      // Nothing further to take off, but a stroke can be put back.
      final minus = find.ancestor(
        of: find.byTooltip('Take a stroke off Ben'),
        matching: find.byType(IconButton),
      );
      expect(tester.widget<IconButton>(minus).onPressed, isNull);
    });
  });

  group('moving round the course', () {
    testWidgets('Next hole scores par for anyone not touched', (tester) async {
      final container = await _pump(tester);
      await _tap(tester, find.byTooltip('Take a stroke off Tom'));

      await _tap(tester, find.text('Next hole'));

      final round = container.read(liveRoundProvider)!;
      expect(round.currentHole, 1);
      expect(round.grossAt('Tom', 0), 3);
      expect(round.grossAt('Ben', 0), 4);
      expect(find.text('Hole 2'), findsOneWidget);
      expect(find.textContaining('Par 5'), findsOneWidget);
      expect(find.textContaining('Leaderboard · after 1 hole'), findsOneWidget);
    });

    testWidgets('the arrow goes back a hole, and not before the first', (
      tester,
    ) async {
      await _pump(tester);
      final back = find.ancestor(
        of: find.text('Previous'),
        matching: find.byType(InkWell),
      );
      expect(tester.widget<InkWell>(back.first).onTap, isNull);

      await _tap(tester, find.text('Next hole'));
      await _tap(tester, find.byTooltip('Previous hole'));

      expect(find.text('Hole 1'), findsOneWidget);
    });

    testWidgets('the last hole offers to finish instead', (tester) async {
      final container = await _pump(tester);
      container.read(roundsProvider.notifier).goToHole(17);
      await tester.pumpAndSettle();

      expect(find.text('Next hole'), findsNothing);
      expect(find.text('Finish round'), findsOneWidget);
      expect(find.text('Hole 18'), findsOneWidget);
    });

    testWidgets('Finish round files the round and opens the results', (
      tester,
    ) async {
      final container = await _pump(tester);
      container.read(roundsProvider.notifier).goToHole(17);
      await tester.pumpAndSettle();

      await _tap(tester, find.text('Finish round'));

      expect(container.read(liveRoundProvider), isNull);
      expect(container.read(completedRoundProvider), isNotNull);
      expect(find.text('Go: /rounds/complete'), findsOneWidget);
    });
  });

  group('the corner', () {
    testWidgets('the leaderboard icon opens the leaderboard', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byTooltip('Leaderboard'));

      expect(find.text('Go: /rounds/leaderboard'), findsOneWidget);
    });

    testWidgets('Finish round now asks first, then shows the results', (
      tester,
    ) async {
      final container = await _pump(tester);
      await _tap(tester, find.text('Next hole'));

      await _tap(tester, find.byTooltip('Round options'));
      await _tap(tester, find.text('Finish round now'));
      expect(find.text('Finish the round?'), findsOneWidget);
      expect(find.textContaining('Only the 1 hole everyone'), findsOneWidget);

      await _tap(tester, find.text('Finish round').last);

      expect(container.read(completedRoundProvider)!.holesPlayed, 1);
      expect(find.text('Go: /rounds/complete'), findsOneWidget);
    });

    testWidgets('finishing before any hole is played does not finish', (
      tester,
    ) async {
      final container = await _pump(tester);

      await _tap(tester, find.byTooltip('Round options'));
      await _tap(tester, find.text('Finish round now'));
      expect(find.textContaining('Nothing has been scored'), findsOneWidget);
      await _tap(tester, find.text('Finish round').last);

      expect(container.read(liveRoundProvider), isNotNull);
    });

    testWidgets('Discard asks first, then goes back', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.byTooltip('Round options'));
      await _tap(tester, find.text('Discard round'));
      expect(find.text('Discard this round?'), findsOneWidget);
      await _tap(tester, find.text('Cancel'));
      expect(container.read(liveRoundProvider), isNotNull);

      await _tap(tester, find.byTooltip('Round options'));
      await _tap(tester, find.text('Discard round'));
      await _tap(tester, find.text('Discard'));

      expect(container.read(liveRoundProvider), isNull);
      expect(find.text('Go: /rounds'), findsOneWidget);
    });
  });

  group('golf moments', () {
    testWidgets('the first tee wishes the golfer well, once', (tester) async {
      await _pump(tester);

      expect(find.textContaining('Enjoy it out there'), findsOneWidget);

      await _tap(tester, find.text('Next hole'));

      expect(find.textContaining('Enjoy it out there'), findsNothing);
    });

    testWidgets('Next hole says who took the hole', (tester) async {
      await _pump(tester);
      await _tap(tester, find.byTooltip('Take a stroke off Tom'));
      await _tap(tester, find.byTooltip('Take a stroke off Tom'));

      await _tap(tester, find.text('Next hole'));

      expect(find.text('Tom wins the hole with an eagle'), findsOneWidget);
    });

    testWidgets('says nothing when the hole is a dead heat', (tester) async {
      await _pump(tester);
      // Ben is given a shot here, so a bogey from him is a net par: all level.
      await _tap(tester, find.byTooltip('Add a stroke for Ben'));

      await _tap(tester, find.text('Next hole'));

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a shot can win the hole: a net birdie', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Next hole'));

      expect(find.text('Ben wins the hole with a net birdie'), findsOneWidget);
    });

    testWidgets('tapping a score offers it in golf words', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.bySemanticsLabel(RegExp('^Tom: 4')));

      expect(find.text('Hole 1 · Par 4'), findsOneWidget);
      for (final word in <String>[
        'Eagle',
        'Birdie',
        'Bogey',
        'Double bogey',
        'Picked up',
      ]) {
        expect(find.text(word), findsWidgets, reason: word);
      }

      await _tap(tester, find.text('Birdie').last);

      expect(container.read(liveRoundProvider)!.grossAt('Tom', 0), 3);
    });

    testWidgets('picking up from the picker records no score', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.bySemanticsLabel(RegExp('^Ben: 4')));
      await _tap(tester, find.text('Picked up').last);

      expect(container.read(liveRoundProvider)!.grossAt('Ben', 0), 0);
    });

    testWidgets('an eagle earns confetti, a birdie does not', (tester) async {
      await _pump(tester);
      expect(find.byType(QaddyConfetti), findsNothing);

      await _tap(tester, find.byTooltip('Take a stroke off Tom'));
      expect(find.byType(QaddyConfetti), findsNothing);

      await _tap(tester, find.byTooltip('Take a stroke off Tom'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(QaddyConfetti), findsOneWidget);

      // The burst ends on its own.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('with no round', () {
    testWidgets('says so and points back to Rounds', (tester) async {
      await _pump(tester, start: false);

      expect(find.text('No round in progress'), findsOneWidget);

      await _tap(tester, find.text('Go to Rounds'));

      expect(find.text('Go: /rounds'), findsOneWidget);
    });
  });

  group('lays out everywhere', () {
    for (final width in <double>[320, 400, 820, 1280]) {
      for (final (name, theme) in <(String, ThemeData)>[
        ('dark', QaddyTheme.dark),
        ('light', QaddyTheme.light),
      ]) {
        testWidgets('at $width px in $name mode with eight players', (
          tester,
        ) async {
          useScreen(tester, Size(width, 2400));
          final container = friendsContainer();
          container
              .read(roundsProvider.notifier)
              .startRound(upcomingRoundInvitees.map((i) => i.player).toList());
          container.read(roundsProvider.notifier).nextHole();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: theme,
                home: const LiveScorecardScreen(),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('scoring a whole round settles and never overflows', (
      tester,
    ) async {
      useScreen(tester, const Size(320, 700));
      final container = friendsContainer();
      container
          .read(roundsProvider.notifier)
          .startRound(upcomingRoundInvitees.map((i) => i.player).toList());
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: QaddyTheme.dark,
            home: const LiveScorecardScreen(),
          ),
        ),
      );

      final store = container.read(roundsProvider.notifier);
      for (var hole = 0; hole < 17; hole++) {
        store
          ..nudgeScore('Tom', hole.isEven ? -1 : 1)
          ..nextHole();
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
