import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_summary_card.dart';

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 800);
  await tester.pumpWidget(
    MaterialApp(
      theme: QaddyTheme.dark,
      home: const TripsSummaryCard(
        upcomingCount: 2,
        pastCount: 2,
        countriesCount: 2,
      ),
    ),
  );
}

void main() {
  testWidgets('shows upcoming, past and countries counts', (tester) async {
    await _pumpAtWidth(tester, 400);

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past'), findsOneWidget);
    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(3));
  });

  testWidgets('stacks vertically on mobile, horizontally on desktop', (
    tester,
  ) async {
    await _pumpAtWidth(tester, 400);
    var upcoming = tester.getTopLeft(find.text('Upcoming'));
    var past = tester.getTopLeft(find.text('Past'));
    expect(upcoming.dy, isNot(past.dy));

    await _pumpAtWidth(tester, 1200);
    upcoming = tester.getTopLeft(find.text('Upcoming'));
    past = tester.getTopLeft(find.text('Past'));
    expect(upcoming.dy, past.dy);
  });
}
