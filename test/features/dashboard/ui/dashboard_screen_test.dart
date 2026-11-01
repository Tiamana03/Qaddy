import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/dashboard/ui/screens/dashboard_screen.dart';
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
  '/friends/groups/details',
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
    testWidgets('uses QaddyScaffold and greets the golfer by the hour', (
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

    testWidgets('has every section a golfer comes for', (tester) async {
      await _pump(tester);

      expect(find.text('NEXT ROUND'), findsOneWidget);
      expect(find.text('Start a round'), findsOneWidget);
      expect(find.text('YOUR GAME'), findsOneWidget);
      expect(find.text('From your mates'), findsOneWidget);
      expect(find.text('Your highlights'), findsOneWidget);
      // The old placeholder furniture is gone.
      expect(find.text('Create Round'), findsNothing);
      expect(find.text('Continue Round'), findsNothing);
      expect(find.text('View Summary'), findsNothing);
    });
  });

  group('next round', () {
    testWidgets('counts down to the round and says where and who', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('6'), findsOneWidget);
      expect(find.text('days to tee-off'), findsOneWidget);
      expect(find.text('Richmond Golf Club · Saturday, 8:20 AM'), findsOne);
      expect(find.text('21°C Sunny'), findsOneWidget);
      expect(find.text('Stableford'), findsOneWidget);
      expect(find.text('18 holes'), findsOneWidget);
      expect(find.text('+3 more · 8 playing'), findsOneWidget);
    });

    testWidgets('changes its tune as the day gets closer', (tester) async {
      await _pump(tester, now: DateTime(2026, 11, 7, 7));

      expect(find.text("IT'S ROUND DAY"), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Get ready opens the Rounds tab', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Get ready'));

      expect(find.text('Go: /rounds'), findsOneWidget);
    });

    testWidgets('the story opens the round too', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('days to tee-off'));

      expect(find.text('Go: /rounds'), findsOneWidget);
    });

    testWidgets('tells the group when, where and who is in', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.byTooltip('Tell the group'));

      final shared = shareOf(container).shared;
      expect(shared, hasLength(1));
      expect(shared.single, contains('Saturday at 8:20 AM'));
      expect(shared.single, contains('Richmond Golf Club'));
      expect(shared.single, contains("Who's in?"));
    });
  });

  group('shortcuts', () {
    for (final (label, path) in <(String, String)>[
      ('Start a round', '/rounds'),
      ('Plan a trip', '/trips/create'),
      ('Add a mate', '/friends/search'),
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
          tester.getTopLeft(find.byIcon(icon)).dy,
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

    testWidgets('the hero says so and offers to continue', (tester) async {
      await pumpLive(tester);

      expect(find.text('ROUND IN PROGRESS'), findsOneWidget);
      expect(find.text('Hole 2 of 18'), findsOneWidget);
      expect(find.text('Continue round'), findsWidgets);
      expect(find.text('Get ready'), findsNothing);
    });

    testWidgets('Continue round opens the scorecard', (tester) async {
      await pumpLive(tester);

      await _tap(tester, find.text('Continue round').first);

      expect(find.text('Go: /rounds/scorecard'), findsOneWidget);
    });

    testWidgets('the first shortcut becomes Continue round', (tester) async {
      await pumpLive(tester);

      expect(find.text('Start a round'), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);
    });
  });

  group('after a round', () {
    testWidgets('your game shows the round just played and opens it', (
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

      expect(find.text('Won at Richmond Golf Club'), findsOneWidget);
      expect(find.textContaining('Today'), findsOneWidget);
      // The numbers now come from the round just played.
      expect(find.text('1 win in 1 round'), findsOneWidget);
      expect(find.text('Rounds played'), findsOneWidget);
      expect(find.text('Avg points'), findsOneWidget);
      expect(find.text('Best round pts'), findsOneWidget);

      await _tap(tester, find.text('Won at Richmond Golf Club'));

      expect(find.text('Go: /rounds/complete'), findsOneWidget);
    });
  });

  group('your game', () {
    testWidgets(
      'starts with the handicap and an invitation, not made-up numbers',
      (tester) async {
        await _pump(tester);

        expect(find.text('8.4'), findsOneWidget);
        expect(find.text('Play a round to build your game'), findsOneWidget);
        expect(find.text('Rounds played'), findsNothing);
        expect(find.textContaining('Dunes'), findsNothing);
        expect(find.textContaining('↓'), findsNothing);
      },
    );

    testWidgets('opens the full statistics', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('All stats'));

      expect(find.text('Go: /profile/statistics'), findsOneWidget);
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

    testWidgets('invites a golfer with no trips to plan one', (tester) async {
      await _pump(
        tester,
        overrides: <Override>[tripsProvider.overrideWith(_NoTrips.new)],
      );

      expect(find.text('Plan your next golf trip'), findsOneWidget);
      await _tap(tester, find.text('Plan your next golf trip'));

      expect(find.text('Go: /trips/create'), findsOneWidget);
    });
  });

  group('from your mates', () {
    testWidgets('shows the latest moments and lets you cheer', (tester) async {
      await _pump(tester);

      expect(find.text('Nice round'), findsOneWidget);

      await _tap(tester, find.text('Nice round'));
    });

    testWidgets('See all goes to Friends', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('See all'));

      expect(find.text('Go: /friends'), findsOneWidget);
    });
  });

  group('highlights', () {
    for (final (text, path) in <(String, String)>[
      ('Round completed at Richmond Golf Club', '/profile/statistics'),
      ('Josh joined the Saturday Boys group', '/friends/groups/details'),
      ('New golf trip created', '/trips'),
      ('Handicap reduced to 8.4', '/profile/statistics'),
      ('Achievement unlocked: Personal Best', '/profile'),
    ]) {
      testWidgets('"$text" leads to $path', (tester) async {
        await _pump(tester);

        await _tap(tester, find.text(text));

        expect(find.text('Go: $path'), findsOneWidget);
      });
    }
  });

  group('the header', () {
    testWidgets('Search, Notifications and Profile all open', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byTooltip('Search'));
      expect(find.text('Go: /home/search'), findsOneWidget);
    });

    testWidgets('the bell opens Notifications', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byTooltip('Notifications'));

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
