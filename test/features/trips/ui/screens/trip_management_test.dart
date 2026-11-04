// Trip management: settings, duplicate, archive, leave, delete, invite and
// export.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/services/share_service.dart';
import 'package:qaddy/features/trips/logic/trip_export.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

import '../../trips_test_harness.dart';

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

/// Taps the dialog's confirm button (the dialog also repeats the action
/// name in its title, so find the button by type).
Future<void> _confirm(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(Dialog), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Trip? _trip(ProviderContainer c, String id) =>
    c.read(tripsProvider).tripById(id);

void main() {
  group('trip settings', () {
    testWidgets('offers everything the brief asks for', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripSettings(melbourneId));

      for (final label in <String>[
        'Rename trip',
        'Change cover image',
        'Invite more friends',
        'Share invite',
        'Export itinerary',
        'Duplicate trip',
        'Archive trip',
        'Leave trip',
        'Delete trip',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('Share Invite opens the share sheet with the invite', (
      tester,
    ) async {
      final copied = captureClipboard(tester);
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Share invite');

      final message = shareOf(c).shared.single;
      expect(
        message,
        tripInviteMessage(melbourneGolfWeekend, melbourneGolfWeekendPlan),
      );
      expect(message, contains('Melbourne Golf Weekend'));
      expect(message, isNot(contains('http')));
      expect(
        shareOf(c).subjects.single,
        'Join Melbourne Golf Weekend on Qaddy',
      );
      expect(copied, isEmpty);
    });

    testWidgets('Share Invite copies instead when there is no share sheet', (
      tester,
    ) async {
      final copied = captureClipboard(tester);
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );
      shareOf(c).outcome = ShareOutcome.unavailable;

      await _tapText(tester, 'Share invite');

      expect(
        copied.single,
        tripInviteMessage(melbourneGolfWeekend, melbourneGolfWeekendPlan),
      );
      expect(find.text('Copied — paste it into a message'), findsOneWidget);
    });

    testWidgets('Duplicate makes a copy and opens it', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Duplicate trip');
      await _confirm(tester, 'Duplicate');

      final copy = c
          .read(tripsProvider)
          .trips
          .firstWhere((t) => t.name == 'Melbourne Golf Weekend (Copy)');
      expect(copy.id, isNot(melbourneId));
      expect(copy.status, TripStatus.planning);
      expect(_trip(c, melbourneId), isNotNull);
      // Opened the copy's details page.
      expect(find.text('Melbourne Golf Weekend (Copy)'), findsWidgets);
    });

    testWidgets('Archive moves the trip into the Archived list', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Archive trip');
      await _confirm(tester, 'Archive');

      expect(_trip(c, melbourneId)!.status, TripStatus.archived);
      expect(find.text('Archived'), findsWidgets);
    });

    testWidgets('an archived trip can be restored', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );
      c.read(tripsProvider.notifier).archiveTrip(melbourneId);
      await tester.pumpAndSettle();

      expect(find.text('Archive trip'), findsNothing);
      await _tapText(tester, 'Restore from Archive');

      expect(_trip(c, melbourneId)!.isUpcoming, isTrue);
    });

    testWidgets('Delete asks first, and Cancel keeps the trip', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Delete trip');
      expect(find.text('Delete this trip?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_trip(c, melbourneId), isNotNull);
    });

    testWidgets('Delete removes the trip and returns to Trips', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Delete trip');
      await _confirm(tester, 'Delete trip');

      expect(_trip(c, melbourneId), isNull);
      expect(find.text('Melbourne Golf Weekend'), findsNothing);
      expect(find.text('Create trip'), findsOneWidget);
    });

    testWidgets('Leave removes the trip from my list', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Leave trip');
      await _confirm(tester, 'Leave');

      expect(_trip(c, melbourneId), isNull);
    });

    testWidgets('trip details links to Edit Trip and Trip Settings', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripDetails(melbourneId));

      await tester.tap(find.byTooltip('Trip Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Duplicate trip'), findsOneWidget);
    });
  });

  group('invite friends', () {
    testWidgets('says so when everyone is already on the trip', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripInvite(melbourneId));

      expect(
        find.text('Everyone you play with is already on this trip.'),
        findsOneWidget,
      );
    });

    testWidgets('opens with who is coming and waits to offer the button', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripInvite(melbourneId));

      expect(find.text("Who's coming?"), findsOneWidget);
      expect(find.text('Your mates'), findsOneWidget);
      expect(find.text('Or send a message'), findsOneWidget);
      expect(find.textContaining('Invite 1'), findsNothing);
    });

    testWidgets('invites ticked friends and says so', (tester) async {
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
      c.read(appRouterProvider).go(AppRoutes.tripInvite(id));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ben'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invite 1 friend'));
      await tester.pumpAndSettle();

      expect(
        c.read(tripPlanProvider(id)).pendingMembers.map((m) => m.displayName),
        contains('Ben'),
      );
      expect(find.text('Invite sent'), findsOneWidget);
    });

    testWidgets('Share Invite shares the invite message', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripInvite(melbourneId),
      );

      await _tapText(tester, 'Share invite');

      expect(
        shareOf(c).shared.single,
        tripInviteMessage(melbourneGolfWeekend, melbourneGolfWeekendPlan),
      );
    });

    testWidgets('Copy Message copies the invite', (tester) async {
      final copied = captureClipboard(tester);
      await pumpApp(tester, location: AppRoutes.tripInvite(melbourneId));

      await _tapText(tester, 'Copy message');

      expect(
        copied.single,
        tripInviteMessage(melbourneGolfWeekend, melbourneGolfWeekendPlan),
      );
      expect(find.text('Invite copied'), findsOneWidget);
    });
  });

  group('export itinerary', () {
    testWidgets('previews the itinerary and copies it as text', (tester) async {
      final copied = captureClipboard(tester);
      await pumpApp(tester, location: AppRoutes.tripExport(melbourneId));

      expect(find.textContaining('MELBOURNE GOLF WEEKEND'), findsOneWidget);

      await _tapText(tester, 'Copy as Text');

      expect(
        copied.single,
        itineraryText(melbourneGolfWeekend, melbourneGolfWeekendPlan),
      );
      expect(find.text('Itinerary copied'), findsOneWidget);
    });

    testWidgets('Share Itinerary sends the itinerary to the share sheet', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripExport(melbourneId),
      );

      await _tapText(tester, 'Share itinerary');

      expect(
        shareOf(c).shared.single,
        itineraryText(melbourneGolfWeekend, melbourneGolfWeekendPlan),
      );
      expect(shareOf(c).subjects.single, 'Melbourne Golf Weekend itinerary');
    });

    testWidgets('has no half-built PDF button', (tester) async {
      await pumpApp(tester, location: AppRoutes.tripExport(melbourneId));

      expect(find.text('Download PDF'), findsNothing);
    });
  });
}
