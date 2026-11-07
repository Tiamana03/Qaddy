import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_hero_card.dart';

final DateTime _now = DateTime(2026, 10, 26);

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  bool withSnapshot = true,
  bool settle = true,
  DateTime? now,
  VoidCallback? onTap,
}) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 2000);
  final moment = now ?? _now;
  await tester.pumpWidget(
    MaterialApp(
      theme: QaddyTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          child: TripHeroCard(
            trip: melbourneGolfWeekend,
            countdown: tripCountdown(melbourneGolfWeekend, now: moment),
            snapshot: withSnapshot
                ? tripSnapshot(
                    melbourneGolfWeekendPlan,
                    trip: melbourneGolfWeekend,
                    now: moment,
                  )
                : null,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
  if (settle) {
    // The ticker's timer never settles, so settle with a fixed span.
    await tester.pump(const Duration(seconds: 4));
  }
}

void main() {
  testWidgets('shows the countdown and the trip facts', (tester) async {
    await _pump(tester, width: 400, onTap: () {});

    expect(find.text('Next trip'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);
    expect(find.text('days to go'), findsOneWidget);
    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('Melbourne, Australia'), findsOneWidget);
    expect(find.text('28 Nov – 1 Dec 2026  ·  4 days'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('View trip'), findsOneWidget);
  });

  testWidgets('leads with what happens next', (tester) async {
    await _pump(tester, width: 400);

    expect(find.text('Up next'), findsOneWidget);
    expect(find.text('Qantas QF431'), findsOneWidget);
    expect(find.text('Sat 28 Nov · 8:30 AM'), findsOneWidget);
  });

  testWidgets('keeps to the headline: no tiles, no ticker', (tester) async {
    await _pump(tester, width: 400);

    // The trip's own page holds these.
    for (final label in <String>['First tee', 'Next task', 'Money', 'Squad']) {
      expect(find.text(label), findsNothing, reason: label);
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('Luke:'), findsNothing);
  });

  testWidgets('shows planning progress as a ring', (tester) async {
    await _pump(tester, width: 400);

    expect(find.byType(PlanningRing), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('counts up to the number of days', (tester) async {
    await _pump(tester, width: 400, settle: false);

    // Before the animation has run the number is still on its way up.
    expect(find.text('33'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('33'), findsOneWidget);
  });

  testWidgets('builds anticipation as the trip gets close', (tester) async {
    await _pump(tester, width: 400, now: DateTime(2026, 11, 24));

    expect(find.text('Get ready'), findsOneWidget);
    expect(find.text('Next trip'), findsNothing);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('says so on the day, and while the trip is underway', (
    tester,
  ) async {
    await _pump(tester, width: 400, now: DateTime(2026, 11, 28, 6));
    expect(find.text("It's trip day"), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    await _pump(tester, width: 400, now: DateTime(2026, 11, 29, 9));
    expect(find.text('Live now'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
  });

  testWidgets('shows only the essentials when the trip has no detail data', (
    tester,
  ) async {
    await _pump(tester, width: 400, withSnapshot: false);

    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('First tee'), findsNothing);
    expect(find.text('Up next'), findsNothing);
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
}
