// Edit Trip: the hub, and the section editors that are a single form.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

import '../../../trips_test_harness.dart';

Trip _trip(ProviderContainer c, [String id = melbourneId]) =>
    c.read(tripsProvider).tripById(id)!;

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

String _section(TripEditSection section) =>
    AppRoutes.tripEditSection(melbourneId, section.slug);

void main() {
  group('hub', () {
    testWidgets('lists every editable section with a summary', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripEdit(melbourneId));

      expect(find.text('Edit Trip'), findsOneWidget);
      for (final section in TripEditSection.values) {
        expect(find.text(section.label), findsOneWidget, reason: section.label);
      }
      expect(find.text('2 flights'), findsOneWidget);
      expect(find.text('3 courses'), findsOneWidget);
      expect(find.text('Trip Settings'), findsOneWidget);
    });

    testWidgets('a row opens its section and Back returns to the hub', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripDetails(melbourneId));

      await tester.tap(find.byTooltip('Edit Trip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Flights'));
      await tester.pumpAndSettle();
      expect(find.text('Qantas QF431'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Trip Settings'), findsOneWidget);
    });

    testWidgets('an unknown trip or section shows the not-found state', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripEdit('nope'));
      expect(find.text('Trip not found'), findsOneWidget);

      await pumpApp(
        tester,
        location: AppRoutes.tripEditSection(melbourneId, 'nonsense'),
      );
      expect(find.text('Trip not found'), findsOneWidget);
    });
  });

  group('trip details', () {
    testWidgets('renames the trip, changes visibility and cover', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.details),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Trip Name'),
        'Melbourne Boys Trip',
      );
      await tester.tap(find.text('Public'));
      await tester.tap(find.bySemanticsLabel('Coast cover'));
      await tester.pump();
      await _save(tester);

      final trip = _trip(c);
      expect(trip.name, 'Melbourne Boys Trip');
      expect(trip.visibility, TripVisibility.public);
      expect(trip.coverImage, 'coast');
      expect(
        c.read(tripPlanProvider(melbourneId)).latestUpdate?.text,
        'Renamed the trip to Melbourne Boys Trip',
      );
      // Saved with nothing to pop back to: lands on the hub.
      expect(find.text('Trip Settings'), findsOneWidget);
    });

    testWidgets('will not save a blank name', (tester) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.details),
      );

      await tester.enterText(find.widgetWithText(TextField, 'Trip Name'), ' ');
      await _save(tester);

      expect(find.text('Give your trip a name'), findsOneWidget);
      expect(_trip(c).name, 'Melbourne Golf Weekend');
    });

    testWidgets('clearing the description removes it', (tester) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.details),
      );
      c
          .read(tripsProvider.notifier)
          .updateTrip(melbourneId, (t) => t.copyWith(description: 'Boys trip'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Description'), '');
      await _save(tester);

      expect(_trip(c).description, isNull);
    });
  });

  group('dates', () {
    testWidgets('shows the current dates and keeps them when saved', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.dates),
      );

      expect(find.text('28 Nov 2026'), findsOneWidget);
      expect(find.text('1 Dec 2026'), findsOneWidget);
      expect(find.textContaining('4 days'), findsOneWidget);
      await _save(tester);

      expect(_trip(c).startDate.day, 28);
      expect(_trip(c).startDate.month, 11);
      expect(_trip(c).endDate.day, 1);
      expect(_trip(c).endDate.month, 12);
    });
  });

  group('destination', () {
    testWidgets('changes the destination and the derived country', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.destination),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Destination'),
        'Barossa Valley, South Australia',
      );
      await _save(tester);

      expect(_trip(c).destination, 'Barossa Valley, South Australia');
      expect(_trip(c).country, 'South Australia');
    });

    testWidgets('requires a destination', (tester) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.destination),
      );

      await tester.enterText(find.widgetWithText(TextField, 'Destination'), '');
      await _save(tester);

      expect(find.text('Where are you going?'), findsOneWidget);
      expect(_trip(c).destination, 'Melbourne, Australia');
    });
  });

  group('notes', () {
    testWidgets('saves the notes', (tester) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.notes),
      );

      expect(find.textContaining('Bring cash for caddies'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Notes'),
        '  Meet at the pro shop  ',
      );
      await _save(tester);

      expect(
        c.read(tripPlanProvider(melbourneId)).notes,
        'Meet at the pro shop',
      );
    });
  });

  group('chat settings', () {
    testWidgets('toggles apply straight away', (tester) async {
      final c = await pumpApp(tester, location: _section(TripEditSection.chat));

      await tester.tap(find.text('Mute notifications'));
      await tester.tap(find.text('Read receipts'));
      await tester.tap(find.text('Typing indicators'));
      await tester.pumpAndSettle();

      final settings = c.read(tripPlanProvider(melbourneId)).chatSettings;
      expect(settings.muted, isTrue);
      expect(settings.readReceipts, isFalse);
      expect(settings.typingIndicators, isFalse);
    });
  });

  group('players', () {
    testWidgets('removes a player after confirming, never the organiser', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.players),
      );

      expect(find.byTooltip('Remove Tiamana'), findsNothing);
      await tester.tap(find.byTooltip('Remove Ben'));
      await tester.pumpAndSettle();
      expect(find.text('Remove Ben?'), findsOneWidget);

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      final names = c
          .read(tripPlanProvider(melbourneId))
          .members
          .map((m) => m.displayName);
      expect(names, isNot(contains('Ben')));
      expect(names, contains('Tiamana'));
    });

    testWidgets('cancelling the confirmation keeps the player', (tester) async {
      final c = await pumpApp(
        tester,
        location: _section(TripEditSection.players),
      );

      await tester.tap(find.byTooltip('Remove Ben'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
        c.read(tripPlanProvider(melbourneId)).members.map((m) => m.displayName),
        contains('Ben'),
      );
    });

    testWidgets('invites friends who are not yet on the trip', (tester) async {
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
      c
          .read(appRouterProvider)
          .go(AppRoutes.tripEditSection(id, TripEditSection.players.slug));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ben'));
      await tester.pump();
      await tester.tap(find.text('Invite 1 friend'));
      await tester.pumpAndSettle();

      final members = c.read(tripPlanProvider(id)).members;
      expect(
        members.firstWhere((m) => m.displayName == 'Ben').status,
        ParticipantStatus.pending,
      );
    });
  });
}
