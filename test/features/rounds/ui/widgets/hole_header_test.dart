import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/hole_score.dart';
import 'package:qaddy/features/rounds/ui/widgets/hole_header.dart';

void main() {
  testWidgets('shows hole number, par, stroke index and distance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const HoleHeader(
          hole: HoleScore(
            holeNumber: 5,
            par: 4,
            strokeIndex: 1,
            distance: 414,
            grossScore: 4,
          ),
        ),
      ),
    );

    expect(find.text('Hole 5'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('414m'), findsOneWidget);
  });
}
