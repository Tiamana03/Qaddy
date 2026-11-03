// Verifies the real app router wires the full Friends feature together:
// Friends -> Friends List -> Friend Profile -> Activity Feed -> back, and
// Friends -> Groups -> Group Details -> back, using the actual GoRouter
// configuration (not a test-only stub).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('Friends -> Friends List -> Friend Profile -> Activity -> back', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();
    expect(find.text('Your squad'), findsOneWidget);

    await tester.tap(find.byTooltip('All friends'));
    await tester.pumpAndSettle();
    expect(find.text('Friends List'), findsOneWidget);

    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    expect(find.text('Head to head'), findsOneWidget);

    await tester.ensureVisible(find.text('Activity'));
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Tom completed a round at Richmond Golf Club',
        findRichText: true,
      ),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Head to head'), findsOneWidget);
  });

  testWidgets('Friends -> Groups -> Group Details -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();

    // Your clubs is the last section on Friends Home.
    await tester.ensureVisible(find.text('See all').last);
    await tester.tap(find.text('See all').last);
    await tester.pumpAndSettle();
    expect(find.text('Saturday Boys'), findsOneWidget);

    await tester.tap(find.text('Saturday Boys'));
    await tester.pumpAndSettle();
    expect(find.text('The squad'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Wednesday Warriors'), findsOneWidget);
  });

  testWidgets('Dashboard "From your mates" opens Friends Home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('See all'));
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    expect(find.text('Your squad'), findsOneWidget);
  });
}
