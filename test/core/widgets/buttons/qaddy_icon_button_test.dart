import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_icon_button.dart';

Future<void> _pump(WidgetTester tester, Widget button) => tester.pumpWidget(
  MaterialApp(
    theme: QaddyTheme.dark,
    home: Scaffold(body: Center(child: button)),
  ),
);

void main() {
  testWidgets('shows its icon, fires when tapped and has a tooltip', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      QaddyIconButton(
        icon: Icons.search,
        tooltip: 'Search',
        onPressed: () => taps++,
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byTooltip('Search'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    expect(taps, 1);
  });

  testWidgets('can wear any face, such as a badged bell', (tester) async {
    await _pump(
      tester,
      QaddyIconButton.custom(
        tooltip: 'Notifications',
        onPressed: () {},
        child: const Text('3'),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
  });

  testWidgets('is the 48 px circle from the spacing tokens', (tester) async {
    await _pump(tester, QaddyIconButton(icon: Icons.add, onPressed: () {}));

    expect(tester.getSize(find.byType(QaddyIconButton)), const Size(48, 48));
  });
}
