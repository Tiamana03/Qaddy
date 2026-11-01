import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/screens/friends_home_screen.dart';
import 'package:qaddy/features/community/ui/widgets/friend_peek_sheet.dart';
import 'package:qaddy/features/community/ui/widgets/rivalry_spotlight.dart';
import 'package:qaddy/features/community/ui/widgets/squad_strip.dart';

import '../../../../support/app_test_harness.dart';

/// A store with no friends at all, for the first-time experience.
class _NoFriends extends FriendsController {
  @override
  FriendsState build() => const FriendsState(friends: <Friend>[], requests: []);
}

List<RouteBase> _routes() => <RouteBase>[
  GoRoute(
    path: '/friends',
    builder: (context, state) => const FriendsHomeScreen(),
    routes: <RouteBase>[
      for (final name in <String>[
        'list',
        'search',
        'requests',
        'activity',
        'rivalries',
        'profile',
      ])
        GoRoute(path: name, builder: (context, state) => Text('Go: $name')),
      GoRoute(
        path: 'groups',
        builder: (context, state) => const Text('Go: groups'),
        routes: <RouteBase>[
          GoRoute(
            path: 'details',
            builder: (context, state) => const Text('Go: details'),
          ),
        ],
      ),
    ],
  ),
];

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Size size = const Size(400, 3000),
  List<Override> overrides = const [],
}) async {
  final container = await pumpFriendsRouter(
    tester,
    initialLocation: '/friends',
    routes: _routes(),
    size: size,
    overrides: overrides,
  );
  await tester.pump(const Duration(seconds: 2));
  return container;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('the clubhouse', () {
    testWidgets('leads with the squad, the rivalry, activity and clubs', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Your squad'), findsOneWidget);
      expect(find.text('RIVALRY'), findsOneWidget);
      expect(find.text('Latest from mates'), findsOneWidget);
      expect(find.text('Your clubs'), findsOneWidget);
    });

    testWidgets('no longer opens with a menu of six links', (tester) async {
      await _pump(tester);

      expect(find.text('Quick Actions'), findsNothing);
      expect(find.text('View Friends'), findsNothing);
      expect(find.text('Total'), findsNothing);
    });

    testWidgets('says how many friends and who played recently', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.textContaining('5 friends'), findsOneWidget);
      expect(find.textContaining('played recently'), findsOneWidget);
    });
  });

  group('squad', () {
    testWidgets('shows every confirmed friend with their handicap', (
      tester,
    ) async {
      // Wide, so the whole strip is built at once.
      await _pump(tester, size: const Size(1280, 3000));

      for (final name in <String>['Tom', 'Ben', 'Luke', 'Nick', 'Liam']) {
        expect(find.text(name), findsWidgets, reason: name);
      }
      expect(find.text('HCP 5'), findsOneWidget);
      // Pending and declined friends aren't in the squad.
      expect(find.text('Jack'), findsNothing);
    });

    testWidgets('crowns the best handicap and rings those who played', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Luke.*best handicap in your squad')),
        findsWidgets,
      );
      expect(
        find.bySemanticsLabel(RegExp('Tom.*played recently')),
        findsWidgets,
      );
    });

    testWidgets('any friend can be tapped for a quick look', (tester) async {
      await _pump(tester);

      await _tap(tester, find.bySemanticsLabel(RegExp('^Ben,')));
      await tester.pumpAndSettle();

      expect(find.byType(FriendPeekSheet), findsOneWidget);
      expect(find.text('Loves Brookwater Golf Club'), findsOneWidget);
      expect(find.text('Ipswich, QLD'), findsOneWidget);
      expect(find.text('Rounds together'), findsOneWidget);
      // Ben has no full profile, so there's nothing to open.
      expect(find.text('View profile'), findsNothing);
    });

    testWidgets('a quick look ends with an invitation to play', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.bySemanticsLabel(RegExp('^Ben,')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fancy a round, Ben?'));
      await tester.pumpAndSettle();

      expect(find.byType(FriendPeekSheet), findsNothing);
      expect(shareOf(container).shared, hasLength(1));
      expect(shareOf(container).shared.single, contains('Fancy a round, Ben?'));
      expect(shareOf(container).shared.single, endsWith('– Tiamana'));
    });

    testWidgets("Tom's look offers his full profile", (tester) async {
      await _pump(tester);

      await _tap(tester, find.bySemanticsLabel(RegExp('^Tom,')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View profile'));
      await tester.pumpAndSettle();

      expect(find.text('Go: profile'), findsOneWidget);
    });

    testWidgets('the Add tile goes to Search', (tester) async {
      await _pump(tester);

      // The Add tile is the last item of the strip.
      await tester.drag(find.byType(SquadStrip), const Offset(-600, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await _tap(tester, find.bySemanticsLabel('Add a friend'));
      await tester.pumpAndSettle();

      expect(find.text('Go: search'), findsOneWidget);
    });

    testWidgets('a new golfer is invited to build a squad', (tester) async {
      await _pump(
        tester,
        overrides: [friendsProvider.overrideWith(_NoFriends.new)],
      );

      expect(find.text('Build your squad'), findsOneWidget);
      expect(find.text('Your squad'), findsNothing);
      await _tap(tester, find.text('Find golfers'));
      await tester.pumpAndSettle();
      expect(find.text('Go: search'), findsOneWidget);
    });
  });

  group('rivalry', () {
    testWidgets('shows the score, who leads and the last result', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('6 – 5'), findsOneWidget);
      expect(find.text('You lead by 1'), findsOneWidget);
      expect(find.text('1 halved'), findsOneWidget);
      expect(
        find.text('Last: Won by 2 strokes at Richmond Golf Club'),
        findsOneWidget,
      );
    });

    testWidgets('counts the score up from nothing', (tester) async {
      await _pump(tester);
      // Pumped for two seconds already; a fresh pump shows it starting.
      await tester.pumpWidget(const SizedBox());
      final container = friendsContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: QaddyTheme.dark,
            home: const FriendsHomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('6 – 5'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('6 – 5'), findsOneWidget);
    });

    testWidgets('sends the rival a challenge', (tester) async {
      final c = await _pump(tester);

      await _tap(tester, find.text('Send Tom a challenge'));

      final message = shareOf(c).shared.single;
      expect(message, contains('Tiamana vs Tom: 6–5'));
      expect(message, contains('Fancy a rematch?'));
    });

    testWidgets('opens the full rivalry', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byType(RivalrySpotlight));
      await tester.pumpAndSettle();

      expect(find.text('Go: rivalries'), findsOneWidget);
    });
  });

  group('requests', () {
    testWidgets('shows who wants to play, with a count', (tester) async {
      await _pump(tester);

      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Sam'), findsOneWidget);
      expect(find.textContaining('Wants to play'), findsOneWidget);
      expect(find.text('Waiting for Josh to reply'), findsOneWidget);
    });

    testWidgets('accepting makes them part of the squad', (tester) async {
      final c = await _pump(tester);

      await _tap(tester, find.text('Accept'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('You and Sam are now friends'), findsOneWidget);
      expect(
        c.read(confirmedFriendsProvider).map((f) => f.id),
        contains('sam'),
      );
      expect(find.textContaining('Wants to play'), findsNothing);
      // Their face is now at the end of the squad strip.
      await tester.drag(find.byType(SquadStrip), const Offset(-600, 0));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.bySemanticsLabel(RegExp('^Sam,')), findsWidgets);
    });

    testWidgets('declining just clears the request', (tester) async {
      final c = await _pump(tester);

      await _tap(tester, find.text('Decline'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Request from Sam declined'), findsOneWidget);
      expect(c.read(incomingRequestsProvider), isEmpty);
      expect(find.bySemanticsLabel(RegExp('^Sam,')), findsNothing);
    });

    testWidgets('a request you sent can be cancelled', (tester) async {
      final c = await _pump(tester);

      await _tap(tester, find.text('Cancel'));
      await tester.pump(const Duration(seconds: 1));

      expect(c.read(outgoingRequestsProvider), isEmpty);
      expect(find.text('Request to Josh cancelled'), findsOneWidget);
    });

    testWidgets('the whole section goes when nothing is waiting', (
      tester,
    ) async {
      final c = await _pump(tester);

      c.read(friendsProvider.notifier)
        ..acceptRequest('sam')
        ..cancelRequest('josh');
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Requests'), findsNothing);
    });

    testWidgets('See all opens the Requests screen', (tester) async {
      await _pump(tester);

      final seeAll = find.descendant(
        of: find.ancestor(
          of: find.text('Requests'),
          matching: find.byType(Row),
        ),
        matching: find.text('See all'),
      );
      await _tap(tester, seeAll);
      await tester.pumpAndSettle();

      expect(find.text('Go: requests'), findsOneWidget);
    });
  });

  group('activity', () {
    testWidgets('shows the latest three moments', (tester) async {
      await _pump(tester);

      expect(
        find.text(
          'Tom completed a round at Richmond Golf Club',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.text('Ben joined Saturday Boys', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.text("Luke's handicap improved to 5", findRichText: true),
        findsOneWidget,
      );
      expect(
        find.text('Liam unlocked Personal Best', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('each moment has its own way to cheer', (tester) async {
      await _pump(tester);

      expect(find.text('Nice round'), findsOneWidget);
      expect(find.text('Welcome in'), findsOneWidget);
      expect(find.text('Well played'), findsOneWidget);
    });

    testWidgets('cheering toggles and is remembered', (tester) async {
      final c = await _pump(tester);

      await _tap(tester, find.text('Nice round'));

      expect(find.text('Cheered'), findsOneWidget);
      expect(c.read(friendsProvider).cheered, contains('activity-1'));

      await _tap(tester, find.text('Cheered'));
      expect(find.text('Cheered'), findsNothing);
      expect(c.read(friendsProvider).cheered, isEmpty);
    });

    testWidgets('See all opens the Activity Feed', (tester) async {
      await _pump(tester);

      final seeAll = find.descendant(
        of: find.ancestor(
          of: find.text('Latest from mates'),
          matching: find.byType(Row),
        ),
        matching: find.text('See all'),
      );
      await _tap(tester, seeAll);
      await tester.pumpAndSettle();

      expect(find.text('Go: activity'), findsOneWidget);
    });
  });

  group('next round', () {
    testWidgets('invites the golfer to the next tee time', (tester) async {
      await _pump(tester);

      expect(find.text('Saturday, 8:20 AM'), findsOneWidget);
      expect(find.text('Richmond Golf Club · Stableford'), findsOneWidget);
      expect(find.text('8 playing'), findsNothing);
      expect(find.textContaining('+3 more · 8 playing'), findsOneWidget);
    });

    testWidgets('rallies the group with when, where and who is in', (
      tester,
    ) async {
      final container = await _pump(tester);

      await _tap(tester, find.text("Who's in? Rally the group"));

      expect(shareOf(container).shared.single, contains('Saturday Boys'));
      expect(shareOf(container).shared.single, contains('8:20 AM'));
      expect(shareOf(container).shared.single, contains("Who's in?"));
    });

    testWidgets('opens the group from the story', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Saturday, 8:20 AM'));
      await tester.pumpAndSettle();

      expect(find.text('Go: details'), findsOneWidget);
    });
  });

  group('season race', () {
    testWidgets('shows the podium and where the golfer stands', (tester) async {
      await _pump(tester);
      await tester.pumpAndSettle();

      expect(find.text('SEASON RACE'), findsOneWidget);
      for (final name in <String>['Luke', 'Tom', 'Nick']) {
        expect(find.text(name), findsWidgets, reason: name);
      }
      expect(find.text('118'), findsOneWidget);
      expect(find.text("You're 5th"), findsOneWidget);
      expect(find.text('4 points behind Ben'), findsOneWidget);
      expect(find.text('10 rounds to go'), findsOneWidget);
    });

    testWidgets('opens the group leaderboard', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text("You're 5th"));
      await tester.pumpAndSettle();

      expect(find.text('Go: details'), findsOneWidget);
    });
  });

  group('clubs', () {
    testWidgets('shows every group with its size and season', (tester) async {
      // A wide screen, so the whole strip is built at once.
      await _pump(tester, size: const Size(1280, 3000));

      for (final name in <String>[
        'Saturday Boys',
        'Wednesday Warriors',
        'Friday Social Club',
        'Family Golf Days',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      expect(find.text('8 members · 2026 Season'), findsOneWidget);
      expect(find.textContaining('6 members'), findsOneWidget);
    });

    testWidgets('Saturday Boys opens its details; the others, the list', (
      tester,
    ) async {
      await _pump(tester);

      await _tap(tester, find.text('Wednesday Warriors'));
      await tester.pumpAndSettle();

      expect(find.text('Go: groups'), findsOneWidget);
    });
  });

  group('getting around', () {
    testWidgets('the header buttons open Search and All friends', (
      tester,
    ) async {
      await _pump(tester);

      await _tap(tester, find.byTooltip('Search golfers'));
      await tester.pumpAndSettle();
      expect(find.text('Go: search'), findsOneWidget);
    });

    testWidgets('All friends opens the Friends List', (tester) async {
      await _pump(tester);

      await _tap(tester, find.byTooltip('All friends'));
      await tester.pumpAndSettle();

      expect(find.text('Go: list'), findsOneWidget);
    });
  });

  group('lays out everywhere', () {
    for (final width in <double>[320, 400, 820, 1280]) {
      for (final (name, theme) in <(String, ThemeData)>[
        ('dark', QaddyTheme.dark),
        ('light', QaddyTheme.light),
      ]) {
        testWidgets('at $width px in $name mode', (tester) async {
          await pumpFriends(
            tester,
            const FriendsHomeScreen(),
            size: Size(width, 3200),
            theme: theme,
          );
          await tester.pump(const Duration(seconds: 2));

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('scrolls end to end repeatedly without a hitch', (
      tester,
    ) async {
      await pumpFriends(
        tester,
        const FriendsHomeScreen(),
        size: const Size(390, 800),
      );
      await tester.pump(const Duration(seconds: 2));

      final page = find.byType(SingleChildScrollView).first;
      for (var i = 0; i < 4; i++) {
        await tester.fling(page, const Offset(0, -900), 3000);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.fling(page, const Offset(0, 900), 3000);
        await tester.pump(const Duration(milliseconds: 600));
      }

      expect(tester.takeException(), isNull);
      expect(find.text('Friends'), findsOneWidget);
    });

    testWidgets('and settles without animating forever', (tester) async {
      await pumpFriends(tester, const FriendsHomeScreen());

      // pumpAndSettle fails if anything keeps animating.
      await tester.pumpAndSettle();
    });
  });

  testWidgets('the placeholder data still adds up', (tester) async {
    expect(confirmedFriendsCount, 5);
    expect(pendingFriendsCount, 2);
  });
}
