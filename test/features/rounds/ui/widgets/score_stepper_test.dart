import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/ui/widgets/score_stepper.dart';

void main() {
  testWidgets('tapping + calls onIncrement', (tester) async {
    var incremented = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: ScoreStepper(
          score: 4,
          onIncrement: () => incremented = true,
          onDecrement: () {},
        ),
      ),
    );

    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(incremented, isTrue);
  });

  testWidgets('tapping - calls onDecrement', (tester) async {
    var decremented = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: ScoreStepper(
          score: 4,
          onIncrement: () {},
          onDecrement: () => decremented = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(decremented, isTrue);
  });

  testWidgets('decrement control is disabled when onDecrement is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: ScoreStepper(score: 1, onIncrement: () {}, onDecrement: null),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    // Score stays at 1 — nothing happened because onDecrement was null.
    expect(find.text('1'), findsOneWidget);
  });
}
