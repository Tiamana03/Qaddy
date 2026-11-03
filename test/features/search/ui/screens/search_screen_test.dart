import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/widgets/friend_peek_sheet.dart';
import 'package:qaddy/features/search/ui/screens/search_screen.dart';

import '../../../../support/app_test_harness.dart';

Future<void> _pump(WidgetTester tester, {Size? size}) async {
  await pumpFriendsRouter(
    tester,
    initialLocation: '/search',
    size: size ?? const Size(400, 3000),
    routes: <RouteBase>[
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/rounds', builder: (_, __) => const Text('Go: rounds')),
      GoRoute(path: '/profile', builder: (_, __) => const Text('Go: profile')),
      GoRoute(
        path: '/friends/groups/:id',
        builder: (_, state) => Text('Group: ${state.pathParameters['id']}'),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (_, state) => Text('Trip: ${state.pathParameters['id']}'),
      ),
    ],
  );
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows every category by default', (tester) async {
    await _pump(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Find anything'), findsOneWidget);
    for (final label in <String>[
      'Friends',
      'Rounds',
      'Trips',
      'Groups',
      'Courses',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Saturday Boys'), findsOneWidget);
    expect(find.text('Kingston Heath'), findsOneWidget);
    // The upcoming round's course and a favourite course are separate
    // results, so the club shows twice — see search-engineering-decisions.md.
    expect(find.text('Richmond Golf Club'), findsNWidgets(2));
  });

  testWidgets('only confirmed friends are found', (tester) async {
    await _pump(tester);

    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('Josh'), findsNothing); // pending
    expect(find.text('Jack'), findsNothing); // declined
  });

  testWidgets('filters as you type and says how many it found', (tester) async {
    await _pump(tester);

    await _type(tester, 'tom');

    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('1 result for “tom”'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    for (final label in <String>['Rounds', 'Trips', 'Groups', 'Courses']) {
      expect(find.text(label), findsNothing, reason: label);
    }
  });

  testWidgets('the part that matched is picked out in gold', (tester) async {
    await _pump(tester);

    await _type(tester, 'tom');

    final spans = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.textSpan is TextSpan &&
          (widget.textSpan! as TextSpan).children!.any(
            (span) => span is TextSpan && span.text == 'Tom',
          ),
    );
    expect(spans, findsOneWidget);
  });

  testWidgets('a mate opens their card, whoever they are', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Ben'));
    await tester.pumpAndSettle();

    expect(find.byType(FriendPeekSheet), findsOneWidget);
  });

  testWidgets('a group opens its own page', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Wednesday Warriors'));
    await tester.tap(find.text('Wednesday Warriors'));
    await tester.pumpAndSettle();

    expect(find.text('Group: wednesday-warriors'), findsOneWidget);
  });

  testWidgets('the next round opens Rounds', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Sample round · Saturday, 8:20 AM'));
    await tester.tap(find.text('Sample round · Saturday, 8:20 AM'));
    await tester.pumpAndSettle();

    expect(find.text('Go: rounds'), findsOneWidget);
  });

  testWidgets('shows a kind empty state, and clearing brings it all back', (
    tester,
  ) async {
    await _pump(tester);

    await _type(tester, 'zzz');

    expect(find.text('No results found'), findsOneWidget);
    expect(find.text('Nothing for “zzz”'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsNothing);
    expect(find.text('Tom'), findsOneWidget);
  });

  testWidgets('lays out on a small phone and in the light theme', (
    tester,
  ) async {
    await _pump(tester, size: const Size(320, 3000));
    expect(tester.takeException(), isNull);

    useScreen(tester, const Size(400, 3000));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: QaddyTheme.light, home: const SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
