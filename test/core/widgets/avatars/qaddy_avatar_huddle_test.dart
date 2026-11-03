import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar_huddle.dart';

Future<void> _pump(WidgetTester tester, List<String> names, int total) =>
    tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: Scaffold(
          body: QaddyAvatarHuddle(
            names: names,
            total: total,
            textColour: Colors.white,
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows at most five faces and counts the rest', (tester) async {
    await _pump(tester, <String>['A', 'B', 'C', 'D', 'E', 'F', 'G'], 8);

    expect(find.byType(QaddyAvatar), findsNWidgets(5));
    expect(find.text('+3 more · 8 playing'), findsOneWidget);
  });

  testWidgets('with everyone shown, just says how many', (tester) async {
    await _pump(tester, <String>['A', 'B', 'C'], 3);

    expect(find.byType(QaddyAvatar), findsNWidgets(3));
    expect(find.text('3 playing'), findsOneWidget);
  });

  testWidgets('can say something else beside the faces', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const Scaffold(
          body: QaddyAvatarHuddle(
            names: <String>['A', 'B'],
            total: 8,
            textColour: Colors.white,
            label: '8 members · 2026 Season',
          ),
        ),
      ),
    );

    expect(find.text('8 members · 2026 Season'), findsOneWidget);
    expect(find.textContaining('playing'), findsNothing);
  });
}
