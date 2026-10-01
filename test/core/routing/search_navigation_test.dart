// Verifies the real app router wires Search into Dashboard: Dashboard ->
// Search -> back, using the actual GoRouter configuration.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('Dashboard -> Search -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Good Morning,'), findsOneWidget);
  });
}
