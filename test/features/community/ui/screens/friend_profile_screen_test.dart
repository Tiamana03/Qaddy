import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/friend_profile_screen.dart';

import '../../../../support/app_test_harness.dart';

Future<ProviderContainer> _pump(WidgetTester tester, {Size? size}) async {
  final container = await pumpFriendsRouter(
    tester,
    initialLocation: '/friends/profile',
    size: size ?? const Size(400, 3000),
    routes: <RouteBase>[
      GoRoute(
        path: '/friends/profile',
        builder: (_, __) => const FriendProfileScreen(),
      ),
      GoRoute(
        path: '/friends/activity',
        builder: (_, __) => const Text('Go: activity'),
      ),
      GoRoute(
        path: '/friends/rivalries',
        builder: (_, __) => const Text('Go: rivalries'),
      ),
      GoRoute(
        path: '/friends/groups/:id',
        builder: (_, state) => Text('Group: ${state.pathParameters['id']}'),
      ),
    ],
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('introduces Tom as a player card', (tester) async {
    await _pump(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Tom'), findsWidgets);
    expect(find.text('Handicap 8'), findsOneWidget);
    expect(find.text('Played today'), findsOneWidget);
    expect(find.text('Richmond Golf Club · Richmond, VIC'), findsOneWidget);
    expect(find.text('Since 2022'), findsOneWidget);
    expect(find.text('12 rounds'), findsOneWidget);
    expect(find.text('Details'), findsNothing);
  });

  testWidgets('shows the score between you and opens the rivalry', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('6 – 5'), findsOneWidget);
    expect(find.text('You lead by 1'), findsOneWidget);

    await _tap(tester, find.text('You lead by 1'));

    expect(find.text('Go: rivalries'), findsOneWidget);
  });

  testWidgets('shows the crews you share and opens one', (tester) async {
    await _pump(tester);

    expect(find.text('In your crews'), findsOneWidget);

    await _tap(tester, find.text('Saturday Boys'));

    expect(find.text('Group: saturday-boys'), findsOneWidget);
  });

  testWidgets('shows what Tom has been up to', (tester) async {
    await _pump(tester);

    expect(find.text('Latest from Tom'), findsOneWidget);
    expect(
      find.text(
        'Tom completed a round at Richmond Golf Club',
        findRichText: true,
      ),
      findsOneWidget,
    );

    await _tap(tester, find.text('See all'));

    expect(find.text('Go: activity'), findsOneWidget);
  });

  testWidgets('invites Tom to play', (tester) async {
    final container = await _pump(tester);

    await _tap(tester, find.text('Invite to play'));

    expect(shareOf(container).shared.single, contains('Fancy a round, Tom?'));
  });

  testWidgets('sends Tom a challenge with the score', (tester) async {
    final container = await _pump(tester);

    await _tap(tester, find.text('Challenge'));

    expect(shareOf(container).shared.single, contains('6–5'));
  });

  testWidgets('Activity opens the activity feed', (tester) async {
    await _pump(tester);

    await _tap(tester, find.text('Activity'));

    expect(find.text('Go: activity'), findsOneWidget);
  });

  testWidgets('lays out on a small phone and in the light theme', (
    tester,
  ) async {
    await _pump(tester, size: const Size(320, 3000));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: QaddyTheme.light,
          home: const FriendProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
