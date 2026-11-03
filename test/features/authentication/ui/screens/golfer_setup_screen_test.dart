import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';

import '../../../../support/launch_harness.dart';

Future<LaunchHarness> _pump(WidgetTester tester, {Size? size}) async {
  final h = await pumpLaunch(
    tester,
    initialLocation: AppRoutes.setup,
    size: size ?? const Size(400, 900),
  );
  await tester.pumpAndSettle();
  return h;
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text("Let's play"));
  await tester.tap(find.text("Let's play"));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('asks who is teeing off, and what is optional', (tester) async {
    await _pump(tester);

    expect(find.text("Who's teeing off?"), findsOneWidget);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Handicap (optional)'), findsOneWidget);
    expect(find.text('Home course (optional)'), findsOneWidget);
    expect(find.text('Only ever kept on this phone.'), findsOneWidget);
  });

  testWidgets('a name is the only thing required', (tester) async {
    final h = await _pump(tester);

    await _tapSave(tester);

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(h.location, AppRoutes.setup);
    expect(h.container.read(golferProvider), isNull);
  });

  testWidgets('a handicap, when given, must be sensible', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Sam');
    await tester.enterText(find.byType(TextField).at(1), 'lots');

    await _tapSave(tester);
    expect(find.text('Enter a number like 12 or 8.4'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '99');
    await _tapSave(tester);
    expect(find.text('Handicaps run from -10 to 54'), findsOneWidget);
  });

  testWidgets('with just a name, the golfer is set up and goes into the app', (
    tester,
  ) async {
    final h = await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), '  Sam  ');

    await _tapSave(tester);

    final golfer = h.container.read(golferProvider)!;
    expect(golfer.firstName, 'Sam');
    expect(golfer.handicap, isNull);
    expect(golfer.homeCourse, isNull);
    expect(h.location, AppRoutes.home);
    expect(currentUserDisplayName, 'Sam');
  });

  testWidgets('everything given is kept, on the phone', (tester) async {
    final h = await _pump(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Amy');
    await tester.enterText(find.byType(TextField).at(1), '8,4');
    await tester.enterText(find.byType(TextField).at(2), 'Royal Melbourne');

    await _tapSave(tester);

    final golfer = h.container.read(golferProvider)!;
    expect(golfer.handicap, 8.4);
    expect(golfer.homeCourse, 'Royal Melbourne');
    expect(currentUserHandicap, 8.4);
    final stored = decodeGolfer(h.golferStorage.document!)!;
    expect(stored.firstName, 'Amy');
    expect(stored.handicap, 8.4);
  });

  testWidgets('the avatar fills in as the name is typed', (tester) async {
    await _pump(tester);
    expect(find.text('You'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Amy');
    await tester.pumpAndSettle();

    expect(find.text('AM'), findsOneWidget);
    expect(find.text('Amy'), findsWidgets);
  });

  testWidgets('lays out on a small phone', (tester) async {
    await _pump(tester, size: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });
}
