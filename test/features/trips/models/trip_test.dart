import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/models/trip.dart';

void main() {
  test('durationInDays is inclusive of both the start and end date', () {
    final trip = Trip(
      id: 'test',
      name: 'Test Trip',
      destination: 'Test',
      country: 'Test',
      startDate: DateTime(2026, 11, 28),
      endDate: DateTime(2026, 12),
      status: TripStatus.confirmed,
      organiserId: 'Tester',
      playerCount: 8,
    );

    expect(trip.durationInDays, 4);
  });

  test('daysUntilStart is positive for a future trip', () {
    final trip = Trip(
      id: 'test',
      name: 'Test Trip',
      destination: 'Test',
      country: 'Test',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      status: TripStatus.confirmed,
      organiserId: 'Tester',
      playerCount: 8,
    );

    expect(trip.daysUntilStart, greaterThanOrEqualTo(9));
  });
}
