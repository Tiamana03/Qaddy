import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/search_friends_screen.dart';

import '../../../../support/app_test_harness.dart';

void main() {
  testWidgets(
    'is an honest invite, not a list of strangers with dead buttons',
    (tester) async {
      await pumpFriends(tester, const SearchFriendsScreen());

      expect(find.byType(QaddyScaffold), findsOneWidget);
      expect(find.text('Golf is better with mates'), findsOneWidget);
      expect(find.text('Invite a mate'), findsWidgets);
      expect(find.text('Add Friend'), findsNothing);
      expect(find.text('Tom'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets('shares a message about Qaddy, signed by the golfer', (
    tester,
  ) async {
    final c = await pumpFriends(tester, const SearchFriendsScreen());

    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final sent = shareOf(c).shared.single;
    expect(sent, contains('Qaddy'));
    expect(sent, endsWith('Tiamana'));
  });
}
