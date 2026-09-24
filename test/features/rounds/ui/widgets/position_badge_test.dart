import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/ui/widgets/position_badge.dart';

void main() {
  testWidgets('renders the position text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const PositionBadge(position: 'T1', isLeader: true),
      ),
    );

    expect(find.text('T1'), findsOneWidget);
  });

  testWidgets('the leader is filled with gold, others with the surface '
      'colour', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const PositionBadge(position: '1', isLeader: true),
      ),
    );
    var container = tester.widget<Container>(find.byType(Container));
    var decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, QaddyColours.dark.gold);

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const PositionBadge(position: '3', isLeader: false),
      ),
    );
    container = tester.widget<Container>(find.byType(Container));
    decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, QaddyColours.dark.surface1);
  });
}
