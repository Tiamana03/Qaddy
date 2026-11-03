// Verifies the real app router wires Golf Bag into Profile: Profile ->
// Golf Bag -> back, using the actual GoRouter configuration.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('Profile -> Golf Bag -> back', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('Golf bag'), findsOneWidget);

    await tester.ensureVisible(find.text('Golf bag'));
    await tester.tap(find.text('Golf bag'));
    await tester.pumpAndSettle();
    expect(find.text('STARTER BAG'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Golf bag'), findsOneWidget);
  });
}
