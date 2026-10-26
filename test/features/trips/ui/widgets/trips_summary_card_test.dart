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
      home: const Scaffold(
        body: TripsSummaryCard(
          upcomingCount: 3,
          pastCount: 5,
          countriesCount: 2,
        ),
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
    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('stays one compact row at every width', (tester) async {
    for (final width in <double>[360, 700, 1200]) {
      await _pumpAtWidth(tester, width);
      final upcoming = tester.getTopLeft(find.text('Upcoming'));
      final past = tester.getTopLeft(find.text('Past'));
      final countries = tester.getTopLeft(find.text('Countries'));
      expect(upcoming.dy, past.dy);
      expect(past.dy, countries.dy);
    }
  });

  testWidgets('reads as a single sentence to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpAtWidth(tester, 400);

    expect(
      find.bySemanticsLabel(
        '3 upcoming trips, 5 past trips, 2 countries visited',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
