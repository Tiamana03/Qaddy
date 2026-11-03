import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/community/ui/widgets/friend_peek_sheet.dart';
import 'package:qaddy/features/groups/ui/screens/group_details_screen.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

import '../../../../support/app_test_harness.dart';
import '../../../../support/played_rounds.dart';

List<RouteBase> _routes(String id) => <RouteBase>[
  GoRoute(
    path: '/group',
    builder: (context, state) => GroupDetailsScreen(groupId: id),
  ),
  GoRoute(path: '/rounds', builder: (_, __) => const Text('Go: rounds')),
  GoRoute(path: '/trips/create', builder: (_, __) => const Text('Go: trip')),
  GoRoute(path: '/profile', builder: (_, __) => const Text('Go: profile')),
  GoRoute(
    path: '/friends/groups',
    builder: (_, __) => const Text('Go: groups'),
  ),
];

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  String id = 'saturday-boys',
  Size size = const Size(400, 4000),
}) async {
  final pumped = await pumpFriendsRouter(
    tester,
    initialLocation: '/group',
    routes: _routes(id),
    size: size,
  );
  await tester.pumpAndSettle();
  return pumped;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  group('Saturday Boys', () {
    testWidgets('opens like a clubhouse, not a form', (tester) async {
      await _pump(tester);

      expect(
        find.text('Saturday mornings at Richmond. The banter is compulsory.'),
        findsOneWidget,
      );
      expect(find.text('8 mates'), findsOneWidget);
      expect(find.text('Since 2024'), findsOneWidget);
      expect(find.text('Richmond Golf Club'), findsOneWidget);
      expect(find.text('Stableford'), findsOneWidget);
      expect(find.text('Group Overview'), findsNothing);
    });

    testWidgets('invites the group to the next round', (tester) async {
      await _pump(tester);

      expect(find.text('NEXT ROUND · SATURDAY BOYS'), findsOneWidget);
      expect(find.text('Saturday, 8:20 AM'), findsOneWidget);
    });

    testWidgets('tells the season story with the golfer in it', (tester) async {
      await _pump(tester);

      expect(find.text('The 2026 Season'), findsOneWidget);
      expect(find.text("You're 5th"), findsOneWidget);
      expect(find.text('4 points behind Ben'), findsOneWidget);
      expect(find.text('8 of 18 rounds played'), findsOneWidget);
    });

    testWidgets('lists the rest of the field with the golfer marked', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('The rest of the field'), findsOneWidget);
      for (final name in <String>['Ben', 'Liam', 'Josh', 'Sam']) {
        expect(find.text(name), findsWidgets, reason: name);
      }
      expect(find.text('97 pts'), findsOneWidget);
      expect(find.text('You'), findsWidgets);
    });

    testWidgets('introduces the squad, captain first', (tester) async {
      await _pump(tester);

      expect(find.text('The squad'), findsOneWidget);
      expect(find.text('Captain'), findsOneWidget);
      expect(find.text('HCP 5'), findsOneWidget);
      expect(find.text('HCP 18'), findsOneWidget);
    });

    testWidgets('a mate in the squad opens their card', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('HCP 5'));
      await tester.pumpAndSettle();

      expect(find.byType(FriendPeekSheet), findsOneWidget);
    });

    testWidgets('the golfer in the squad opens their own profile', (
      tester,
    ) async {
      await _pump(tester);

      await _tap(tester, find.text('Captain'));
      await tester.pumpAndSettle();

      expect(find.text('Go: profile'), findsOneWidget);
    });

    testWidgets('plans a round with the whole group', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('Plan a round'));
      await tester.pumpAndSettle();

      expect(find.text('Go: rounds'), findsOneWidget);
      expect(
        container.read(roundSetupProvider),
        containsAll(<String>['Tiamana', 'Tom', 'Luke', 'Ben']),
      );
    });

    testWidgets('the story of the next round plans it too', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Saturday, 8:20 AM'));
      await tester.pumpAndSettle();

      expect(find.text('Go: rounds'), findsOneWidget);
    });

    testWidgets('plans a trip', (tester) async {
      await _pump(tester);

      await _tap(tester, find.text('Plan a trip'));
      await tester.pumpAndSettle();

      expect(find.text('Go: trip'), findsOneWidget);
    });

    testWidgets('rallies the group', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text("Who's in? Rally the group"));

      expect(shareOf(container).shared.single, contains('Saturday Boys'));
      expect(shareOf(container).shared.single, contains('8:20 AM'));
    });

    testWidgets('sends the banter about the table', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('Banter'));

      expect(
        shareOf(container).shared.single,
        'Luke leads the Saturday Boys table by 7 points. '
        'Time someone did something about it. – Tiamana',
      );
    });

    testWidgets('invites a mate to join', (tester) async {
      final container = await _pump(tester);

      await _tap(tester, find.text('Invite a mate'));

      expect(shareOf(container).shared.single, contains('Saturday Boys'));
      expect(shareOf(container).shared.single, contains('banter'));
    });

    testWidgets('head to head waits for a round together', (tester) async {
      await _pump(tester);

      expect(find.text('Head to head'), findsOneWidget);
      expect(
        find.textContaining('Play a round with the Saturday Boys'),
        findsOneWidget,
      );
    });

    testWidgets('head to head counts the rounds actually played', (
      tester,
    ) async {
      final played = PlayedRounds()
        ..play(1, List<int>.filled(18, 4))
        ..play(2, List<int>.filled(18, 3));
      useScreen(tester, const Size(400, 4000));
      final router = GoRouter(
        initialLocation: '/group',
        routes: _routes('saturday-boys'),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: played.container,
          child: MaterialApp.router(
            theme: QaddyTheme.dark,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 rounds together'), findsOneWidget);
    });

    testWidgets('lays out on a small phone', (tester) async {
      await _pump(tester, size: const Size(320, 4000));

      expect(tester.takeException(), isNull);
    });
  });

  group('a group without a season yet', () {
    testWidgets('says what its first round will start', (tester) async {
      await _pump(tester, id: 'wednesday-warriors');

      expect(find.text('Midweek rounds and long lunches.'), findsOneWidget);
      expect(find.text('6 mates'), findsOneWidget);
      expect(find.text('The table starts with a round'), findsOneWidget);
      expect(find.text('The squad'), findsNothing);
      expect(find.text('NEXT ROUND · WEDNESDAY WARRIORS'), findsNothing);
    });

    testWidgets('still lets the golfer start something', (tester) async {
      await _pump(tester, id: 'friday-social-club');

      await _tap(tester, find.text('Plan a round').first);
      await tester.pumpAndSettle();

      expect(find.text('Go: rounds'), findsOneWidget);
    });

    testWidgets('banter is a nudge to play', (tester) async {
      final container = await _pump(tester, id: 'family-golf-days');

      await _tap(tester, find.text('Banter'));

      expect(
        shareOf(container).shared.single,
        "Family Golf Days: who's up for a round? – Tiamana",
      );
    });
  });

  testWidgets('an unknown group is a kind dead end, not a crash', (
    tester,
  ) async {
    await _pump(tester, id: 'nobody');

    expect(find.text('This group has gone quiet'), findsOneWidget);

    await _tap(tester, find.text('See my groups'));
    await tester.pumpAndSettle();
    expect(find.text('Go: groups'), findsOneWidget);
  });
}
