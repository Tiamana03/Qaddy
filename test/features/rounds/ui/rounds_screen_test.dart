import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/cards/qaddy_round_list_card.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/rounds/ui/screens/rounds_screen.dart';

import '../../../support/app_test_harness.dart';
import '../../../support/fake_course_data.dart';
import '../../../support/sample_off.dart';

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
  List<Override> overrides = const <Override>[],
}) async {
  useScreen(tester, size);
  final container = friendsContainer(overrides: overrides);
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
  group('the course', () {
    testWidgets('shows the course the round is on, and lets it change', (
      tester,
    ) async {
      final container = await _pump(tester, overrides: fakeCourseData());

      expect(find.text('Course'), findsOneWidget);
      expect(find.text('Sample course'), findsOneWidget);

      await _tap(tester, find.text('Change'));
      expect(find.text('Choose your course'), findsOneWidget);
      await tester.tap(find.text('Test Links'));
      await tester.pumpAndSettle();

      expect(find.text('Test Links'), findsWidgets);
      expect(find.text('Testville, TS · 2 holes'), findsOneWidget);

      await _tap(tester, find.text('Start round'));
      final round = container.read(liveRoundProvider)!;
      expect(round.course, 'Test Links');
      expect(round.holes, fakeHoles);
    });

    testWidgets('without a course says what a standard layout is', (
      tester,
    ) async {
      await _pump(tester, overrides: sampleOff());

      expect(find.textContaining('Standard layout'), findsOneWidget);
      await _tap(tester, find.text('Change'));
      expect(find.text('Course search is not connected yet'), findsOneWidget);
    });
  });

  group('before the round', () {
    testWidgets('is an invitation to the first tee', (tester) async {
      await _pump(tester);

      expect(find.text('My rounds'), findsOneWidget);
      expect(
        find.text('Play more. Keep track. Make it count.'),
        findsOneWidget,
      );
      expect(find.text('Upcoming (1)'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Invitations'), findsOneWidget);
      expect(find.byType(QaddyRoundListCard), findsOneWidget);
      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('8:20 AM'), findsOneWidget);
      expect(find.text('Richmond Golf Club'), findsWidgets);
      expect(find.text('Stableford'), findsOneWidget);
      expect(find.text('21°C'), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Sample'), findsOneWidget);
      expect(find.textContaining('1 playing'), findsNothing);
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

    testWidgets('a round starts with just the golfer; mates are added', (
      tester,
    ) async {
      final container = await _pump(tester);
      expect(container.read(selectedPlayersProvider), hasLength(1));

      await _tap(tester, find.text('Tom'));
      expect(container.read(selectedPlayersProvider), hasLength(2));
      expect(find.textContaining('2 players'), findsOneWidget);

      await _tap(tester, find.text('Tom'));
      expect(container.read(selectedPlayersProvider), hasLength(1));
    });

    testWidgets('someone who has not replied can be added', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('Josh'));

      expect(
        container.read(selectedPlayersProvider).map((p) => p.name),
        contains('Josh'),
      );
      expect(find.textContaining('2 players'), findsOneWidget);
    });

    testWidgets('the golfer cannot take themselves out', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('You'));

      expect(container.read(selectedPlayersProvider), hasLength(1));
    });

    testWidgets('shows the side games and their holes', (tester) async {
      await _pump(tester);

      expect(find.text('On the course (sample)'), findsOneWidget);
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
      expect(round.players, hasLength(1));
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
      expect(names, containsAll(<String>['Tom', 'Josh']));
      expect(names, isNot(contains('Ben')));
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

      expect(find.textContaining('Leaderboard · after 1 hole'), findsOneWidget);
      await _tap(tester, find.textContaining('Leaderboard'));
      expect(find.text('Go: /rounds/leaderboard'), findsOneWidget);
    });
  });

  group('the rest of the screen', () {
    testWidgets('Invitations says there are none, kindly', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Invitations'));

      expect(find.text('No invitations yet'), findsOneWidget);
      expect(find.text('Start round'), findsNothing);
    });

    testWidgets('search narrows the rounds by course', (tester) async {
      await _pump(tester);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.textContaining('No rounds match'), findsOneWidget);
      expect(find.text('Start round'), findsNothing);

      await tester.enterText(find.byType(TextField), 'richmond');
      await tester.pumpAndSettle();
      expect(find.text('Start round'), findsOneWidget);
    });

    testWidgets('Create round brings the players into view', (tester) async {
      await _pump(tester, size: const Size(400, 700));

      await _tap(tester, find.text('Create round'));

      expect(find.text("Who's playing"), findsOneWidget);
      final top = tester.getTopLeft(find.text("Who's playing")).dy;
      expect(top, lessThan(700));
    });

    testWidgets('the filter keeps its place, dimmed', (tester) async {
      await _pump(tester);

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });
  });

  group('the Completed tab', () {
    testWidgets('says so, kindly, before a first round', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Completed'));

      expect(find.text('No finished rounds yet'), findsOneWidget);
      expect(find.text('Start round'), findsNothing);
    });

    testWidgets('See upcoming goes back to the next round', (tester) async {
      await _pump(tester);
      await _tap(tester, find.text('Completed'));

      await _tap(tester, find.text('See upcoming'));

      expect(find.text('Start round'), findsOneWidget);
    });

    testWidgets('keeps how the round went, and the older ones too', (
      tester,
    ) async {
      await _pump(
        tester,
        before: (c) {
          for (var i = 0; i < 2; i++) {
            c.read(roundsProvider.notifier)
              ..startRound(
                upcomingRoundInvitees.take(2).map((i) => i.player).toList(),
              )
              ..nextHole()
              ..finishRound();
          }
        },
      );

      await _tap(tester, find.text('Completed (2)'));

      expect(find.byType(QaddyRoundListCard), findsNWidgets(2));
      // Only the latest has a results page to open.
      expect(find.text('View results'), findsOneWidget);
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

      // The finished round is kept under Completed, one tap from the results.
      expect(find.text('Completed (1)'), findsOneWidget);
      expect(find.text('Start round'), findsOneWidget);

      await _tap(tester, find.text('Completed (1)'));
      expect(find.text('Start round'), findsNothing);
      expect(find.text('Richmond Golf Club'), findsOneWidget);

      await _tap(tester, find.text('View results'));

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
