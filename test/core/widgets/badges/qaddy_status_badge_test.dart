import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const QaddyStatusBadge(label: 'Upcoming'),
      ),
    );

    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('fills with the colour matching its tone', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const QaddyStatusBadge(
          label: 'Completed',
          tone: QaddyStatusBadgeTone.success,
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = decoratedBox.decoration as BoxDecoration;
    expect(decoration.color, QaddyColours.dark.success);
  });
}
