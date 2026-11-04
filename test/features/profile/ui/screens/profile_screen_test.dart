import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/profile/ui/screens/profile_screen.dart';

import '../../../../support/app_test_harness.dart';
import '../../../../support/played_rounds.dart';

const List<String> _destinations = <String>[
  '/rounds',
  '/friends',
  '/friends/groups',
  '/trips',
  '/profile/statistics',
  '/profile/bag',
  '/profile/settings',
];

List<RouteBase> _routes() => <RouteBase>[
  GoRoute(
    path: '/profile',
    builder: (context, state) => const ProfileScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: 'statistics',
        builder: (context, state) => const Text('Go: /profile/statistics'),
      ),
      GoRoute(
        path: 'bag',
        builder: (context, state) => const Text('Go: /profile/bag'),
      ),
      GoRoute(
        path: 'settings',
        builder: (context, state) => const Text('Go: /profile/settings'),
      ),
    ],
  ),
  for (final path in _destinations.where((p) => !p.startsWith('/profile')))
    GoRoute(path: path, builder: (context, state) => Text('Go: $path')),
];

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer container, {
  Size size = const Size(400, 3200),
}) async {
  useScreen(tester, size);
  final router = GoRouter(initialLocation: '/profile', routes: _routes());
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  group('a golfer who has not played yet', () {
    testWidgets('sees a player card and an invitation, not made-up numbers', (
      tester,
    ) async {
      await _pump(tester, PlayedRounds().container);

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Player card'), findsOneWidget);
      expect(find.text('Tiamana'), findsOneWidget);
      expect(find.text('Handicap 8.4'), findsOneWidget);
      expect(find.text('Since 2024'), findsOneWidget);
      expect(find.text('Start your first round'), findsOneWidget);
      // The old placeholder tables are gone.
      expect(find.text('68'), findsNothing);
      expect(find.text('Playing Statistics'), findsNothing);
      expect(find.text('Personal Bests'), findsNothing);
      expect(find.text('Equipment'), findsNothing);
      expect(find.text('Recent rounds'), findsNothing);
    });

    testWidgets('Start your first round goes to Rounds', (tester) async {
      await _pump(tester, PlayedRounds().container);

      await _tap(tester, find.text('Start your first round'));

      expect(find.text('Go: /rounds'), findsOneWidget);
    });

    testWidgets('every achievement is waiting, the first one next', (
      tester,
    ) async {
      await _pump(tester, PlayedRounds().container);

      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Next up'), findsOneWidget);
      expect(find.text('0 of 8 earned'), findsOneWidget);
      // The shelf scrolls, so only the badges in view are built.
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
      expect(find.byIcon(Icons.flag), findsNothing);
    });
  });

  group('after some rounds', () {
    late PlayedRounds h;
    setUp(() {
      h = PlayedRounds()
        ..play(1, <int>[3, 5, 3, 4], partners: <String>['Tom', 'Ben', 'Luke'])
        ..play(2, <int>[5, 6, 4, 5])
        ..play(3, <int>[3, 4, 2, 4]);
    });

    testWidgets('the card shows what the rounds say', (tester) async {
      await _pump(tester, h.container);

      expect(find.text('Rounds'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      expect(find.text('Wins'), findsOneWidget);
      expect(find.text('Avg points'), findsOneWidget);
      expect(find.text('Share my golf card'), findsOneWidget);
      expect(find.text('Start your first round'), findsNothing);
    });

    testWidgets('Share my golf card shares the real numbers', (tester) async {
      await _pump(tester, h.container);

      await _tap(tester, find.text('Share my golf card'));

      final shared = shareOf(h.container).shared;
      expect(shared, hasLength(1));
      expect(shared.single, contains('Tiamana: handicap 8.4'));
      expect(shared.single, contains('3 rounds'));
      expect(shared.single, endsWith('Played with Qaddy.'));
    });

    testWidgets('achievements light up as they are earned', (tester) async {
      await _pump(tester, h.container);

      expect(find.text('First Round'), findsOneWidget);
      expect(find.text('Eagle Eye'), findsOneWidget);
      // First Round, Full Eighteen? no (4 holes), Winner, Social Golfer, ...
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
      expect(find.textContaining(' of 8 earned'), findsOneWidget);
    });

    testWidgets('tapping a badge says how to earn it', (tester) async {
      await _pump(tester, h.container);

      await _tap(tester, find.text('Birdie Hunter'));

      expect(find.text('Make 5 birdies or better'), findsOneWidget);
      expect(find.textContaining(' of 5'), findsWidgets);
    });

    testWidgets('an earned badge says so', (tester) async {
      await _pump(tester, h.container);

      await _tap(tester, find.text('First Round'));

      expect(find.text('Finish your first round'), findsOneWidget);
      expect(find.text('Earned'), findsWidgets);
    });

    testWidgets('lists the playing partners and the recent rounds', (
      tester,
    ) async {
      await _pump(tester, h.container);

      expect(find.text('Your playing partners'), findsOneWidget);
      expect(find.text('Tom'), findsOneWidget);
      expect(find.text('3 rounds'), findsWidgets);
      expect(find.text('Recent rounds'), findsOneWidget);
    });

    testWidgets('your world counts only your own, and says what is sample', (
      tester,
    ) async {
      await _pump(tester, h.container);

      expect(find.text('Your world'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Trips'), findsOneWidget);
      // Nothing here was created by the golfer, so the counts are zero and the
      // sample mates, groups and trips are named as such.
      expect(find.text('+5 sample'), findsOneWidget);
      expect(find.text('+4 sample'), findsNWidgets(2));
    });

    for (final (label, path) in <(String, String)>[
      ('My stats', '/profile/statistics'),
      ('Golf bag', '/profile/bag'),
      ('Settings', '/profile/settings'),
      ('Friends', '/friends'),
      ('Groups', '/friends/groups'),
      ('Trips', '/trips'),
    ]) {
      testWidgets('$label leads to $path', (tester) async {
        await _pump(tester, h.container);

        await _tap(tester, find.text(label));

        expect(find.text('Go: $path'), findsOneWidget);
      });
    }

    testWidgets('the player card and the partners open the statistics', (
      tester,
    ) async {
      await _pump(tester, h.container);

      await _tap(tester, find.text('Your playing partners'));
      // The heading is not a button; tap the partner tile itself.
      await _tap(tester, find.text('Tom'));

      expect(find.text('Go: /profile/statistics'), findsOneWidget);
    });
  });

  group('lays out everywhere', () {
    for (final width in <double>[320, 400, 820, 1280]) {
      for (final (name, theme) in <(String, ThemeData)>[
        ('dark', QaddyTheme.dark),
        ('light', QaddyTheme.light),
      ]) {
        testWidgets('at $width px in $name mode', (tester) async {
          final h = PlayedRounds();
          for (var day = 1; day <= 6; day++) {
            h.play(
              day,
              <int>[3, 4, 2, 5, 6, 0].take(day % 4 + 2).toList(),
              partners: <String>['Tom', 'Ben', 'Luke', 'Nick'],
            );
          }
          useScreen(tester, Size(width, 4200));
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: h.container,
              child: MaterialApp(theme: theme, home: const ProfileScreen()),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('and for a golfer with no rounds', (tester) async {
      useScreen(tester, const Size(320, 4200));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: PlayedRounds().container,
          child: MaterialApp(
            theme: QaddyTheme.dark,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
