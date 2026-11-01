import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';

void main() {
  testWidgets('is spaced capitals in gold by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const QaddyEyebrow('NEXT')),
    );

    final text = tester.widget<Text>(find.text('NEXT'));
    final gold = QaddyTheme.dark.extension<QaddyColours>()!.gold;

    expect(text.style!.letterSpacing, 1.5);
    expect(text.style!.fontWeight, FontWeight.w600);
    expect(text.style!.color, gold);
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
