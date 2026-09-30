import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/statistics/ui/screens/statistics_screen.dart';

void main() {
  testWidgets('shows every placeholder statistics section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const StatisticsScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);

    // Career Totals — computed from Profile, not duplicated.
    expect(find.text('Career Totals'), findsOneWidget);
    // "Rounds Played" appears twice: Career Totals and Rivalry Performance
    // (a different concept that happens to share the same label).
    expect(find.text('Rounds Played'), findsNWidgets(2));
    expect(find.text('68'), findsOneWidget);

    // Scoring Statistics + Scoring Breakdown.
    expect(find.text('Scoring Statistics'), findsOneWidget);
    // "83" appears twice: Scoring Statistics' Average Score row and the
    // Trends card's Average Score value.
    expect(find.text('83'), findsNWidgets(2));
    expect(find.text('Scoring Breakdown'), findsOneWidget);
    // "37" appears twice: Birdies (Scoring Breakdown) and Best Front Nine
    // (Personal Records) happen to share the same value.
    expect(find.text('37'), findsNWidgets(2));

    // Trends — the two-point deltas via QaddyStatisticCard.
    expect(find.text('Trends'), findsOneWidget);
    expect(find.text('Handicap'), findsOneWidget);
    expect(find.text('8.4'), findsOneWidget);
    expect(find.text('↓1.2 (Last 3 months)'), findsOneWidget);
    expect(find.text('↓3 (Last 3 months)'), findsOneWidget);

    // Personal Records.
    expect(find.text('Personal Records'), findsOneWidget);
    expect(find.text('312m'), findsOneWidget);

    // Season Performance — full leaderboard, not just Tiamana's row.
    expect(find.text('Season Performance'), findsOneWidget);
    expect(find.text('Saturday Boys'), findsOneWidget);
    // "Luke" appears twice: the season Leader row and his own leaderboard
    // entry (he holds both).
    expect(find.text('Luke'), findsNWidgets(2));
    expect(find.text('Sam'), findsOneWidget);

    // Rivalry Performance.
    expect(find.text('Rivalry Performance'), findsOneWidget);
    expect(find.text('You vs Tom'), findsOneWidget);
    expect(find.text('Won by 2 strokes at Richmond Golf Club'), findsOneWidget);
  });
}
