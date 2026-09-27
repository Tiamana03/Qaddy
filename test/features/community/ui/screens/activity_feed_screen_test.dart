import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/activity_feed_screen.dart';

void main() {
  testWidgets('shows every placeholder activity entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const ActivityFeedScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(
      find.text('Tom completed a round at Richmond Golf Club'),
      findsOneWidget,
    );
    expect(find.text('Ben joined Saturday Boys'), findsOneWidget);
    expect(find.text("Luke's handicap improved to 5"), findsOneWidget);
    expect(find.text('Nick created Gold Coast Golf Escape'), findsOneWidget);
    expect(find.text('Liam unlocked Personal Best'), findsOneWidget);
  });
}
