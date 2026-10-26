// Every Trips screen, at phone, tablet and desktop widths: no layout overflow
// or other framework exception.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';

import '../../trips_test_harness.dart';

const _phone = Size(360, 2400);
const _tablet = Size(820, 2400);
const _desktop = Size(1280, 2400);

/// A representative route for every Trips screen, using Melbourne's data.
final Map<String, String> _screens = <String, String>{
  'trips': AppRoutes.trips,
  'create trip': AppRoutes.tripCreate,
  'details': AppRoutes.tripDetails(melbourneId),
  'planning': AppRoutes.tripPlanning(melbourneId),
  'flights': AppRoutes.tripFlights(melbourneId),
  'flight': AppRoutes.tripFlight(melbourneId, 'qf431'),
  'accommodation': AppRoutes.tripAccommodation(melbourneId),
  'transport': AppRoutes.tripTransport(melbourneId),
  'golf': AppRoutes.tripGolf(melbourneId),
  'course': AppRoutes.tripCourse(melbourneId, 'kingston-heath'),
  'expenses': AppRoutes.tripExpenses(melbourneId),
  'chat': AppRoutes.tripChat(melbourneId),
  'complete': AppRoutes.tripComplete(melbourneId),
  'edit hub': AppRoutes.tripEdit(melbourneId),
  'settings': AppRoutes.tripSettings(melbourneId),
  'invite': AppRoutes.tripInvite(melbourneId),
  'export': AppRoutes.tripExport(melbourneId),
  for (final section in TripEditSection.values)
    'edit ${section.slug}': AppRoutes.tripEditSection(
      melbourneId,
      section.slug,
    ),
  'edit flight': AppRoutes.tripEditItem(melbourneId, 'flights', 'qf431'),
  'edit accommodation': AppRoutes.tripEditItem(
    melbourneId,
    'accommodation',
    'racv-healesville',
  ),
  'edit transport': AppRoutes.tripEditItem(melbourneId, 'transport', 'car-sat'),
  'edit course': AppRoutes.tripEditItem(
    melbourneId,
    'courses',
    'kingston-heath',
  ),
  'edit expense': AppRoutes.tripEditItem(melbourneId, 'expenses', 'exp-golf'),
  'edit activity': AppRoutes.tripEditItem(melbourneId, 'itinerary', 'dinner'),
  'edit task': AppRoutes.tripEditItem(melbourneId, 'tasks', 'task-dinner'),
  'edit weather': AppRoutes.tripEditItem(melbourneId, 'weather', 'w-sat'),
  'edit packing': AppRoutes.tripEditItem(melbourneId, 'packing', 'pack-rain'),
};

void main() {
  for (final (label, size) in <(String, Size)>[
    ('phone', _phone),
    ('tablet', _tablet),
    ('desktop', _desktop),
  ]) {
    group('at $label width', () {
      for (final entry in _screens.entries) {
        testWidgets('${entry.key} lays out without errors', (tester) async {
          await pumpApp(tester, location: entry.value, size: size);

          expect(tester.takeException(), isNull);
          expect(find.text('Trip not found'), findsNothing);
        });
      }
    });
  }
}
