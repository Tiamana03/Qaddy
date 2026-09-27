import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/groups/ui/screens/groups_screen.dart';

Future<void> _pumpWithRouter(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/friends/groups',
    routes: <RouteBase>[
      GoRoute(
        path: '/friends/groups',
        builder: (context, state) => const GroupsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'details',
            builder: (context, state) => const Text('Group Details'),
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
  testWidgets('shows every placeholder group', (tester) async {
    await _pumpWithRouter(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Saturday Boys'), findsOneWidget);
    expect(find.text('Wednesday Warriors'), findsOneWidget);
    expect(find.text('Friday Social Club'), findsOneWidget);
    expect(find.text('Family Golf Days'), findsOneWidget);
  });

  testWidgets('tapping Saturday Boys opens Group Details', (tester) async {
    await _pumpWithRouter(tester);

    await tester.tap(find.text('Saturday Boys'));
    await tester.pumpAndSettle();

    expect(find.text('Group Details'), findsOneWidget);
  });
}
