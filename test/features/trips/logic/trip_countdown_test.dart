import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/models/trip.dart';

void main() {
  final trip = Trip(
    id: 't',
    name: 'Test Trip',
    destination: 'Somewhere',
    country: 'Australia',
    startDate: DateTime.utc(2026, 11, 28),
    endDate: DateTime.utc(2026, 12),
    status: TripStatus.confirmed,
    organiserId: 'Tiamana',
    playerCount: 4,
  );

  test('counts whole days to go before the start', () {
    final countdown = tripCountdown(trip, now: DateTime(2026, 10, 26, 15));
    expect(countdown.value, '33');
    expect(countdown.label, 'days to go');
  });

  test('uses the singular the day before', () {
    final countdown = tripCountdown(trip, now: DateTime(2026, 11, 27, 23, 59));
    expect(countdown.value, '1');
    expect(countdown.label, 'day to go');
  });

  test('says Today on the start date regardless of the time', () {
    expect(tripCountdown(trip, now: DateTime(2026, 11, 28, 6)).value, 'Today');
    expect(tripCountdown(trip, now: DateTime(2026, 11, 28, 22)).value, 'Today');
  });

  test('says Now while the trip is underway, through its last day', () {
    expect(tripCountdown(trip, now: DateTime(2026, 11, 30)).value, 'Now');
    expect(tripCountdown(trip, now: DateTime(2026, 12)).value, 'Now');
  });

  test('says Done once the trip has finished', () {
    final countdown = tripCountdown(trip, now: DateTime(2026, 12, 2));
    expect(countdown.value, 'Done');
    expect(countdown.label, 'trip finished');
  });
}
