import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/screens/trip_golf_schedule_screen.dart';

void main() {
  testWidgets('shows courses, playing groups and side games', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const TripGolfScheduleScreen()),
    );

    expect(find.text('Kingston Heath'), findsOneWidget);
    expect(find.text('Group 1'), findsOneWidget);
    expect(find.text('Tiamana, Ben, Luke, Josh'), findsOneWidget);
    expect(find.text('Longest Drive'), findsOneWidget);
    expect(find.text('Hole 5'), findsOneWidget);
  });
}
