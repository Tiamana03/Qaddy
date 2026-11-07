import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/actions/qaddy_quick_actions.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:qaddy/features/dashboard/ui/widgets/home_hero.dart';
import 'package:qaddy/features/dashboard/ui/widgets/upcoming_round_card.dart';
import 'package:qaddy/features/dashboard/ui/widgets/your_game_tiles.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

import '../../../support/app_test_harness.dart';

/// A Sunday morning: the round is six days away and the Melbourne trip 27.
final DateTime _sundayMorning = DateTime(2026, 11, 1, 9);

/// A golfer with no trips planned.
class _NoTrips extends TripsController {
  @override
  TripsState build() => const TripsState(trips: [], plans: {});
}

/// Every place the Dashboard can lead, as a stub that says where it went.
const List<String> _destinations = <String>[
  '/home/search',
  '/home/notifications',
  '/rounds',
  '/rounds/scorecard',
  '/rounds/complete',
  '/trips',
  '/trips/create',
  '/trips/melbourne-golf-weekend',
  '/friends',
  '/friends/search',
  '/friends/requests',
  '/friends/groups/saturday-boys',
  '/profile',
  '/profile/statistics',
];

List<RouteBase> _routes() => <RouteBase>[
  GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
  for (final path in _destinations)
    GoRoute(path: path, builder: (context, state) => Text('Go: $path')),
];

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Size size = const Size(400, 3200),
  DateTime? now,
  List<Override> overrides = const [],
}) async {
  final container = await pumpFriendsRouter(
    tester,
    initialLocation: '/home',
    routes: _routes(),
    size: size,
    overrides: <Override>[
      dashboardClockProvider.overrideWithValue(() => now ?? _sundayMorning),
      ...overrides,
    ],
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
  group('the first tee', () {
    testWidgets('uses QaddyScaffold and greets the golfer in the hero', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Good morning,'), findsOneWidget);
      expect(find.text('Tiamana'), findsWidgets);
      expect(find.text('Sunday 1 November'), findsOneWidget);
    });

    testWidgets('says good evening in the evening', (tester) async {
      await _pump(tester, now: DateTime(2026, 11, 1, 19));

      expect(find.text('Good evening,'), findsOneWidget);
    });

    testWidgets('has the hero, the doors and the round, in that order', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(HomeHero), findsOneWidget);
      expect(find.text('Start a round'), findsOneWidget);
      expect(find.text('Upcoming round'), findsOneWidget);
      final hero = tester.getTopLeft(find.byType(HomeHero)).dy;
      final doors = tester.getTopLeft(find.text('Start a round')).dy;
      final round = tester.getTopLeft(find.text('Upcoming round')).dy;
      expect(hero, lessThan(doors));
      expect(doors, lessThan(round));
      // The mates feed and the highlights are not on Home.
      expect(find.text('From your sample mates'), findsNothing);
      expect(find.text('Highlights'), findsNothing);
    });

    testWidgets('the hero carries the forecast, and says it is a sample', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('21°C'), findsOneWidget);
      expect(find.text('Sunny'), findsOneWidget);
      expect(find.text('Sample'), findsWidgets);
    });
  });

  group('the upcoming round', () {
    testWidgets('says where, when and who', (tester) async {
      await _pump(tester);

      expect(find.byType(UpcomingRoundCard), findsOneWidget);
      expect(find.text('Richmond Golf Club'), findsWidgets);
      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('In 6 days'), findsOneWidget);
      expect(find.text('8:20 AM'), findsOneWidget);
      expect(find.textContaining('8 playing'), findsOneWidget);
    });

    testWidgets('changes its tune as the day gets closer', (tester) async {
      await _pump(tester, now: DateTime(2026, 11, 6, 9));
      expect(find.text('Tomorrow'), findsOneWidget);

      await _pump(tester, now: DateTime(2026, 11, 7, 9));
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Get ready opens the Rounds tab', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Get ready'));

      expect(find.text('Go: /rounds'), findsOneWidget);
    });

    testWidgets('See all opens Rounds too', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('See all').first);

      expect(find.text('Go: /rounds'), findsOneWidget);
    });

    testWidgets('View details tells the group when, where and who is in', (
      tester,
    ) async {
      final c = await _pump(tester);

      await _tap(tester, find.text('View details'));

      final sent = shareOf(c).shared.single;
      expect(sent, contains('Saturday'));
      expect(sent, contains('Richmond Golf Club'));
    });
  });

  group('shortcuts', () {
    for (final (label, path) in <(String, String)>[
      ('Start a round', '/rounds'),
      ('Plan a trip', '/trips/create'),
      ('Invite a mate', '/friends/search'),
      ('My stats', '/profile/statistics'),
    ]) {
      testWidgets('$label opens $path', (tester) async {
        await _pump(tester);

        await _tap(tester, find.text(label));

        expect(find.text('Go: $path'), findsOneWidget);
      });
    }
  });

  group('shortcut layout', () {
    testWidgets('icons line up whatever the labels do', (tester) async {
      await _pump(tester);

      final tops = <double>{
        for (final icon in <IconData>[
          Icons.sports_golf,
          Icons.luggage_outlined,
          Icons.person_add_alt_1_outlined,
          Icons.bar_chart_rounded,
        ])
          tester
              .getTopLeft(
                find.descendant(
                  of: find.byType(QaddyQuickActions),
                  matching: find.byIcon(icon),
                ),
              )
              .dy,
      };

      expect(tops, hasLength(1));
    });
  });

  group('with a round under way', () {
    Future<ProviderContainer> pumpLive(WidgetTester tester) async {
      final container = friendsContainer(
        overrides: <Override>[
          dashboardClockProvider.overrideWithValue(() => _sundayMorning),
        ],
      );
      container
          .read(roundsProvider.notifier)
          .startRound(
            upcomingRoundInvitees.take(3).map((i) => i.player).toList(),
          );
      container.read(roundsProvider.notifier).nextHole();
      useScreen(tester, const Size(400, 3200));
      final router = GoRouter(initialLocation: '/home', routes: _routes());
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: QaddyTheme.dark,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('the card says so and offers to continue', (tester) async {
      await pumpLive(tester);

      expect(find.text('Hole 2 of 18'), findsOneWidget);
      expect(find.text('Continue round'), findsWidgets);
      expect(find.text('Get ready'), findsNothing);
    });

    testWidgets('Continue round opens the scorecard', (tester) async {
      await pumpLive(tester);

      await _tap(tester, find.text('Continue round').last);

      expect(find.text('Go: /rounds/scorecard'), findsOneWidget);
    });

    testWidgets('the first shortcut becomes Continue round', (tester) async {
      await pumpLive(tester);

      expect(find.text('Start a round'), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);
    });
  });

  group('your game', () {
    testWidgets('starts with the handicap, and says no more than it knows', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(YourGameTiles), findsOneWidget);
      expect(find.text('8.4'), findsOneWidget);
      for (final label in <String>[
        'Handicap',
        'Rounds',
        'Best score',
        'Wins',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('–'), findsOneWidget);
    });

    testWidgets('opens the full statistics', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Handicap'));

      expect(find.text('Go: /profile/statistics'), findsOneWidget);
    });

    testWidgets('after a round it counts the round just played', (
      tester,
    ) async {
      final container = friendsContainer(
        overrides: <Override>[
          dashboardClockProvider.overrideWithValue(() => _sundayMorning),
          roundsClockProvider.overrideWithValue(() => _sundayMorning),
        ],
      );
      container.read(roundsProvider.notifier)
        ..startRound(
          upcomingRoundInvitees.take(2).map((i) => i.player).toList(),
        )
        ..nextHole()
        ..finishRound();
      useScreen(tester, const Size(400, 3200));
      final router = GoRouter(initialLocation: '/home', routes: _routes());
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: QaddyTheme.dark,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tiles = find.byType(YourGameTiles);
      expect(
        find.descendant(of: tiles, matching: find.text('1')),
        findsWidgets,
      );
      expect(
        find.descendant(of: tiles, matching: find.text('–')),
        findsNothing,
      );
    });
  });

  group('next trip', () {
    testWidgets('counts down to the next trip', (tester) async {
      await _pump(tester);

      expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
      expect(find.text('days to go'), findsOneWidget);
    });

    testWidgets('opens the trip', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Melbourne Golf Weekend'));

      expect(find.text('Go: /trips/melbourne-golf-weekend'), findsOneWidget);
    });

    testWidgets('is absent with no trips; the Plan a trip door is the way in', (
      tester,
    ) async {
      await _pump(
        tester,
        overrides: <Override>[tripsProvider.overrideWith(_NoTrips.new)],
      );

      expect(find.text('Next trip'), findsNothing);
      expect(find.text('Plan your next golf trip'), findsNothing);
      await _tap(tester, find.text('Plan a trip'));

      expect(find.text('Go: /trips/create'), findsOneWidget);
    });
  });

  group('the header', () {
    testWidgets('Search, Notifications and Profile all open', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byTooltip('Search'));
      expect(find.text('Go: /home/search'), findsOneWidget);
    });

    testWidgets('the bell opens Notifications', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byIcon(Icons.notifications_outlined));

      expect(find.text('Go: /home/notifications'), findsOneWidget);
    });

    testWidgets('the avatar opens the profile', (tester) async {
      await _pump(tester);

      await _tap(tester, find.bySemanticsLabel('Your profile'));

      expect(find.text('Go: /profile'), findsOneWidget);
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
          final container = friendsContainer(
            overrides: <Override>[
              dashboardClockProvider.overrideWithValue(() => _sundayMorning),
            ],
          );
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(theme: theme, home: const DashboardScreen()),
            ),
          );
          await tester.pump(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('scrolls end to end repeatedly without a hitch', (
      tester,
    ) async {
      await _pump(tester, size: const Size(390, 800));

      final page = find.byType(SingleChildScrollView).first;
      for (var i = 0; i < 4; i++) {
        await tester.fling(page, const Offset(0, -1200), 3000);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.fling(page, const Offset(0, 1200), 3000);
        await tester.pump(const Duration(milliseconds: 600));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('settles without animating forever', (tester) async {
      await _pump(tester);

      await tester.pumpAndSettle();
    });
  });
}
