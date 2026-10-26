import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/trips/logic/trip_edit_summary.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_message.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';

String _summary(TripEditSection section, [TripPlan? plan]) => tripEditSummary(
  melbourneGolfWeekend,
  plan ?? melbourneGolfWeekendPlan,
  section,
);

void main() {
  test('every section has a non-empty summary', () {
    for (final section in TripEditSection.values) {
      expect(_summary(section), isNotEmpty, reason: section.label);
      expect(_summary(section, TripPlan.empty), isNotEmpty);
    }
  });

  test('summaries describe what is in the seeded Melbourne trip', () {
    expect(
      _summary(TripEditSection.details),
      'Melbourne Golf Weekend · Private',
    );
    expect(_summary(TripEditSection.destination), 'Melbourne, Australia');
    expect(_summary(TripEditSection.flights), '2 flights');
    expect(_summary(TripEditSection.accommodation), '1 stay');
    expect(_summary(TripEditSection.courses), '3 courses');
    expect(_summary(TripEditSection.players), '8 going · 1 invited');
    expect(_summary(TripEditSection.expenses), r'4 expenses · $11,500');
    expect(_summary(TripEditSection.packing), contains('packed'));
    expect(_summary(TripEditSection.dates), contains('4 days'));
  });

  test('empty sections invite the golfer to add something', () {
    expect(_summary(TripEditSection.flights, TripPlan.empty), 'No flights yet');
    expect(
      _summary(TripEditSection.accommodation, TripPlan.empty),
      'No stays yet',
    );
    expect(_summary(TripEditSection.notes, TripPlan.empty), 'No notes yet');
    expect(
      _summary(TripEditSection.weather, TripPlan.empty),
      'No forecast yet',
    );
  });

  test('chat summary reflects the settings', () {
    final plan = TripPlan.empty.copyWith(
      chatSettings: const TripChatSettings(muted: true, readReceipts: false),
    );

    expect(
      _summary(TripEditSection.chat, plan),
      'Muted · Read receipts off · Typing on',
    );
  });

  test('a section is found by its slug', () {
    expect(TripEditSection.fromSlug('flights'), TripEditSection.flights);
    expect(TripEditSection.fromSlug('nope'), isNull);
    expect(TripEditSection.flights.isList, isTrue);
    expect(TripEditSection.notes.isList, isFalse);
  });
}
