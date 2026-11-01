import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/screens/activity_feed_screen.dart';

import '../../community_test_harness.dart';

void main() {
  testWidgets('shows every placeholder activity entry', (tester) async {
    await pumpFriends(tester, const ActivityFeedScreen());

    expect(find.byType(QaddyScaffold), findsOneWidget);
    for (final message in <String>[
      'Tom completed a round at Richmond Golf Club',
      'Ben joined Saturday Boys',
      "Luke's handicap improved to 5",
      'Nick created Gold Coast Golf Escape',
      'Liam unlocked Personal Best',
    ]) {
      expect(find.text(message, findRichText: true), findsOneWidget);
    }
  });

  testWidgets('every entry can be cheered', (tester) async {
    final c = await pumpFriends(tester, const ActivityFeedScreen());

    expect(find.byIcon(Icons.celebration_outlined), findsNWidgets(5));
    await tester.tap(find.text('Congrats'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(c.read(friendsProvider).cheered, contains('activity-5'));
  });
}
