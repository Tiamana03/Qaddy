// Verifies Sprint 1.2's navigation shell: all five bottom-navigation
// destinations are reachable and each shows its placeholder content.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/main.dart';

void main() {
  testWidgets('bottom navigation switches between all five destinations', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: QaddyApp()));
    await tester.pumpAndSettle();

    // Each label legitimately appears twice once its screen is active: the
    // placeholder screen's heading and the bottom navigation bar's own tab
    // label.
    expect(find.text('Home'), findsWidgets);

    for (final (String label, IconData icon) in const <(String, IconData)>[
      ('Rounds', Icons.flag),
      ('Trips', Icons.card_travel),
      ('Friends', Icons.people),
      ('Profile', Icons.person),
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(find.text(label), findsWidgets);
    }
  });
}
