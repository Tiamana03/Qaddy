import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/features/trips/models/trip.dart';

void main() {
  final trip = Trip(
    id: 'melbourne',
    name: 'Melbourne Golf Weekend',
    destination: 'Melbourne, Australia',
    country: 'Australia',
    startDate: DateTime(2026, 11, 28),
    endDate: DateTime(2026, 12),
    status: TripStatus.confirmed,
    organiserId: 'Tiamana',
    playerCount: 8,
  );

  testWidgets('shows name, destination, dates, player count and status', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: QaddyTripCard(trip: trip),
      ),
    );

    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('Melbourne, Australia'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.textContaining('8 Players'), findsOneWidget);
  });

  testWidgets('shows a chevron only when tappable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: QaddyTripCard(trip: trip),
      ),
    );
    expect(find.byIcon(Icons.chevron_right), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: QaddyTheme.dark,
        home: QaddyTripCard(trip: trip, onTap: () {}),
      ),
    );
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
