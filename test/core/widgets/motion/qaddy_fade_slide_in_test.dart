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

  testWidgets('waits out its delay before starting to appear', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Scaffold(
          body: QaddyFadeSlideIn(
            delay: Duration(milliseconds: 400),
            child: Text('Later'),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);

    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
  });

  test('staggerDelay grows by a step per item and then stops growing', () {
    expect(staggerDelay(0), Duration.zero);
    expect(staggerDelay(1), const Duration(milliseconds: 70));
    expect(staggerDelay(3), const Duration(milliseconds: 210));
    expect(staggerDelay(6), const Duration(milliseconds: 420));
    expect(staggerDelay(40), const Duration(milliseconds: 420));
  });

  testWidgets('staggered wraps content but leaves plain spacers alone', (
    tester,
  ) async {
    final wrapped = staggered(<Widget>[
      const SizedBox(height: 8),
      const Text('A'),
      const Text('B'),
    ]);

    expect(wrapped, hasLength(3));
    expect(wrapped[0], isA<SizedBox>());
    expect(wrapped[1], isA<QaddyFadeSlideIn>());
    expect((wrapped[2] as QaddyFadeSlideIn).delay, staggerDelay(1));
  });
}
