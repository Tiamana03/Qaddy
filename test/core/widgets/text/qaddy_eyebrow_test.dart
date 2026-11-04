import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';

void main() {
  testWidgets('is calm sentence-case text in the accent colour by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const QaddyEyebrow('Next')),
    );

    final text = tester.widget<Text>(find.text('Next'));
    final accent = QaddyTheme.dark.extension<QaddyColours>()!.accent;

    expect(text.style!.letterSpacing, isNull);
    expect(text.style!.fontSize, 14);
    expect(text.style!.fontWeight, FontWeight.w600);
    expect(text.style!.color, accent);
  });

  testWidgets('takes another colour and can be limited to a line', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const QaddyEyebrow('LIVE', colour: Colors.red, maxLines: 1),
      ),
    );

    final text = tester.widget<Text>(find.text('LIVE'));
    expect(text.style!.color, Colors.red);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });
}
