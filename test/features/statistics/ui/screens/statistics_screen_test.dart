import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/models/round_player.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/ui/screens/statistics_screen.dart';
import 'package:qaddy/features/statistics/ui/widgets/form_chart.dart';

import '../../../../support/app_test_harness.dart';

/// The golfer and Tom: the two we always play with.
final _pair = <String>[currentUserName, 'Tom'];

class _Harness {
  _Harness() {
    container = friendsContainer(
      overrides: <Override>[roundsClockProvider.overrideWithValue(() => _now)],
    );
  }

  late final ProviderContainer container;
  DateTime _now = DateTime(2026, 10, 1, 8);

  /// Plays a round with Tom on [day] (October), the golfer scoring [golfer]
  /// strokes on the first holes and Tom carding par. Then finishes it.
  void play(int day, List<int> golfer) {
    _now = DateTime(2026, 10, day, 8);
    final store = container.read(roundsProvider.notifier)
      ..startRound(<RoundPlayer>[
        for (final invitee in upcomingRoundInvitees)
          if (_pair.contains(invitee.player.name)) invitee.player,
      ]);
    for (final strokes in golfer) {
      store
        ..setScore(currentUserName, strokes)
        ..nextHole();
    }
    store.finishRound();
  }
}

List<RouteBase> _routes() => <RouteBase>[
  GoRoute(
    path: '/profile/statistics',
    builder: (context, state) => const StatisticsScreen(),
  ),
  GoRoute(
    path: '/rounds',
    builder: (context, state) => const Text('Go: /rounds'),
    routes: <RouteBase>[
      GoRoute(
        path: 'complete',
        builder: (context, state) => const Text('Go: /rounds/complete'),
      ),
    ],
  ),
];

Future<void> _pump(
  WidgetTester tester,
  _Harness h, {
  Size size = const Size(400, 4200),
}) async {
  useScreen(tester, size);
  final router = GoRouter(
    initialLocation: '/profile/statistics',
    routes: _routes(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: h.container,
      child: MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Par-4, 5, 3, 4, 4, 5 on the first six holes.
const List<int> _pars = <int>[4, 5, 3, 4, 4, 5];

void main() {
  group('before any round', () {
    testWidgets('invites the golfer to play one', (tester) async {
      await _pump(tester, _Harness());

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Your story starts on the first tee'), findsOneWidget);
      expect(find.text('Your form'), findsNothing);
      // No made-up numbers.
      expect(find.text('68'), findsNothing);
      expect(find.text('Career Totals'), findsNothing);
    });

    testWidgets('the button starts a round', (tester) async {
      await _pump(tester, _Harness());

      await tester.tap(find.text('Start a round'));
      await tester.pumpAndSettle();

      expect(find.text('Go: /rounds'), findsOneWidget);
    });
  });

  group('after one round', () {
    late _Harness h;
    setUp(() {
      h = _Harness()..play(1, <int>[3, 5, 3, 4]); // birdie then pars
    });

    testWidgets('tells the story of the round just played', (tester) async {
      await _pump(tester, h);

      expect(find.text('YOUR GAME'), findsOneWidget);
      expect(find.text('Stableford points\na round'), findsOneWidget);
      expect(find.text('1 round'), findsWidgets);
      expect(find.text('Handicap 8.4'), findsOneWidget);
      expect(find.textContaining('3 more rounds'), findsOneWidget);
    });

    testWidgets('shows how the holes broke down', (tester) async {
      await _pump(tester, h);

      expect(find.text('How you score'), findsOneWidget);
      expect(find.text('Par or better on 100% of holes'), findsOneWidget);
      expect(find.text('Across 4 holes'), findsOneWidget);
      expect(find.text('Birdie 1'), findsOneWidget);
      expect(find.text('Par 3'), findsOneWidget);
    });

    testWidgets('has a form chart even with one round', (tester) async {
      await _pump(tester, h);

      expect(find.byType(FormChart), findsOneWidget);
      expect(find.text('Points in your round'), findsOneWidget);
    });

    testWidgets('names the favourite and the nemesis from four holes', (
      tester,
    ) async {
      await _pump(tester, h);

      expect(find.text('YOUR FAVOURITE'), findsOneWidget);
      expect(find.text('YOUR NEMESIS'), findsOneWidget);
      expect(find.text('Hole 1'), findsOneWidget);
    });

    testWidgets('lists the playing partner head to head', (tester) async {
      await _pump(tester, h);

      expect(find.text('Head to head'), findsOneWidget);
      expect(find.text('Tom'), findsOneWidget);
      expect(find.text('1 round together'), findsOneWidget);
      expect(find.text('1 – 0'), findsOneWidget);
      expect(find.text('You lead'), findsOneWidget);
    });

    testWidgets('lists the highlights', (tester) async {
      await _pump(tester, h);

      expect(find.textContaining('Best round: '), findsOneWidget);
      expect(find.text('Most birdies in a round: 1'), findsOneWidget);
      expect(find.text('4 holes played'), findsOneWidget);
    });

    testWidgets('can open the last round', (tester) async {
      await _pump(tester, h);

      await tester.ensureVisible(find.text('See your last round'));
      await tester.tap(find.text('See your last round'));
      await tester.pumpAndSettle();

      expect(find.text('Go: /rounds/complete'), findsOneWidget);
    });
  });

  group('after a season of rounds', () {
    testWidgets('shows form, a win rate and a rising trend', (tester) async {
      final h = _Harness();
      // Three poor rounds (Tom wins), then three better ones (the golfer wins).
      for (var day = 1; day <= 3; day++) {
        h.play(day, <int>[5, 6, 4, 5, 5, 6]); // bogeys: Tom wins
      }
      for (var day = 4; day <= 6; day++) {
        h.play(day, <int>[3, 4, 2, 3, 3, 4]);
      }
      await _pump(tester, h);

      expect(find.text('6 rounds'), findsWidgets);
      expect(find.textContaining('On the up'), findsOneWidget);
      expect(find.text('Points over your last 6 rounds'), findsOneWidget);
      expect(find.text('3 wins · 50%'), findsOneWidget);
      expect(find.text('Longest win streak: 3 rounds'), findsOneWidget);
    });

    testWidgets('only charts the last eight rounds', (tester) async {
      final h = _Harness();
      for (var day = 1; day <= 10; day++) {
        h.play(day, _pars);
      }
      await _pump(tester, h);

      expect(find.text('Points over your last 8 rounds'), findsOneWidget);
    });
  });

  group('lays out everywhere', () {
    for (final width in <double>[320, 400, 820, 1280]) {
      for (final (name, theme) in <(String, ThemeData)>[
        ('dark', QaddyTheme.dark),
        ('light', QaddyTheme.light),
      ]) {
        testWidgets('at $width px in $name mode', (tester) async {
          final h = _Harness();
          for (var day = 1; day <= 9; day++) {
            h.play(day, <int>[3, 4, 2, 5, 6, 0].take(day % 5 + 2).toList());
          }
          useScreen(tester, Size(width, 5200));
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: h.container,
              child: MaterialApp(theme: theme, home: const StatisticsScreen()),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('settles without animating forever', (tester) async {
      final h = _Harness()..play(1, <int>[3, 5]);
      await _pump(tester, h);

      await tester.pumpAndSettle();
    });
  });
}
