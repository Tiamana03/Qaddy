import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';

void main() {
  testWidgets('renders two-letter initials for a single-word name', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const QaddyAvatar(name: 'Tom'),
      ),
    );

    expect(find.text('TO'), findsOneWidget);
  });

  testWidgets('renders first-letter-of-each-word initials for a full name', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const QaddyAvatar(name: 'Jordan Tamaariki'),
      ),
    );

    expect(find.text('JT'), findsOneWidget);
  });

  testWidgets('is sized to spacing.display (48px, the touch-target minimum)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Center(child: QaddyAvatar(name: 'Tom')),
      ),
    );

    final size = tester.getSize(find.byType(QaddyAvatar));
    expect(
      size,
      Size(QaddySpacing.standard.display, QaddySpacing.standard.display),
    );
  });
}
