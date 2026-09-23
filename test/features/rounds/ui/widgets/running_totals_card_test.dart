import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/rounds/models/hole_score.dart';
import 'package:qaddy/features/rounds/ui/widgets/running_totals_card.dart';

List<HoleScore> _parOnlyHoles({int count = 18, int par = 4}) => <HoleScore>[
  for (var i = 1; i <= count; i++)
    HoleScore(
      holeNumber: i,
      par: par,
      strokeIndex: i,
      distance: 350,
      grossScore: par,
    ),
];

void main() {
  testWidgets('computes front 9 / back 9 / total / total vs par', (
    tester,
  ) async {
    final holes = _parOnlyHoles();
    holes[0] = holes[0].copyWithGrossScore(5); // one over par on hole 1

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: RunningTotalsCard(holes: holes),
      ),
    );

    // Front 9 = 8 holes at par 4 (32) + 1 hole at 5 = 37.
    expect(find.text('37'), findsOneWidget);
    // Back 9 = 9 holes at par 4 = 36.
    expect(find.text('36'), findsOneWidget);
    // 18-hole total = 37 + 36 = 73.
    expect(find.text('73'), findsOneWidget);
    // Total par = 72, total = 73, so total vs par = +1.
    expect(find.text('+1'), findsOneWidget);
  });
}
