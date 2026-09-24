// Verifies Sprint 2.4's Live Leaderboard: every placeholder player renders,
// ranked and tied correctly per placeholder-data.md's Leaderboard table.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/rounds/ui/screens/leaderboard_screen.dart';

void main() {
  testWidgets('uses QaddyScaffold and shows every placeholder player', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const LeaderboardScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);

    for (final name in <String>[
      'Tom',
      'Tiamana',
      'Josh',
      'Nick',
      'Luke',
      'Ben',
      'Liam',
      'Sam',
    ]) {
      expect(find.text(name), findsOneWidget);
    }

    // Tom and Tiamana are tied for first.
    expect(find.text('T1'), findsNWidgets(2));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });
}
