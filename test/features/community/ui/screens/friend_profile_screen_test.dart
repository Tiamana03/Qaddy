import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/friend_profile_screen.dart';

void main() {
  testWidgets(
    'shows home club, location, handicap, history and quick actions',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: QaddyTheme.dark, home: const FriendProfileScreen()),
      );

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Tom'), findsWidgets);
      expect(find.text('Richmond Golf Club'), findsOneWidget);
      expect(find.text('Richmond, VIC'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Rounds Played Together'), findsOneWidget);
      expect(find.text('View Activity'), findsOneWidget);
      expect(find.text('View Rivalry'), findsOneWidget);
    },
  );
}
