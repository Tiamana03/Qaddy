// Edit Trip item forms: add, validate, edit and delete for each list section.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_expense.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/models/trip_transport.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

import '../../../trips_test_harness.dart';

String _item(TripEditSection section, String itemId) =>
    AppRoutes.tripEditItem(melbourneId, section.slug, itemId);

TripPlan _plan(ProviderContainer c) => c.read(tripPlanProvider(melbourneId));

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> _confirmDelete(WidgetTester tester) async {
  await _tapText(tester, 'Delete');
  expect(find.byType(Dialog), findsOneWidget);
  // The dialog's own destructive button, not the page's.
  await tester.tap(
    find.descendant(of: find.byType(Dialog), matching: find.text('Delete')),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('flights', () {
    testWidgets('lists the flights and offers to add one', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.tripEditSection(
          melbourneId,
          TripEditSection.flights.slug,
        ),
      );

      expect(find.text('Qantas QF431'), findsOneWidget);
      expect(find.text('Qantas QF438'), findsOneWidget);
      expect(find.text('Add flight'), findsOneWidget);
    });

    testWidgets('adds a flight', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.flights, 'new'),
      );
      final before = _plan(c).flights.length;

      await _enter(tester, 'Airline', 'Virgin');
      await _enter(tester, 'Flight number', 'va 810');
      await _enter(tester, 'From', 'Sydney (SYD)');
      await _enter(tester, 'To', 'Melbourne (MEL)');
      await _enter(tester, 'Booking reference', 'abc123');
      await _tapText(tester, 'Save');

      final flights = _plan(c).flights;
      expect(flights, hasLength(before + 1));
      expect(flights.last.airline, 'Virgin');
      expect(flights.last.flightNumber, 'VA 810');
      expect(flights.last.bookingReference, 'ABC123');
      expect(_plan(c).latestUpdate?.text, 'Added flight VA 810');
      // Saved with nothing to pop back to: lands on the flights list.
      expect(find.text('Virgin VA 810'), findsOneWidget);
    });

    testWidgets('needs the airline, number and both airports', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.flights, 'new'),
      );
      final before = _plan(c).flights.length;

      await _tapText(tester, 'Save');

      expect(find.text('Required'), findsNWidgets(4));
      expect(_plan(c).flights, hasLength(before));
    });

    testWidgets('edits an existing flight, prefilled', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.flights, 'qf431'),
      );

      expect(find.text('Edit flight'), findsOneWidget);
      expect(find.text('QF431'), findsWidgets);
      await _enter(tester, 'Seat', '14c');
      await _enter(tester, 'Gate', '7');
      await tester.ensureVisible(find.text('Checked in'));
      await tester.tap(find.text('Checked in'));
      await tester.pump();
      await _tapText(tester, 'Save');

      final flight = _plan(c).flights.firstWhere((f) => f.id == 'qf431');
      expect(flight.seat, '14C');
      expect(flight.gate, '7');
      expect(flight.checkInStatus, FlightCheckInStatus.checkedIn);
      expect(_plan(c).flights, hasLength(2));
    });

    testWidgets('deletes a flight after confirming', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.flights, 'qf438'),
      );

      await _confirmDelete(tester);

      expect(_plan(c).flights.map((f) => f.id), <String>['qf431']);
    });

    testWidgets('a missing flight shows not-found, not a blank form', (
      tester,
    ) async {
      await pumpApp(tester, location: _item(TripEditSection.flights, 'gone'));

      expect(find.text('Trip not found'), findsOneWidget);
    });
  });

  group('courses', () {
    testWidgets('adds a course with every confirmed player', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.courses, 'new'),
      );

      await _enter(tester, 'Course name', 'Barwon Heads');
      await _enter(tester, 'Course rating', '72.1');
      await _enter(tester, 'Slope', '128');
      await _enter(tester, 'Green Fee (per player)', r'$185');
      await _tapText(tester, 'Save');

      final course = _plan(c).courses.last;
      expect(course.name, 'Barwon Heads');
      expect(course.courseRating, 72.1);
      expect(course.slope, 128);
      expect(course.greenFee, 185);
      expect(course.players, hasLength(_plan(c).confirmedMembers.length));
      expect(course.totalGreenFees, 185.0 * course.players.length);
    });

    testWidgets('rejects a rating that is not a number', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.courses, 'kingston-heath'),
      );

      await _enter(tester, 'Course rating', '7.2.1');
      await _tapText(tester, 'Save');

      expect(find.text('Check this number'), findsOneWidget);
      expect(
        _plan(
          c,
        ).courses.firstWhere((x) => x.id == 'kingston-heath').courseRating,
        isNot(isNull),
      );
    });

    testWidgets('players can be unticked', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.courses, 'kingston-heath'),
      );
      final before = _plan(c).courses.first.players.length;

      await tester.ensureVisible(find.text('Ben').first);
      await tester.tap(find.text('Ben').first);
      await tester.pump();
      await _tapText(tester, 'Save');

      expect(
        _plan(c).courses.firstWhere((x) => x.id == 'kingston-heath').players,
        hasLength(before - 1),
      );
    });

    testWidgets('deletes a course', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.courses, 'royal-melbourne'),
      );

      await _confirmDelete(tester);

      expect(
        _plan(c).courses.map((x) => x.id),
        isNot(contains('royal-melbourne')),
      );
    });
  });

  group('expenses', () {
    testWidgets('adds an equally split expense', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.expenses, 'new'),
      );
      final totalBefore = _plan(c).expenses.length;

      await _enter(tester, 'What was it for?', 'Dinner at Rosetta');
      await _enter(tester, 'Amount', r'$480');
      await tester.ensureVisible(find.textContaining('each'));
      expect(find.textContaining('each'), findsOneWidget);
      await _tapText(tester, 'Save');

      final expense = _plan(c).expenses.last;
      expect(_plan(c).expenses, hasLength(totalBefore + 1));
      expect(expense.title, 'Dinner at Rosetta');
      expect(expense.amount, 480);
      expect(expense.splitMode, ExpenseSplitMode.equal);
      expect(expense.paidBy, 'Tiamana');
      expect(expense.shareOf('Ben'), 480 / expense.participants.length);
    });

    testWidgets('needs a description and an amount', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.expenses, 'new'),
      );
      final before = _plan(c).expenses.length;

      await _tapText(tester, 'Save');

      expect(find.text('Describe the expense'), findsOneWidget);
      expect(find.text('Enter an amount'), findsOneWidget);
      expect(_plan(c).expenses, hasLength(before));
    });

    testWidgets('a custom split must add up to the amount', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.expenses, 'new'),
      );
      final before = _plan(c).expenses.length;

      await _enter(tester, 'What was it for?', 'Caddies');
      await _enter(tester, 'Amount', '100');
      await _tapText(tester, 'Custom');
      // Leave two people to share it.
      for (final name in <String>[
        'Luke',
        'Josh',
        'Nick',
        'Sam',
        'Liam',
        'Jack',
      ]) {
        final chip = find.widgetWithText(InkWell, name);
        if (chip.evaluate().isNotEmpty) {
          await tester.ensureVisible(chip.first);
          await tester.tap(chip.first, warnIfMissed: false);
          await tester.pump();
        }
      }
      await _tapText(tester, 'Save');

      expect(find.textContaining('Shares add up to'), findsOneWidget);
      expect(_plan(c).expenses, hasLength(before));
    });

    testWidgets('edits an expense and keeps who has already paid', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.expenses, 'exp-food'),
      );
      final settledBefore = _plan(
        c,
      ).expenses.firstWhere((e) => e.id == 'exp-food').settled;

      expect(find.text('Edit expense'), findsOneWidget);
      await _enter(tester, 'What was it for?', 'Team dinner');
      await _tapText(tester, 'Save');

      final edited = _plan(c).expenses.firstWhere((e) => e.id == 'exp-food');
      expect(edited.title, 'Team dinner');
      expect(edited.settled, settledBefore);
    });

    testWidgets('deletes an expense', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.expenses, 'exp-transport'),
      );

      await _confirmDelete(tester);

      expect(
        _plan(c).expenses.map((e) => e.id),
        isNot(contains('exp-transport')),
      );
    });
  });

  group('accommodation', () {
    testWidgets('adds a stay with a room allocation and a cost per guest', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.accommodation, 'new'),
      );

      await _enter(tester, 'Name', 'Chateau Yering');
      await _enter(tester, 'Total cost', r'$1,200');
      await _tapText(tester, 'Add room');
      await _enter(tester, 'Room 1', 'Twin room');
      await tester.ensureVisible(find.text('Ben').first);
      await tester.tap(find.text('Ben').first);
      await tester.pump();
      await tester.ensureVisible(find.text('Luke').first);
      await tester.tap(find.text('Luke').first);
      await tester.pump();
      await _tapText(tester, 'Save');

      final stay = _plan(c).accommodations.last;
      expect(stay.name, 'Chateau Yering');
      expect(stay.totalCost, 1200);
      expect(stay.rooms.single.name, 'Twin room');
      expect(stay.rooms.single.guests, containsAll(<String>['Ben', 'Luke']));
      expect(stay.costPerGuest, 600);
    });

    testWidgets('a guest can only sleep in one room', (tester) async {
      await pumpApp(
        tester,
        location: _item(TripEditSection.accommodation, 'racv-healesville'),
      );

      // Every confirmed member is already in a room, so a new room has no
      // one left to offer.
      await _tapText(tester, 'Add room');
      await tester.ensureVisible(find.text('Room 5'));
      expect(find.text('Room 5'), findsOneWidget);
    });

    testWidgets('requires a name', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.accommodation, 'new'),
      );
      final before = _plan(c).accommodations.length;

      await _tapText(tester, 'Save');

      expect(find.text('Where are you staying?'), findsOneWidget);
      expect(_plan(c).accommodations, hasLength(before));
    });
  });

  group('transport', () {
    testWidgets('adds a booking with a pickup or a drop-off', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.transport, 'new'),
      );

      await tester.tap(find.text('Uber'));
      await tester.pump();
      await _enter(tester, 'From', 'Crown Casino');
      await _tapText(tester, 'Save');

      final leg = _plan(c).transport.last;
      expect(leg.type, TransportType.rideShare);
      expect(leg.from, 'Crown Casino');
    });

    testWidgets('needs a place to start or finish', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.transport, 'new'),
      );
      final before = _plan(c).transport.length;

      await _tapText(tester, 'Save');

      expect(find.text('Add a pickup or a drop-off'), findsNWidgets(2));
      expect(_plan(c).transport, hasLength(before));
    });
  });

  group('weather', () {
    testWidgets('adds a forecast day by hand', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.weather, 'new'),
      );

      await _enter(tester, 'Day', 'Wednesday');
      await tester.tap(find.text('Rain'));
      await _enter(tester, 'High', '16');
      await _enter(tester, 'Low', '9');
      await _tapText(tester, 'Save');

      final day = _plan(c).weather.last;
      expect(day.day, 'Wednesday');
      expect(day.high, 16);
      expect(day.low, 9);
    });

    testWidgets('needs numbers for both temperatures', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.weather, 'new'),
      );
      final before = _plan(c).weather.length;

      await _enter(tester, 'Day', 'Wednesday');
      await _tapText(tester, 'Save');

      expect(find.text('Number'), findsNWidgets(2));
      expect(_plan(c).weather, hasLength(before));
    });
  });

  group('activities and tasks', () {
    testWidgets('adds an activity to the timeline', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.itinerary, 'new'),
      );

      await _enter(tester, 'What are you doing?', 'Dinner at Rosetta');
      await _enter(tester, 'Where', 'Crown Melbourne');
      await _tapText(tester, 'Save');

      final item = _plan(c).itinerary.last;
      expect(item.title, 'Dinner at Rosetta');
      expect(item.location, 'Crown Melbourne');
      expect(item.kind.label, 'Food & Drink');
    });

    testWidgets('an activity needs a name', (tester) async {
      await pumpApp(tester, location: _item(TripEditSection.itinerary, 'new'));

      await _tapText(tester, 'Save');

      expect(find.text('Give it a name'), findsOneWidget);
    });

    testWidgets('adds a completed task', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.tasks, 'new'),
      );

      await _enter(tester, 'Task', 'Book the airport lounge');
      await tester.tap(find.text('Done'));
      await tester.pump();
      await _tapText(tester, 'Save');
      final task = _plan(c).tasks.last;
      expect(task.title, 'Book the airport lounge');
      expect(task.done, isTrue);
    });

    testWidgets('deletes a task', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.tasks, 'task-pack'),
      );

      await _confirmDelete(tester);

      expect(_plan(c).tasks.map((t) => t.id), isNot(contains('task-pack')));
    });
  });

  group('packing list', () {
    testWidgets('adds an item and marks it packed', (tester) async {
      final c = await pumpApp(
        tester,
        location: _item(TripEditSection.packing, 'new'),
      );

      await _enter(tester, 'Item', 'Rain jacket');
      await tester.tap(find.text('Packed'));
      await tester.pump();
      await _tapText(tester, 'Save');

      final item = _plan(c).packing.last;
      expect(item.label, 'Rain jacket');
      expect(item.packed, isTrue);
    });

    testWidgets('requires an item name', (tester) async {
      await pumpApp(tester, location: _item(TripEditSection.packing, 'new'));

      await _tapText(tester, 'Save');

      expect(find.text('What are you packing?'), findsOneWidget);
    });
  });
}
