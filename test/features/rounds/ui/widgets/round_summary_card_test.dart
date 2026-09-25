import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/ui/widgets/round_summary_card.dart';

void main() {
  testWidgets('shows course, date, players, holes, winner and status', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const RoundSummaryCard(
          courseName: 'Richmond Golf Club',
          date: 'Saturday',
          playerCount: 8,
          completedHoles: 18,
          winnerNames: 'Tom & Tiamana',
          roundStatus: 'Completed',
        ),
      ),
    );

    expect(find.text('Round Summary'), findsOneWidget);
    expect(find.text('Richmond Golf Club'), findsOneWidget);
    expect(find.text('Saturday'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Tom & Tiamana'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });
}
