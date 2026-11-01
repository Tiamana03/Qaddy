import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';

Widget _card({VoidCallback? onTap, VoidCallback? onFooter}) => MaterialApp(
  theme: QaddyTheme.dark,
  home: Scaffold(
    body: SingleChildScrollView(
      child: QaddyHeroCard(
        gradient: const LinearGradient(
          colors: <Color>[Colors.green, Colors.teal],
        ),
        semanticLabel: 'The story',
        onTap: onTap ?? () {},
        footer: onFooter == null
            ? null
            : TextButton(onPressed: onFooter, child: const Text('Footer')),
        child: const Text('Story'),
      ),
    ),
  ),
);

void main() {
  testWidgets('tapping the story calls onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_card(onTap: () => taps++));

    await tester.tap(find.text('Story'));

    expect(taps, 1);
  });

  testWidgets('the footer is its own control, outside the story tap', (
    tester,
  ) async {
    var story = 0;
    var footer = 0;
    await tester.pumpWidget(
      _card(onTap: () => story++, onFooter: () => footer++),
    );

    await tester.tap(find.text('Footer'));

    expect(footer, 1);
    expect(story, 0);
  });

  testWidgets('has no footer unless given one', (tester) async {
    await tester.pumpWidget(_card());

    expect(find.text('Footer'), findsNothing);
  });

  testWidgets('reads the story as a single button', (tester) async {
    await tester.pumpWidget(_card());

    expect(find.bySemanticsLabel('The story'), findsOneWidget);
  });

  testWidgets('without onTap the story is not a button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Scaffold(
          body: QaddyHeroCard(
            gradient: LinearGradient(
              colors: <Color>[Colors.green, Colors.teal],
            ),
            child: Text('Story'),
          ),
        ),
      ),
    );

    expect(find.text('Story'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(QaddyHeroCard),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });
}
