import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/screens/trip_planning_screen.dart';

void main() {
  testWidgets('shows itinerary, flights, accommodation, transport and '
      'courses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const TripPlanningScreen()),
    );

    expect(find.text('Itinerary'), findsOneWidget);
    expect(find.textContaining('Arrive Melbourne'), findsOneWidget);
    expect(find.text('Flights'), findsOneWidget);
    expect(find.text('Accommodation'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Courses & Tee Times'), findsOneWidget);
    expect(find.text('Kingston Heath'), findsOneWidget);
  });
}
