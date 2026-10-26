import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_hero_card.dart';

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  bool withSnapshot = true,
  bool settle = true,
  VoidCallback? onTap,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1800);
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
            snapshot: withSnapshot
                ? tripSnapshot(melbourneGolfWeekendPlan)
                : null,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('shows the countdown and the trip facts', (tester) async {
    await _pump(tester, width: 400, onTap: () {});

    expect(find.text('NEXT TRIP'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);
    expect(find.text('days to go'), findsOneWidget);
    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('Melbourne, Australia'), findsOneWidget);
    expect(find.text('28 Nov – 1 Dec 2026  ·  4 days'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('View trip'), findsOneWidget);
  });

  testWidgets('shows the course, weather, task, payment and budget', (
    tester,
  ) async {
    await _pump(tester, width: 400);

    // A course logo placeholder leads the first tee.
    expect(find.text('First tee'), findsOneWidget);
    expect(find.text('Kingston Heath · 8:10 AM'), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    // The weather has its icon.
    expect(find.text('Saturday forecast'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
    expect(find.text('Next task: Reserve Sunday dinner'), findsOneWidget);
    expect(find.textContaining(r'You owe Ben $730'), findsOneWidget);
    expect(find.text(r'52% paid · $5,540 to go'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows planning progress, players, invites and latest news', (
    tester,
  ) async {
    await _pump(tester, width: 400);

    expect(find.byType(PlanningRing), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('8 going · 1 invited'), findsOneWidget);
    expect(
      find.text('Royal Melbourne tee time moved to 8:00 AM'),
      findsOneWidget,
    );
    expect(find.text('Luke: See everyone Saturday morning.'), findsOneWidget);
  });

  testWidgets('counts up to the number of days', (tester) async {
    await _pump(tester, width: 400, settle: false);

    // Before the animation has run the number is still on its way up.
    expect(find.text('33'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('33'), findsOneWidget);
  });

  testWidgets('skips the animation when the user prefers reduced motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await _pump(tester, width: 400, settle: false);

    expect(find.text('33'), findsOneWidget);
  });

  testWidgets('shows only the essentials when the trip has no detail data', (
    tester,
  ) async {
    await _pump(tester, width: 400, withSnapshot: false);

    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('First tee'), findsNothing);
    expect(find.byType(PlanningRing), findsNothing);
    expect(find.textContaining('going'), findsNothing);
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
