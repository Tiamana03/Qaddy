import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/notifications/ui/screens/notifications_screen.dart';

void main() {
  testWidgets('shows the total and every placeholder notification', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const NotificationsScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Total Notifications'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Your round starts in 2 days.'), findsOneWidget);
    expect(find.text('Josh accepted your invitation.'), findsOneWidget);
    expect(find.text('Trip payment due this Friday.'), findsOneWidget);
    expect(find.text('New version of Qaddy available.'), findsOneWidget);
  });
}
