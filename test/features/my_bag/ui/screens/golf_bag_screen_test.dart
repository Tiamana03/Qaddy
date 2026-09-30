import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/my_bag/ui/screens/golf_bag_screen.dart';

void main() {
  testWidgets('shows bag summary, equipment and club distances', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const GolfBagScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);

    // Bag Summary.
    expect(find.text('Bag Summary'), findsOneWidget);
    expect(find.text('Total Clubs'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Longest Average Distance'), findsOneWidget);
    expect(find.text('Driver — 235m'), findsOneWidget);

    // Equipment — reused from Profile, not duplicated.
    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('TaylorMade Qi35'), findsOneWidget);
    expect(find.text('TaylorMade P790'), findsOneWidget);
    expect(find.text('Cleveland RTX'), findsOneWidget);
    expect(find.text('Odyssey White Hot'), findsOneWidget);
    expect(find.text('Titleist Pro V1'), findsOneWidget);

    // Club Distances — only Driver, Irons and Wedges (no Putter/Ball).
    expect(find.text('Club Distances'), findsOneWidget);
    expect(find.text('145m'), findsOneWidget);
    expect(find.text('95m'), findsOneWidget);
  });
}
