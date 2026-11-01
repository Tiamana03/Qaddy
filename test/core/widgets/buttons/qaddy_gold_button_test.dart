import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('is disabled without a handler', (tester) async {
    await _pump(tester, const QaddyGoldButton(label: 'Wait', onPressed: null));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('tall is a little taller than standard', (tester) async {
    await _pump(tester, QaddyGoldButton(label: 'A', onPressed: () {}));
    final standard = tester.getSize(find.byType(FilledButton)).height;

    await _pump(
      tester,
      QaddyGoldButton(label: 'A', tall: true, onPressed: () {}),
    );
    final tall = tester.getSize(find.byType(FilledButton)).height;

    expect(tall, standard + 4);
  });
}
