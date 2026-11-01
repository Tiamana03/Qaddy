import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/screens/friend_requests_screen.dart';

import '../../community_test_harness.dart';

void main() {
  testWidgets('shows incoming and outgoing requests', (tester) async {
    await pumpFriends(tester, const FriendRequestsScreen());

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Incoming'), findsOneWidget);
    expect(find.text('Outgoing'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Josh'), findsOneWidget);
  });

  testWidgets('accepting a request moves it out of Incoming', (tester) async {
    final c = await pumpFriends(tester, const FriendRequestsScreen());

    await tester.tap(find.text('Accept'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sam'), findsNothing);
    expect(find.text('No incoming requests'), findsOneWidget);
    expect(c.read(confirmedFriendsProvider).map((f) => f.id), contains('sam'));
  });

  testWidgets('an answered request does not come back', (tester) async {
    await pumpFriends(tester, const FriendRequestsScreen());

    await tester.tap(find.text('Decline'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('No incoming requests'), findsOneWidget);
    expect(find.text('No outgoing requests'), findsOneWidget);
  });
}
