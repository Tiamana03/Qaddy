import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/trip_setup.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

void main() {
  test('a fully planned trip has nothing left to set up', () {
    final steps = tripSetupSteps('t', melbourneGolfWeekendPlan);

    expect(steps, hasLength(5));
    expect(steps.every((step) => step.done), isTrue);
  });

  test('an empty trip has every step still to do', () {
    final steps = tripSetupSteps('t', TripPlan.empty);

    expect(steps.where((step) => step.done), isEmpty);
  });

  test('each step knows when it is done', () {
    final plan = TripPlan.empty.copyWith(
      members: const <TripMember>[
        TripMember(
          displayName: 'Tiamana',
          handicap: 8.4,
          role: TripRole.organiser,
          status: ParticipantStatus.confirmed,
        ),
        TripMember(
          displayName: 'Ben',
          handicap: 12,
          role: TripRole.player,
          status: ParticipantStatus.pending,
        ),
      ],
      flights: melbourneGolfWeekendPlan.flights,
    );

    final done = <String, bool>{
      for (final step in tripSetupSteps('t', plan)) step.title: step.done,
    };

    expect(done['Invite your squad'], isTrue);
    expect(done['Add your flights'], isTrue);
    expect(done['Add where you are staying'], isFalse);
    expect(done['Add a course and tee time'], isFalse);
    expect(done['Plan something fun'], isFalse);
  });

  test('every step leads to the page where it is done', () {
    final routes = tripSetupSteps(
      'abc',
      TripPlan.empty,
    ).map((step) => step.route).toList();

    expect(routes, <String>[
      '/trips/abc/invite',
      '/trips/abc/edit/flights/new',
      '/trips/abc/edit/accommodation/new',
      '/trips/abc/edit/courses/new',
      '/trips/abc/edit/itinerary/new',
    ]);
  });
}
