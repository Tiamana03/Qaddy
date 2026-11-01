import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/repositories/trips_codec.dart';

String _seedDocument() => encodeTrips(seedTrips, seedPlans);

Map<String, dynamic> _seedJson() =>
    jsonDecode(_seedDocument()) as Map<String, dynamic>;

void main() {
  test('every seeded trip and plan survives a round trip unchanged', () {
    final document = _seedDocument();

    final decoded = decodeTrips(document)!;

    expect(decoded.trips, hasLength(seedTrips.length));
    expect(decoded.plans.keys, seedPlans.keys);
    // Re-encoding what was decoded gives the identical document, so nothing
    // was dropped, reordered or altered on the way through.
    expect(encodeTrips(decoded.trips, decoded.plans), document);
  });

  test('keeps the details a golfer would notice if they went missing', () {
    final decoded = decodeTrips(_seedDocument())!;
    final trip = decoded.trips.firstWhere(
      (t) => t.id == melbourneGolfWeekend.id,
    );
    final plan = decoded.plans[trip.id]!;

    expect(trip.name, 'Melbourne Golf Weekend');
    expect(trip.status, TripStatus.confirmed);
    expect(trip.coverImage, 'fairway');
    expect(trip.startDate.isUtc, isTrue);
    expect(trip.startDate, melbourneGolfWeekend.startDate);

    expect(plan.members, hasLength(9));
    expect(plan.courses.first.teeTime, DateTime(2026, 11, 29, 8, 10));
    expect(plan.courses.first.courseRating, 73.8);
    expect(plan.courses.first.slope, 138);
    expect(plan.courses.first.players, hasLength(8));
    expect(plan.flights.first.boarding, DateTime(2026, 11, 28, 7, 55));
    expect(plan.flights.first.checkInStatus, FlightCheckInStatus.notOpen);
    expect(plan.accommodations.single.rooms, hasLength(4));
    expect(plan.accommodations.single.totalCost, 3360);
    expect(plan.transport, hasLength(4));
    expect(plan.itinerary, hasLength(2));
    expect(plan.tasks.where((t) => t.done), hasLength(3));
    expect(plan.tasks.firstWhere((t) => t.id == 'task-dinner').due, isNotNull);
    expect(plan.messages, hasLength(8));
    expect(plan.chatSettings.readReceipts, isTrue);
    expect(plan.updates, hasLength(2));
    expect(plan.notes, contains('caddies'));
  });

  test('keeps who has paid and custom splits', () {
    final plan = decodeTrips(_seedDocument())!.plans[melbourneGolfWeekend.id]!;
    final golf = plan.expenses.firstWhere((e) => e.id == 'exp-golf');
    expect(golf.settled, <String>{'Luke', 'Josh'});
    expect(golf.splitMode, ExpenseSplitMode.equal);

    final custom = encodeTrips(
      <Trip>[melbourneGolfWeekend],
      <String, TripPlan>{
        melbourneGolfWeekend.id: seedPlans[melbourneGolfWeekend.id]!.copyWith(
          expenses: <TripExpense>[
            golf.copyWith(
              splitMode: ExpenseSplitMode.custom,
              customShares: const <String, double>{
                'Ben': 1500.5,
                'Luke': 4339.5,
              },
            ),
          ],
        ),
      },
    );
    final back = decodeTrips(custom)!.plans[melbourneGolfWeekend.id]!;

    expect(back.expenses.single.splitMode, ExpenseSplitMode.custom);
    expect(back.expenses.single.customShares['Ben'], 1500.5);
    expect(back.expenses.single.settled, <String>{'Luke', 'Josh'});
  });

  group('a document it cannot read decodes to null', () {
    test('that is not JSON', () => expect(decodeTrips('not json'), isNull));

    test('that is not an object', () => expect(decodeTrips('[1,2]'), isNull));

    test('from a different format version', () {
      final document = _seedJson()..['version'] = 99;

      expect(decodeTrips(jsonEncode(document)), isNull);
    });

    test('that is missing its trips', () {
      expect(decodeTrips('{"version":1}'), isNull);
    });

    test('with a trip missing a required field', () {
      final document = _seedJson();
      ((document['trips'] as List<dynamic>).first as Map<String, dynamic>)
          .remove('name');

      expect(decodeTrips(jsonEncode(document)), isNull);
    });
  });

  group('is forgiving about what it can recover', () {
    test('an unknown status falls back to Planning', () {
      final document = _seedJson();
      ((document['trips'] as List<dynamic>).first
              as Map<String, dynamic>)['status'] =
          'sparkling';

      final trip = decodeTrips(jsonEncode(document))!.trips.first;

      expect(trip.status, TripStatus.planning);
    });

    test('missing optional fields take their defaults', () {
      final document = _seedJson();
      (document['plans'] as Map<String, dynamic>)[melbourneGolfWeekend.id]
            as Map<String, dynamic>
        ..remove('chatSettings')
        ..remove('notes')
        ..remove('updates');

      final back = decodeTrips(
        jsonEncode(document),
      )!.plans[melbourneGolfWeekend.id]!;

      expect(back.notes, '');
      expect(back.updates, isEmpty);
      expect(back.chatSettings.readReceipts, isTrue);
    });
  });

  test('an empty store round trips', () {
    final back = decodeTrips(encodeTrips(const <Trip>[], const {}))!;

    expect(back.trips, isEmpty);
    expect(back.plans, isEmpty);
  });
}
