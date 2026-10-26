import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/trip_export.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

void main() {
  group('itineraryText', () {
    final text = itineraryText(melbourneGolfWeekend, melbourneGolfWeekendPlan);

    test('opens with the trip, destination, dates and players', () {
      final lines = text.split('\n');

      expect(lines.first, 'MELBOURNE GOLF WEEKEND');
      expect(lines[1], contains('Melbourne, Australia'));
      expect(lines[1], contains('28 Nov'));
      expect(lines[1], contains('4 days'));
      expect(text, contains('Players: Tiamana, Ben'));
    });

    test('lists the schedule day by day with times and weather', () {
      expect(text, contains('SCHEDULE'));
      expect(text, contains('Saturday 28 November'));
      expect(text, contains('8:10 AM  Golf · Kingston Heath'));
      expect(text, contains('Sunny'));
    });

    test('includes flights, accommodation, money and notes', () {
      expect(text, contains('QF431'));
      expect(text, contains('Ref QK7P2M'));
      expect(text, contains('RACV Healesville'));
      expect(text, contains(r'Total $11,500'));
      expect(text, contains('NOTES'));
      expect(text, contains('Bring cash for caddies'));
    });

    test('has no trailing whitespace', () {
      expect(text, text.trimRight());
    });
  });

  test('an empty plan exports just the header', () {
    final text = itineraryText(melbourneGolfWeekend, TripPlan.empty);

    expect(text.split('\n'), hasLength(2));
    expect(text, isNot(contains('SCHEDULE')));
  });

  test('the invite link carries the trip id on a reserved host', () {
    final link = tripInviteLink(melbourneGolfWeekend);

    expect(link, 'https://qaddy.example/join/melbourne-golf-weekend');
  });
}
