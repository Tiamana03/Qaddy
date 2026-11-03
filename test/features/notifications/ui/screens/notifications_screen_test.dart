import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';
import 'package:qaddy/features/notifications/ui/screens/notifications_screen.dart';

import '../../../../support/app_test_harness.dart';

const _destinations = <String>[
  '/rounds',
  '/friends/requests',
  '/trips/melbourne-golf-weekend',
  '/trips/melbourne-golf-weekend/invite',
  '/friends/groups/saturday-boys',
  '/profile/settings',
];

Future<ProviderContainer> _pump(WidgetTester tester, {Size? size}) async {
  final container = await pumpFriendsRouter(
    tester,
    initialLocation: '/home/notifications',
    size: size ?? const Size(400, 3000),
    overrides: <Override>[
      dashboardClockProvider.overrideWithValue(() => DateTime(2026, 11, 1, 9)),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: '/home/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      for (final path in _destinations)
        GoRoute(path: path, builder: (_, __) => Text('Go: $path')),
    ],
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('is a live list of what is really going on', (tester) async {
    await _pump(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text("What's happening"), findsOneWidget);
    expect(find.text('Your round starts in 6 days'), findsOneWidget);
    expect(find.text('Sam wants to play with you'), findsOneWidget);
    expect(find.text('Melbourne Golf Weekend is 27 days away'), findsOneWidget);
    expect(find.text("You're 5th in the Saturday Boys table"), findsOneWidget);
    expect(find.text('Welcome to Qaddy, Tiamana'), findsOneWidget);
    // The old made-up list is gone.
    expect(find.text('Total Notifications'), findsNothing);
    expect(find.text('New version of Qaddy available.'), findsNothing);
  });

  testWidgets('counts what is new, and Mark all read clears it', (
    tester,
  ) async {
    final c = await _pump(tester);
    final fresh = c.read(unreadNotificationCountProvider);
    expect(find.text('$fresh new'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Earlier'), findsNothing);

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();

    expect(c.read(unreadNotificationCountProvider), 0);
    expect(find.text("You're all caught up"), findsOneWidget);
    expect(find.text('Mark all read'), findsNothing);
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('Your round starts in 6 days'), findsOneWidget);
  });

  testWidgets('tapping one reads it and goes where it matters', (tester) async {
    final c = await _pump(tester);
    final before = c.read(unreadNotificationCountProvider);

    await tester.tap(find.text('Sam wants to play with you'));
    await tester.pumpAndSettle();

    expect(find.text('Go: /friends/requests'), findsOneWidget);
    expect(c.read(unreadNotificationCountProvider), before - 1);
  });

  for (final (message, path) in <(String, String)>[
    ('Your round starts in 6 days', '/rounds'),
    ('Melbourne Golf Weekend is 27 days away', '/trips/melbourne-golf-weekend'),
    (
      '1 mate has not replied to Melbourne Golf Weekend',
      '/trips/melbourne-golf-weekend/invite',
    ),
    ("You're 5th in the Saturday Boys table", '/friends/groups/saturday-boys'),
    ('Welcome to Qaddy, Tiamana', '/profile/settings'),
  ]) {
    testWidgets('"$message" opens $path', (tester) async {
      await _pump(tester);

      await tester.ensureVisible(find.text(message));
      await tester.tap(find.text(message));
      await tester.pumpAndSettle();

      expect(find.text('Go: $path'), findsOneWidget);
    });
  }

  testWidgets('switching every kind off says so, and points to Settings', (
    tester,
  ) async {
    final c = await _pump(tester);
    for (final category in NotificationCategory.values) {
      c
          .read(notificationsProvider.notifier)
          .setEnabled(category, enabled: false);
    }
    await tester.pumpAndSettle();

    expect(find.text('Nothing to tell you'), findsOneWidget);
    expect(find.text('Open Settings'), findsOneWidget);
    expect(find.text('Nothing to tell you right now'), findsOneWidget);
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
          home: const NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
