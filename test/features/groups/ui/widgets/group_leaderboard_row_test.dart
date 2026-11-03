import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/groups/ui/widgets/group_leaderboard_row.dart';

Future<void> _pump(WidgetTester tester, Widget row) => tester.pumpWidget(
  MaterialApp(
    theme: QaddyTheme.dark,
    home: Scaffold(body: Center(child: row)),
  ),
);

double _share(WidgetTester tester) => tester
    .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
    .value!;

void main() {
  testWidgets('shows rank, name and points with a bar as the leader share', (
    tester,
  ) async {
    await _pump(
      tester,
      const GroupLeaderboardRow(
        rank: 4,
        player: 'Ben',
        points: 100,
        leaderPoints: 200,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('Ben'), findsOneWidget);
    expect(find.text('100 pts'), findsOneWidget);
    expect(_share(tester), 0.5);
  });

  testWidgets('the golfer is "You"', (tester) async {
    await _pump(
      tester,
      const GroupLeaderboardRow(
        rank: 5,
        player: 'Tiamana',
        points: 97,
        leaderPoints: 118,
        isYou: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('You'), findsOneWidget);
    expect(find.text('Tiamana'), findsNothing);
  });

  testWidgets('a table with no points yet draws an empty bar', (tester) async {
    await _pump(
      tester,
      const GroupLeaderboardRow(
        rank: 4,
        player: 'Ben',
        points: 0,
        leaderPoints: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(_share(tester), 0);
  });

  testWidgets('says its place aloud', (tester) async {
    await _pump(
      tester,
      const GroupLeaderboardRow(
        rank: 5,
        player: 'Ben',
        points: 97,
        leaderPoints: 118,
      ),
    );

    expect(find.bySemanticsLabel('5th, Ben, 97 points.'), findsOneWidget);
  });
}
