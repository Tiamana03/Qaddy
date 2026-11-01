import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';

void main() {
  testWidgets('shows its icon and fact', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Center(
          child: QaddyInfoChip(icon: Icons.wb_sunny_outlined, text: '21°C'),
        ),
      ),
    );

    expect(find.text('21°C'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
  });

  testWidgets('a long fact is ellipsised, not overflowed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Center(
          child: SizedBox(
            width: 120,
            child: QaddyInfoChip(
              icon: Icons.flag,
              text: 'Nearest the Pin on this very long hole',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
