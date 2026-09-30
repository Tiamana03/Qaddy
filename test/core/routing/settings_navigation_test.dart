// Verifies the real app router wires Settings into Profile: Profile ->
// Settings -> back, using the actual GoRouter configuration.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('Profile -> Settings -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('View Settings'), findsOneWidget);

    await tester.ensureVisible(find.text('View Settings'));
    await tester.tap(find.text('View Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('View Settings'), findsOneWidget);
  });
}
