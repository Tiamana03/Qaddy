import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/friends_list_screen.dart';

Future<void> _pumpWithRouter(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/friends/list',
    routes: <RouteBase>[
      GoRoute(
        path: '/friends/list',
        builder: (context, state) => const FriendsListScreen(),
      ),
      GoRoute(
        path: '/friends/profile',
        builder: (context, state) => const Text('Friend Profile'),
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(theme: QaddyTheme.dark, routerConfig: router),
  );
}

void main() {
  testWidgets('shows only Confirmed friends', (tester) async {
    await _pumpWithRouter(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('Luke'), findsOneWidget);
    expect(find.text('Nick'), findsOneWidget);
    expect(find.text('Liam'), findsOneWidget);
    // Pending/Declined friends are excluded — they surface on Friend
    // Requests instead.
    expect(find.text('Josh'), findsNothing);
    expect(find.text('Sam'), findsNothing);
    expect(find.text('Jack'), findsNothing);
  });

  testWidgets('tapping Tom opens Friend Profile', (tester) async {
    await _pumpWithRouter(tester);

    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();

    expect(find.text('Friend Profile'), findsOneWidget);
  });
}
