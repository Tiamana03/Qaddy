// Verifies the real app router wires Statistics into Profile: Profile ->
// Statistics -> back, using the actual GoRouter configuration.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('Profile -> Statistics -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('My stats'), findsOneWidget);

    await tester.ensureVisible(find.text('My stats'));
    await tester.tap(find.text('My stats'));
    await tester.pumpAndSettle();
    expect(find.text('Your story starts on the first tee'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('My stats'), findsOneWidget);
  });
}
