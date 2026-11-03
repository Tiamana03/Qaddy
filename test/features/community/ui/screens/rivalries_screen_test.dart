import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/rivalries_screen.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';

import '../../../../support/app_test_harness.dart';

Future<ProviderContainer> _pump(WidgetTester tester, {Size? size}) async {
  final container = await pumpFriendsRouter(
    tester,
    initialLocation: '/friends/rivalries',
    size: size ?? const Size(400, 3000),
    routes: <RouteBase>[
      GoRoute(
        path: '/friends/rivalries',
        builder: (_, __) => const RivalriesScreen(),
      ),
      GoRoute(path: '/rounds', builder: (_, __) => const Text('Go: rounds')),
    ],
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('tells the whole story of you against Tom', (tester) async {
    await _pump(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('SAMPLE RIVALRY'), findsOneWidget);
    expect(find.text('6 – 5'), findsOneWidget);
    expect(find.text('You lead by 1'), findsOneWidget);
    expect(find.text('The scoreboard'), findsOneWidget);
    expect(find.text('You won'), findsOneWidget);
    expect(find.text('Halved'), findsOneWidget);
    expect(find.text('Tom won'), findsOneWidget);
    expect(
      find.text('You have taken 55% of the rounds with a winner.'),
      findsOneWidget,
    );
  });

  testWidgets('sends Tom a challenge', (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text('Send Tom a challenge'));
    await tester.pump();

    expect(shareOf(container).shared.single, contains('6–5'));
  });

  testWidgets('plans the rematch with Tom', (tester) async {
    final container = await _pump(tester);

    await tester.ensureVisible(find.text('Plan the rematch with Tom'));
    await tester.tap(find.text('Plan the rematch with Tom'));
    await tester.pumpAndSettle();

    expect(find.text('Go: rounds'), findsOneWidget);
    expect(container.read(roundSetupProvider), contains('Tom'));
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
          home: const RivalriesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
