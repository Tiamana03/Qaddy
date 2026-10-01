import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/search/ui/screens/search_screen.dart';

void main() {
  testWidgets('shows every category by default and filters as you type', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const SearchScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Rounds'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('Courses'), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Saturday Boys'), findsOneWidget);
    expect(find.text('Kingston Heath'), findsOneWidget);
    // "Richmond Golf Club" legitimately appears twice: the Rounds result
    // (the upcoming round's course) and the Courses result sourced from
    // Profile's own Favourite Courses — see search-engineering-decisions.md
    // on why these two sources are never deduplicated.
    expect(find.text('Richmond Golf Club'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'tom');
    await tester.pumpAndSettle();

    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Saturday Boys'), findsNothing);
    expect(find.text('Rounds'), findsNothing);
    expect(find.text('Trips'), findsNothing);
    expect(find.text('Groups'), findsNothing);
    expect(find.text('Courses'), findsNothing);
  });

  testWidgets('shows an empty state when nothing matches', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const SearchScreen()),
    );

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
  });
}
