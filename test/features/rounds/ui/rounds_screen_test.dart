// Verifies Sprint 2.2's Round Setup screen: placeholder content renders
// and the primary actions are visual-only (no onPressed wired up).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/ui/screens/rounds_screen.dart';

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 2000);
  await tester.pumpWidget(
    MaterialApp(theme: QaddyTheme.dark, home: const RoundsScreen()),
  );
}

void main() {
  testWidgets('uses QaddyScaffold and shows every placeholder section', (
    tester,
  ) async {
    await _pumpAtWidth(tester, 400);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Rounds'), findsOneWidget);
    // "Richmond Golf Club" legitimately appears twice: the Upcoming Round
    // Card's heading and the Round Information section's Course row.
    expect(find.text('Richmond Golf Club'), findsNWidgets(2));
    expect(find.text('21°C Sunny'), findsOneWidget);
    // "Players" legitimately appears twice: the Upcoming Round Card's field
    // label and the Players Section's own heading.
    expect(find.text('Players'), findsNWidgets(2));
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('HCP 8'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Round Information'), findsOneWidget);
    expect(find.text('Stableford'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Side Games'), findsOneWidget);
    expect(find.text('Hole 5'), findsOneWidget);
    expect(find.text('Start Round'), findsOneWidget);
    expect(find.text('Edit Round'), findsOneWidget);
    expect(find.text('Cancel Round'), findsOneWidget);
  });

  testWidgets('Primary Actions are visual only', (tester) async {
    await _pumpAtWidth(tester, 400);

    final button = tester.widget<QaddyPrimaryButton>(
      find.byType(QaddyPrimaryButton),
    );
    expect(button.onPressed, isNull);
  });
}
