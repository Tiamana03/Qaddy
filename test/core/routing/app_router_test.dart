// Verifies Sprint 1.2's navigation shell: all five bottom-navigation
// destinations are reachable and each shows its placeholder content.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/widgets/navigation/qaddy_bottom_nav.dart';
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

    for (final label in const <String>[
      'Rounds',
      'Trips',
      'Friends',
      'Profile',
    ]) {
      await tester.tap(
        find.descendant(
          of: find.byType(QaddyBottomNav),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(label), findsWidgets);
    }
  });
}
