import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';
import 'package:qaddy/features/rounds/ui/widgets/leaderboard_row.dart';

void main() {
  testWidgets('shows position, name, gross score, relative to par and '
      'through-hole progress', (tester) async {
    const ranked = RankedLeaderboardEntry(
      position: 'T1',
      isLeader: true,
      entry: LeaderboardEntry(
        name: 'Tom',
        grossScore: 70,
        relativeToPar: -2,
        throughHole: 18,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const LeaderboardRow(ranked: ranked),
      ),
    );

    expect(find.text('T1'), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
    expect(find.text('-2'), findsOneWidget);
    expect(find.text('Thru 18'), findsOneWidget);
  });

  testWidgets('shows "E" for a player level with par', (tester) async {
    const ranked = RankedLeaderboardEntry(
      position: '4',
      isLeader: false,
      entry: LeaderboardEntry(
        name: 'Even Player',
        grossScore: 72,
        relativeToPar: 0,
        throughHole: 18,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const LeaderboardRow(ranked: ranked),
      ),
    );

    expect(find.text('E'), findsOneWidget);
  });
}
