import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_welcome.dart';

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  VoidCallback? onCreate,
  ThemeData? theme,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1400);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? QaddyTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          child: TripsWelcome(onCreateTrip: onCreate ?? () {}),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('invites the golfer to plan their first trip', (tester) async {
    await _pump(tester, width: 400);

    expect(find.text('Plan your next golf trip'), findsOneWidget);
    expect(find.text('Plan every day'), findsOneWidget);
    expect(find.text('Split costs fairly'), findsOneWidget);
    expect(find.text('Keep the squad talking'), findsOneWidget);
  });

  testWidgets('the button starts Create Trip', (tester) async {
    var taps = 0;
    await _pump(tester, width: 400, onCreate: () => taps++);

    await tester.tap(find.text('Create your first trip'));

    expect(taps, 1);
  });

  for (final width in <double>[320, 400, 820, 1280]) {
    for (final (name, theme) in <(String, ThemeData)>[
      ('dark', QaddyTheme.dark),
      ('light', QaddyTheme.light),
    ]) {
      testWidgets('lays out at $width px in $name mode', (tester) async {
        await _pump(tester, width: width, theme: theme);

        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('a cover date tile shows the month and day over the cover', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: Scaffold(body: TripCoverDateTile(trip: melbourneGolfWeekend)),
      ),
    );

    expect(find.text('NOV'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
  });
}
