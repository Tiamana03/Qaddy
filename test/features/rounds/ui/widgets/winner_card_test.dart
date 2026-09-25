import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';
import 'package:qaddy/features/rounds/ui/widgets/winner_card.dart';

void main() {
  testWidgets('shows "Winner" (singular) and the player details for one '
      'winner', (tester) async {
    const winners = <RankedLeaderboardEntry>[
      RankedLeaderboardEntry(
        position: '1',
        isLeader: true,
        entry: LeaderboardEntry(
          name: 'Tom',
          grossScore: 70,
          relativeToPar: -2,
          throughHole: 18,
        ),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const WinnerCard(winners: winners),
      ),
    );

    expect(find.text('Winner'), findsOneWidget);
    expect(find.text('Winners'), findsNothing);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
    expect(find.text('-2'), findsOneWidget);
  });

  testWidgets('shows "Winners" (plural) and every tied player on a tie', (
    tester,
  ) async {
    const winners = <RankedLeaderboardEntry>[
      RankedLeaderboardEntry(
        position: 'T1',
        isLeader: true,
        entry: LeaderboardEntry(
          name: 'Tom',
          grossScore: 70,
          relativeToPar: -2,
          throughHole: 18,
        ),
      ),
      RankedLeaderboardEntry(
        position: 'T1',
        isLeader: true,
        entry: LeaderboardEntry(
          name: 'Tiamana',
          grossScore: 70,
          relativeToPar: -2,
          throughHole: 18,
        ),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const WinnerCard(winners: winners),
      ),
    );

    expect(find.text('Winners'), findsOneWidget);
    expect(find.text('Winner'), findsNothing);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Tiamana'), findsOneWidget);
    expect(find.text('70'), findsNWidgets(2));
  });
}
