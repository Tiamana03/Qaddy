import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/friend_requests_screen.dart';

void main() {
  testWidgets('shows incoming and outgoing requests', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const FriendRequestsScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Incoming'), findsOneWidget);
    expect(find.text('Outgoing'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Josh'), findsOneWidget);
  });
}
