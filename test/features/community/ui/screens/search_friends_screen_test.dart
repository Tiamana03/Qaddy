import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/search_friends_screen.dart';

void main() {
  testWidgets('shows every golfer by default and filters as you type', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const SearchFriendsScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Jack'), findsOneWidget);
    expect(find.text('Add Friend'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'tom');
    await tester.pumpAndSettle();

    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Jack'), findsNothing);
  });

  testWidgets('shows an empty state when nothing matches', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const SearchFriendsScreen()),
    );

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No golfers found'), findsOneWidget);
  });
}
