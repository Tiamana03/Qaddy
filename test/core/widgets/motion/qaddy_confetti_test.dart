import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/motion/qaddy_confetti.dart';

Widget _app({bool reduceMotion = false}) => MaterialApp(
  theme: QaddyTheme.dark,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: const Scaffold(
      body: Stack(children: <Widget>[Positioned.fill(child: QaddyConfetti())]),
    ),
  ),
);

void main() {
  testWidgets('falls once and then stops', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CustomPaint), findsWidgets);

    // pumpAndSettle fails if the burst never ends.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not take taps', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.byType(IgnorePointer), findsWidgets);
  });

  testWidgets('is skipped when motion is reduced', (tester) async {
    await tester.pumpWidget(_app(reduceMotion: true));

    expect(tester.hasRunningAnimations, isFalse);
  });
}
