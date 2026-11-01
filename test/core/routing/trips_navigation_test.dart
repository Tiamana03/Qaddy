// Verifies the real app router wires the full Trips feature together:
// Trips -> Trip Details -> a sub-screen -> back to Trip Details, using the
// actual GoRouter configuration (not a test-only stub).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('Trips -> Trip Details -> Golf Schedule -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.card_travel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Melbourne Golf Weekend'));
    await tester.pumpAndSettle();
    expect(find.text('The Trip'), findsOneWidget);

    await tester.ensureVisible(find.text('Golf'));
    await tester.tap(find.text('Golf'));
    await tester.pumpAndSettle();
    expect(find.text('Playing Groups'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('The Trip'), findsOneWidget);
  });

  testWidgets('Complete Trip -> Return Home returns to the Dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.card_travel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Melbourne Golf Weekend'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Complete Trip'));
    await tester.tap(find.text('Complete Trip'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Return Home'));
    await tester.tap(find.text('Return Home'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR GAME'), findsOneWidget);
  });
}
