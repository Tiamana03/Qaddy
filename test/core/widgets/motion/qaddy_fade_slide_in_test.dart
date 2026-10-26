import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';

Widget _app({required bool disableAnimations}) => MaterialApp(
  theme: QaddyTheme.dark,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
    child: child!,
  ),
  home: const Scaffold(body: QaddyFadeSlideIn(child: Text('Hello'))),
);

void main() {
  testWidgets('fades in from transparent and settles fully opaque', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: false));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);

    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('skips the animation when reduced motion is requested', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: true));

    expect(find.byType(Opacity), findsNothing);
    expect(find.text('Hello'), findsOneWidget);
  });
}
