import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';

void main() {
  testWidgets('is a round badge of the given size holding the icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Center(
          child: QaddyIconBadge(icon: Icons.star, colour: Colors.amber),
        ),
      ),
    );

    expect(tester.getSize(find.byType(QaddyIconBadge)), const Size(40, 40));
    final icon = tester.widget<Icon>(find.byIcon(Icons.star));
    expect(icon.color, Colors.amber);
  });

  testWidgets('honours size and iconSize', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Center(
          child: QaddyIconBadge(
            icon: Icons.star,
            colour: Colors.amber,
            size: 44,
            iconSize: 20,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(QaddyIconBadge)), const Size(44, 44));
    expect(tester.widget<Icon>(find.byIcon(Icons.star)).size, 20);
  });
}
