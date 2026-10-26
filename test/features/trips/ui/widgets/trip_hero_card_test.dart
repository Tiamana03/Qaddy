import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_hero_card.dart';

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  bool withSnapshot = true,
  VoidCallback? onTap,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1400);
  await tester.pumpWidget(
    MaterialApp(
      theme: QaddyTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          child: TripHeroCard(
            trip: melbourneGolfWeekend,
            countdown: tripCountdown(
              melbourneGolfWeekend,
              now: DateTime(2026, 10, 26),
            ),
            snapshot: withSnapshot ? tripSnapshot(melbourneGolfWeekend) : null,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the countdown, trip facts and latest chat message', (
    tester,
  ) async {
    await _pump(tester, width: 400, onTap: () {});

    expect(find.text('NEXT TRIP'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);
    expect(find.text('days to go'), findsOneWidget);
    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('Melbourne, Australia'), findsOneWidget);
    expect(find.text('28 Nov – 1 Dec 2026  ·  4 days'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('First tee'), findsOneWidget);
    expect(find.text('Kingston Heath · 8:10 AM'), findsOneWidget);
    expect(find.text('All settled'), findsOneWidget);
    expect(find.text('8 going'), findsOneWidget);
    expect(find.text('Luke: See everyone Saturday morning.'), findsOneWidget);
    expect(find.text('View trip'), findsOneWidget);
  });

  testWidgets('shows only the essentials when the trip has no detail data', (
    tester,
  ) async {
    await _pump(tester, width: 400, withSnapshot: false);

    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('First tee'), findsNothing);
    expect(find.text('8 going'), findsNothing);
    expect(find.text('View trip'), findsNothing);
  });

  testWidgets('is tappable only when given an onTap', (tester) async {
    var taps = 0;
    await _pump(tester, width: 400, onTap: () => taps++);

    await tester.tap(find.text('Melbourne Golf Weekend'));
    expect(taps, 1);
  });

  testWidgets('puts the facts beside the headline on wide screens', (
    tester,
  ) async {
    await _pump(tester, width: 400);
    final mobileName = tester.getTopLeft(find.text('Melbourne Golf Weekend'));
    final mobileFirstTee = tester.getTopLeft(find.text('First tee'));
    expect(mobileFirstTee.dy, greaterThan(mobileName.dy));

    await _pump(tester, width: 1200);
    final wideName = tester.getTopLeft(find.text('Melbourne Golf Weekend'));
    final wideFirstTee = tester.getTopLeft(find.text('First tee'));
    expect(wideFirstTee.dx, greaterThan(wideName.dx));
  });
}
