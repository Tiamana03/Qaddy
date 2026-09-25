import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/features/trips/ui/screens/trip_accommodation_screen.dart';

void main() {
  testWidgets('shows hotel, check-in/out, address and contact', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: const TripAccommodationScreen(),
      ),
    );

    expect(find.text('RACV Healesville Resort'), findsOneWidget);
    expect(find.text('28 November'), findsOneWidget);
    expect(find.text('1 December'), findsOneWidget);
    expect(
      find.text('122 Healesville-Kinglake Road, Healesville VIC'),
      findsOneWidget,
    );
    expect(find.text('(03) 5962 4899'), findsOneWidget);
  });
}
