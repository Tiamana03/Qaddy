// Verifies Sprint 2.1's Dashboard: placeholder content renders and the
// Quick Actions / Statistics Preview grids adapt to the current breakpoint.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/dashboard/ui/screens/dashboard_screen.dart';

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 1400);
  await tester.pumpWidget(
    MaterialApp(theme: QaddyTheme.dark, home: const DashboardScreen()),
  );
}

void main() {
  testWidgets('uses QaddyScaffold and shows every placeholder section', (
    tester,
  ) async {
    await _pumpAtWidth(tester, 400);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Tiamana'), findsOneWidget);
    expect(find.text('Richmond Golf Club'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('The Dunes Golf Links'), findsOneWidget);
    expect(find.text('View Summary'), findsOneWidget);
    expect(find.text('Rounds Played'), findsOneWidget);
    expect(find.text('68'), findsOneWidget);
    expect(find.text('Achievement unlocked: Personal Best'), findsOneWidget);
  });

  testWidgets('Quick Actions collapse to two per row on mobile', (
    tester,
  ) async {
    await _pumpAtWidth(tester, 400);

    final createRoundOffset = tester.getTopLeft(find.text('Create Round'));
    final continueRoundOffset = tester.getTopLeft(find.text('Continue Round'));
    final statisticsOffset = tester.getTopLeft(find.text('Statistics'));

    expect(createRoundOffset.dy, continueRoundOffset.dy);
    expect(statisticsOffset.dy, greaterThan(createRoundOffset.dy));
  });

  testWidgets('Quick Actions render in a single row on desktop', (
    tester,
  ) async {
    await _pumpAtWidth(tester, 1200);

    final createRoundOffset = tester.getTopLeft(find.text('Create Round'));
    final friendsOffset = tester.getTopLeft(find.text('Friends'));

    expect(createRoundOffset.dy, friendsOffset.dy);
  });
}
