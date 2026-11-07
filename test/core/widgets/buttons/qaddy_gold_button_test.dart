import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';

Future<void> _pump(WidgetTester tester, Widget button) => tester.pumpWidget(
  MaterialApp(
    theme: QaddyTheme.dark,
    home: Scaffold(
      body: Center(child: SizedBox(width: 300, child: button)),
    ),
  ),
);

Size _size(WidgetTester tester) => tester.getSize(find.byType(QaddyGoldButton));

void main() {
  testWidgets('shows its label and fires when tapped', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      QaddyGoldButton(label: 'Get ready', onPressed: () => taps++),
    );

    await tester.tap(find.text('Get ready'));

    expect(taps, 1);
  });

  testWidgets('can carry a leading icon', (tester) async {
    await _pump(
      tester,
      QaddyGoldButton(label: 'Send', icon: Icons.send, onPressed: () {}),
    );

    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('is disabled without a handler, in the disabled colours', (
    tester,
  ) async {
    await _pump(tester, const QaddyGoldButton(label: 'Wait', onPressed: null));
    const colours = QaddyColours.dark;

    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(QaddyGoldButton),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.gradient, isNull);
    expect(decoration.color, colours.disabledBackground);
  });

  testWidgets('is the Gold Gradient token when enabled', (tester) async {
    await _pump(tester, QaddyGoldButton(label: 'Go', onPressed: () {}));

    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(QaddyGoldButton),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (box.decoration as BoxDecoration).gradient,
      QaddyColours.dark.gradientGold,
    );
  });

  testWidgets('has the Buttons Library heights: 48, 56, and a 36 pill', (
    tester,
  ) async {
    await _pump(tester, QaddyGoldButton(label: 'A', onPressed: () {}));
    expect(_size(tester).height, QaddyButtonHeight.medium);

    await _pump(
      tester,
      QaddyGoldButton(label: 'A', tall: true, onPressed: () {}),
    );
    expect(_size(tester).height, QaddyButtonHeight.large);

    await _pump(
      tester,
      QaddyGoldButton(label: 'A', compact: true, onPressed: () {}),
    );
    // The compact button is the mockups' 36-tall pill.
    expect(_size(tester).height, 36);
  });
}
