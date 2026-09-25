import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/screens/trip_travel_screen.dart';

void main() {
  testWidgets('shows flight and airport transfer details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: QaddyTheme.dark, home: const TripTravelScreen()),
    );

    expect(find.text('Qantas QF431'), findsOneWidget);
    expect(find.text('Sydney 8:30 AM'), findsOneWidget);
    expect(find.text('Melbourne 10:05 AM'), findsOneWidget);
    expect(find.text('Melbourne Airport → RACV Healesville'), findsOneWidget);
  });
}
