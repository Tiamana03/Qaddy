// Verifies Sprint 2.3's Live Scorecard: hole navigation, score entry
// bounded at 1, and running totals recalculating from in-memory state.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/ui/screens/live_scorecard_screen.dart';

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(theme: QaddyTheme.dark, home: const LiveScorecardScreen()),
  );
}

void main() {
  testWidgets('starts on hole 1 with the score defaulted to par', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Hole 1'), findsOneWidget);
    // Hole 1's par is 4 — the score stepper should start there too.
    expect(find.text('4'), findsWidgets);
    expect(find.text('Previous Hole'), findsOneWidget);
    expect(find.text('Next Hole'), findsOneWidget);
  });

  testWidgets('Next Hole advances and Previous Hole returns', (tester) async {
    await _pumpScreen(tester);

    await tester.tap(find.text('Next Hole'));
    await tester.pump();
    expect(find.text('Hole 2'), findsOneWidget);

    await tester.tap(find.text('Previous Hole'));
    await tester.pump();
    expect(find.text('Hole 1'), findsOneWidget);
  });

  testWidgets('incrementing the score updates the running total', (
    tester,
  ) async {
    await _pumpScreen(tester);

    // 18 holes at par sum to 72, so Total vs Par starts at "E".
    expect(find.text('E'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('score cannot go below 1', (tester) async {
    await _pumpScreen(tester);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
    }

    expect(find.text('1'), findsWidgets);
    expect(find.text('0'), findsNothing);
  });
}
