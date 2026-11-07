import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/groups/ui/screens/groups_screen.dart';

import '../../../../support/app_test_harness.dart';

Future<void> _pump(WidgetTester tester, {Size? size}) async {
  await pumpFriendsRouter(
    tester,
    initialLocation: '/friends/groups',
    size: size ?? const Size(400, 2400),
    routes: <RouteBase>[
      GoRoute(
        path: '/friends/groups',
        builder: (context, state) => const GroupsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                Text('Group: ${state.pathParameters['id']}'),
          ),
        ],
      ),
    ],
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows every group with what it is about', (tester) async {
    await _pump(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('My groups'), findsOneWidget);
    expect(find.text("Golf's better together."), findsOneWidget);
    expect(find.text('My groups (4)'), findsOneWidget);
    for (final name in <String>[
      'Saturday Boys',
      'Wednesday Warriors',
      'Friday Social Club',
      'Family Golf Days',
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.text('Three generations, one fairway.'), findsOneWidget);
    expect(find.textContaining('8 members'), findsOneWidget);
  });

  testWidgets('only the group with a round coming up says so', (tester) async {
    await _pump(tester);

    expect(find.text('Saturday · 8:20 AM'), findsOneWidget);
    expect(find.text('Round ready'), findsOneWidget);
  });

  testWidgets('every group opens its own page', (tester) async {
    for (final (name, id) in <(String, String)>[
      ('Saturday Boys', 'saturday-boys'),
      ('Wednesday Warriors', 'wednesday-warriors'),
      ('Friday Social Club', 'friday-social-club'),
      ('Family Golf Days', 'family-golf-days'),
    ]) {
      await _pump(tester);

      await tester.tap(find.text(name));
      await tester.pumpAndSettle();

      expect(find.text('Group: $id'), findsOneWidget, reason: name);
    }
  });

  testWidgets('shows the faces of a group whose people are known', (
    tester,
  ) async {
    await _pump(tester);

    // Saturday Boys: four faces and how many are in, the others the line.
    // (and the golfer's own face in the brand bar)
    expect(find.byType(QaddyAvatar), findsNWidgets(5));
    expect(find.text('8 members · 8 confirmed'), findsOneWidget);
  });

  testWidgets('Invitations and Past groups say there is nothing yet', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();
    expect(find.text('No invitations yet'), findsOneWidget);

    await tester.tap(find.text('Past groups'));
    await tester.pumpAndSettle();
    expect(find.text('No past groups'), findsOneWidget);
  });

  testWidgets('search narrows the groups', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'friday');
    await tester.pumpAndSettle();

    expect(find.text('Friday Social Club'), findsOneWidget);
    expect(find.text('Saturday Boys'), findsNothing);
  });

  testWidgets('Create group says it is coming, kindly', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();

    expect(find.text('Creating groups is coming'), findsOneWidget);
  });

  for (final size in <Size>[const Size(320, 2400), const Size(1280, 2400)]) {
    testWidgets('lays out at ${size.width}', (tester) async {
      await _pump(tester, size: size);

      expect(tester.takeException(), isNull);
    });
  }
}
