import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/friends_home_screen.dart';

Future<void> _pumpWithRouter(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/friends',
    routes: <RouteBase>[
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsHomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'list',
            builder: (context, state) => const Text('Friends List'),
          ),
          GoRoute(
            path: 'search',
            builder: (context, state) => const Text('Search Friends'),
          ),
          GoRoute(
            path: 'requests',
            builder: (context, state) => const Text('Friend Requests'),
          ),
          GoRoute(
            path: 'groups',
            builder: (context, state) => const Text('Groups'),
          ),
          GoRoute(
            path: 'activity',
            builder: (context, state) => const Text('Activity Feed'),
          ),
          GoRoute(
            path: 'rivalries',
            builder: (context, state) => const Text('Rivalries'),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
  );
}

void main() {
  testWidgets('shows friend summary, quick actions and previews', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('View Friends'), findsOneWidget);
    expect(find.text('Search Friends'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('View Activity'), findsOneWidget);
    expect(find.text('View Rivalries'), findsOneWidget);
  });

  testWidgets('View Activity opens Activity Feed directly from Friends Home', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    await tester.tap(find.text('View Activity'));
    await tester.pumpAndSettle();

    expect(find.text('Activity Feed'), findsOneWidget);
  });

  testWidgets('View Rivalries opens Rivalries directly from Friends Home', (
    tester,
  ) async {
    await _pumpWithRouter(tester);

    await tester.tap(find.text('View Rivalries'));
    await tester.pumpAndSettle();

    expect(find.text('Rivalries'), findsOneWidget);
  });
}
