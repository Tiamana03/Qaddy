import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/ui/screens/rivalries_screen.dart';

void main() {
  testWidgets('shows the head-to-head record against Tom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const RivalriesScreen()),
    );

    expect(find.byType(QaddyScaffold), findsOneWidget);
    expect(find.text('You vs Tom'), findsOneWidget);
    expect(find.text('Rounds Played'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Wins'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Won by 2 strokes at Richmond Golf Club'), findsOneWidget);
  });
}
