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
    expect(find.text('Quick Actions'), findsOneWidget);

    await tester.tap(find.text('View Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Friends List'), findsOneWidget);

    await tester.tap(find.text('Tom'));
    await tester.pumpAndSettle();
    expect(find.text('Shared History'), findsOneWidget);

    await tester.ensureVisible(find.text('View Activity'));
    await tester.tap(find.text('View Activity'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tom completed a round at Richmond Golf Club'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Shared History'), findsOneWidget);
  });

  testWidgets('Friends -> Groups -> Group Details -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expect(find.text('Saturday Boys'), findsOneWidget);

    await tester.tap(find.text('Saturday Boys'));
    await tester.pumpAndSettle();
    expect(find.text('Season Summary'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Wednesday Warriors'), findsOneWidget);
  });

  testWidgets('Dashboard Friends quick action opens Friends Home', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    // The Quick Action tile's icon (`diversity_3`) is distinct from the
    // bottom nav's Friends tab icon (`people`), disambiguating the two
    // "Friends"-labelled controls on this screen.
    await tester.tap(find.byIcon(Icons.diversity_3));
    await tester.pumpAndSettle();

    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
