import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/groups/ui/screens/group_details_screen.dart';

void main() {
  testWidgets(
    'shows overview, members, season summary, leaderboard and upcoming round',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: QaddyTheme.dark, home: const GroupDetailsScreen()),
      );

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Tiamana'), findsWidgets);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Season Summary'), findsOneWidget);
      expect(find.text('2026 Season'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Upcoming Group Round'), findsOneWidget);
      // Appears twice: the group's home course and the upcoming round's
      // course happen to be the same club.
      expect(find.text('Richmond Golf Club'), findsNWidgets(2));
    },
  );
}
