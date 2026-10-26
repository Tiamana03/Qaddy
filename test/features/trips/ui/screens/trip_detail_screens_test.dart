// The trip detail pages: golf, course, flights, accommodation, transport,
// expenses and planning.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';

import '../../trips_test_harness.dart';

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  group('golf schedule', () {
    testWidgets('shows every course as a tee-time card under its day', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripGolf(melbourneId));

      expect(find.text('Kingston Heath'), findsOneWidget);
      expect(find.text('Royal Melbourne'), findsOneWidget);
      expect(find.text('Peninsula Kingswood'), findsOneWidget);
      expect(find.text('8:10 AM'), findsOneWidget);
      expect(find.text('Sunday 29 November'), findsOneWidget);
      expect(find.text(r'8 players · $250 pp'), findsOneWidget);
      // Weather for the day sits on the card.
      expect(find.byIcon(Icons.wb_cloudy_outlined), findsOneWidget);
    });

    testWidgets('keeps the playing groups and side games', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripGolf(melbourneId));

      expect(find.text('Playing Groups'), findsOneWidget);
      expect(find.text('Side Games'), findsOneWidget);
      expect(find.text('Longest Drive'), findsOneWidget);
    });

    testWidgets('a course card opens that course', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripGolf(melbourneId));

      await _tap(tester, 'Royal Melbourne');

      expect(find.text('Course'), findsOneWidget);
      expect(
        find.text('12 Cheltenham Road, Black Rock VIC 3193'),
        findsWidgets,
      );
    });

    testWidgets('a trip with no courses invites the first one', (tester) async {
      final c = await pumpApp(tester);
      final id = c
          .read(tripsProvider.notifier)
          .createTrip(
            NewTripDraft(
              name: 'Barossa',
              destination: 'Barossa Valley, Australia',
              startDate: DateTime(2027, 3, 12),
              endDate: DateTime(2027, 3, 14),
            ),
          );
      c.read(appRouterProvider).go(AppRoutes.tripGolf(id));
      await tester.pumpAndSettle();

      expect(find.text('No courses yet'), findsOneWidget);
    });
  });

  group('course page', () {
    String course(String id) => AppRoutes.tripCourse(melbourneId, id);

    testWidgets('shows everything the brief asks for', (tester) async {
      await pumpApp(tester, location: course('kingston-heath'));

      expect(find.text('Kingston Heath'), findsWidgets);
      expect(find.text('1 Heath Road, Cheltenham VIC 3192'), findsWidgets);
      expect(find.text('(03) 5550 0141'), findsOneWidget);
      expect(find.text('www.kingstonheath.example'), findsOneWidget);
      expect(find.text('73.8'), findsOneWidget);
      expect(find.text('138'), findsOneWidget);
      expect(find.text('Map & Directions'), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);
      expect(find.textContaining('Partly Cloudy'), findsOneWidget);
      expect(find.textContaining('Collared shirt'), findsOneWidget);
      expect(find.textContaining('Carts are limited'), findsOneWidget);
    });

    testWidgets('works out the green fees from the players', (tester) async {
      await pumpApp(tester, location: course('kingston-heath'));

      expect(find.text('Green Fees'), findsOneWidget);
      expect(find.text(r'$250'), findsOneWidget);
      expect(find.text(r'$2,000'), findsOneWidget);
    });

    testWidgets('lists the players', (tester) async {
      await pumpApp(tester, location: course('kingston-heath'));

      expect(find.text('Players (8)'), findsOneWidget);
      expect(find.text('Jack'), findsOneWidget);
    });

    testWidgets('copies the phone number and the address', (tester) async {
      final copied = captureClipboard(tester);
      await pumpApp(tester, location: course('kingston-heath'));

      await _tap(tester, '(03) 5550 0141');
      await _tap(tester, 'Copy Address for Directions');

      expect(copied, <String>[
        '(03) 5550 0141',
        '1 Heath Road, Cheltenham VIC 3192',
      ]);
    });

    testWidgets('an unknown course shows not-found', (tester) async {
      await pumpApp(tester, location: course('nope'));

      expect(find.text('Trip not found'), findsOneWidget);
    });
  });

  group('flights', () {
    testWidgets('shows each flight as a boarding pass', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripFlights(melbourneId));

      expect(find.text('Qantas QF431'), findsOneWidget);
      expect(find.text('Qantas QF438'), findsOneWidget);
      expect(find.text('Sydney → Melbourne'), findsOneWidget);
      expect(find.text('Terminal 3'), findsOneWidget);
      expect(find.text('14A'), findsNWidgets(2));
      expect(find.textContaining('1h 35m'), findsNWidgets(2));
      expect(find.text('Check-in not open'), findsNWidgets(2));
    });

    testWidgets('a boarding pass opens the flight page', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripFlights(melbourneId));

      await _tap(tester, 'Qantas QF431');

      expect(find.text('Flight'), findsOneWidget);
      expect(find.text('QK7P2M'), findsOneWidget);
      expect(find.text('Terminal 3'), findsOneWidget);
      expect(find.text('Gate 12'), findsOneWidget);
      expect(find.text('7:55 AM'), findsOneWidget);
    });

    testWidgets('check-in status can be changed on the flight page', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripFlight(melbourneId, 'qf431'),
      );

      await _tap(tester, 'Checked in');

      final flight = c
          .read(tripPlanProvider(melbourneId))
          .flights
          .firstWhere((f) => f.id == 'qf431');
      expect(flight.checkInStatus, FlightCheckInStatus.checkedIn);
    });

    testWidgets('copies the booking reference', (tester) async {
      final copied = captureClipboard(tester);
      await pumpApp(
        tester,
        location: AppRoutes.tripFlight(melbourneId, 'qf431'),
      );

      await _tap(tester, 'QK7P2M');

      expect(copied.single, 'QK7P2M');
    });

    testWidgets('an unknown flight shows not-found', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.tripFlight(melbourneId, 'nope'),
      );

      expect(find.text('Trip not found'), findsOneWidget);
    });
  });

  group('accommodation', () {
    testWidgets('shows the stay, contact details and booking number', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripAccommodation(melbourneId));

      expect(find.text('RACV Healesville Resort'), findsOneWidget);
      expect(find.text('RHR-482910'), findsOneWidget);
      expect(find.text('(03) 5550 4899'), findsOneWidget);
      expect(find.textContaining('3 nights'), findsOneWidget);
      expect(find.textContaining('Breakfast included'), findsOneWidget);
    });

    testWidgets('shows who is in each room and the cost per guest', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripAccommodation(melbourneId));

      expect(find.text('Room 101'), findsOneWidget);
      expect(find.text('Tiamana, Ben'), findsOneWidget);
      expect(find.text(r'$3,360'), findsOneWidget);
      expect(find.text('Per guest (8)'), findsOneWidget);
      expect(find.text(r'$420'), findsOneWidget);
    });

    testWidgets('a trip with no stay invites the first one', (tester) async {
      final c = await pumpApp(tester);
      final id = c
          .read(tripsProvider.notifier)
          .createTrip(
            NewTripDraft(
              name: 'Barossa',
              destination: 'Barossa Valley, Australia',
              startDate: DateTime(2027, 3, 12),
              endDate: DateTime(2027, 3, 14),
            ),
          );
      c.read(appRouterProvider).go(AppRoutes.tripAccommodation(id));
      await tester.pumpAndSettle();

      expect(find.text('No accommodation yet'), findsOneWidget);
    });
  });

  group('transport', () {
    testWidgets('groups bookings by day with their details', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripTransport(melbourneId));

      expect(find.text('Saturday 28 November'), findsOneWidget);
      expect(find.text('Airport Transfer'), findsOneWidget);
      expect(find.text('Melbourne Airport → RACV Healesville'), findsOneWidget);
      expect(
        find.textContaining('Daniel (Yarra Valley Shuttles)'),
        findsOneWidget,
      );
      expect(find.text('YVS-30871'), findsOneWidget);
      expect(find.text('Rental Car'), findsNWidgets(3));
    });

    testWidgets('copies a booking reference', (tester) async {
      final copied = captureClipboard(tester);
      await pumpApp(tester, location: AppRoutes.tripTransport(melbourneId));

      await _tap(tester, 'YVS-30871');

      expect(copied.single, 'YVS-30871');
    });
  });

  group('expenses', () {
    testWidgets('shows total, paid and outstanding with a progress bar', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripExpenses(melbourneId));

      expect(find.text(r'$11,500'), findsOneWidget);
      expect(find.text(r'$5,960'), findsOneWidget);
      expect(find.text(r'$5,540'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('says where the golfer stands', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripExpenses(melbourneId));

      expect(find.text('You owe'), findsOneWidget);
      expect(find.text(r'$880'), findsOneWidget);
      expect(find.text('You are owed'), findsOneWidget);
      expect(find.text(r'$840'), findsOneWidget);
    });

    testWidgets('lists who owes who and every expense', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripExpenses(melbourneId));

      expect(find.text('Who Owes Who'), findsOneWidget);
      expect(find.text('Tiamana owes Ben'), findsOneWidget);
      expect(find.text('Expense History'), findsOneWidget);
      expect(find.text('Green fees — 3 rounds'), findsOneWidget);
      expect(find.text('Dinner deposits'), findsOneWidget);
    });

    testWidgets('Mark Paid settles a debt after confirming', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripExpenses(melbourneId),
      );
      final before = summariseExpenses(
        c.read(tripPlanProvider(melbourneId)).expenses,
      );

      await tester.tap(find.bySemanticsLabel('Mark Tiamana paid').first);
      await tester.pumpAndSettle();
      expect(find.text('Mark as paid?'), findsOneWidget);
      await tester.tap(find.text('Mark Paid').last);
      await tester.pumpAndSettle();

      final after = summariseExpenses(
        c.read(tripPlanProvider(melbourneId)).expenses,
      );
      expect(after.outstanding, lessThan(before.outstanding));
      expect(find.text('Tiamana owes Ben'), findsNothing);
    });

    testWidgets('cancelling Mark Paid changes nothing', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripExpenses(melbourneId),
      );
      final before = summariseExpenses(
        c.read(tripPlanProvider(melbourneId)).expenses,
      );

      await tester.tap(find.bySemanticsLabel('Mark Tiamana paid').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
        summariseExpenses(
          c.read(tripPlanProvider(melbourneId)).expenses,
        ).outstanding,
        before.outstanding,
      );
    });

    testWidgets('settling everything shows All settled', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripExpenses(melbourneId),
      );
      final controller = c.read(tripsProvider.notifier);
      for (final debt in whoOwesWho(
        c.read(tripPlanProvider(melbourneId)).expenses,
      )) {
        controller.settleDebt(melbourneId, from: debt.from, to: debt.to);
      }
      await tester.pumpAndSettle();

      expect(find.text('All settled'), findsOneWidget);
      expect(find.text('Everyone is settled up.'), findsOneWidget);
    });

    testWidgets('Add Expense opens the form', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripExpenses(melbourneId));

      await _tap(tester, 'Add Expense');

      expect(find.text('What was it for?'), findsOneWidget);
    });

    testWidgets('a trip with no expenses invites the first one', (
      tester,
    ) async {
      final c = await pumpApp(tester);
      final id = c
          .read(tripsProvider.notifier)
          .createTrip(
            NewTripDraft(
              name: 'Barossa',
              destination: 'Barossa Valley, Australia',
              startDate: DateTime(2027, 3, 12),
              endDate: DateTime(2027, 3, 14),
            ),
          );
      c.read(appRouterProvider).go(AppRoutes.tripExpenses(id));
      await tester.pumpAndSettle();

      expect(find.text('No expenses yet'), findsOneWidget);
    });
  });

  group('planning', () {
    testWidgets('shows planning progress and the next task', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripPlanning(melbourneId));

      expect(find.byType(PlanningRing), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('3 of 6 tasks done'), findsOneWidget);
      expect(find.text('Next: Reserve Sunday dinner'), findsOneWidget);
    });

    testWidgets('the timeline lists each day with weather and events', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: AppRoutes.tripPlanning(melbourneId),
        size: const Size(400, 4000),
      );

      expect(find.text('Saturday 28 November'), findsOneWidget);
      expect(find.text('Sunday 29 November'), findsOneWidget);
      expect(find.text('Qantas QF431'), findsOneWidget);
      expect(find.text('Golf · Kingston Heath'), findsOneWidget);
      expect(find.text('Team dinner'), findsOneWidget);
      expect(find.text('Yarra Valley winery visit'), findsOneWidget);
      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Day 4'), findsOneWidget);
    });

    testWidgets('a timeline event opens its page', (tester) async {
      await pumpApp(
        tester,
        location: AppRoutes.tripPlanning(melbourneId),
        size: const Size(400, 4000),
      );

      await _tap(tester, 'Golf · Kingston Heath');

      expect(find.text('Course'), findsOneWidget);
    });

    testWidgets('the checklist ticks tasks and updates the progress', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripPlanning(melbourneId),
      );

      await _tap(tester, 'Tasks');
      await _tap(tester, 'Reserve Sunday dinner');

      expect(
        c.read(tripPlanProvider(melbourneId)).planningProgress,
        closeTo(4 / 6, 0.001),
      );
      expect(find.text('67%'), findsOneWidget);
    });

    testWidgets('flags overdue tasks', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripPlanning(melbourneId));

      await _tap(tester, 'Tasks');

      // The clock in tests is the real one; both open tasks are due in
      // November 2026, so they read as upcoming, not overdue, until then.
      expect(find.textContaining('Due 20 Nov 2026'), findsOneWidget);
    });

    testWidgets('the packing list ticks items off', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripPlanning(melbourneId),
      );

      await _tap(tester, 'Packing');
      expect(find.text('1 of 8 packed'), findsOneWidget);
      await _tap(tester, 'Rain jacket');

      expect(
        c
            .read(tripPlanProvider(melbourneId))
            .packing
            .firstWhere((i) => i.id == 'pack-rain')
            .packed,
        isTrue,
      );
      expect(find.text('2 of 8 packed'), findsOneWidget);
    });

    testWidgets('bookings link to each page', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripPlanning(melbourneId));

      await _tap(tester, 'Bookings');
      expect(find.text('2 flights'), findsOneWidget);
      expect(find.text('3 courses'), findsOneWidget);
      await _tap(tester, 'Flights');

      expect(find.text('Qantas QF431'), findsOneWidget);
    });

    testWidgets('Add Task opens the task form', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripPlanning(melbourneId));

      await _tap(tester, 'Tasks');
      await _tap(tester, 'Add Task');

      expect(find.text('Add Task'), findsWidgets);
      expect(find.text('Book the Saturday dinner'), findsOneWidget);
    });
  });
}
