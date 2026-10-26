// Trip management: settings, duplicate, archive, leave, delete, invite and
// export.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/routing/app_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/features/trips/logic/trip_export.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

import '../../trips_test_harness.dart';

/// Records what the app puts on the clipboard.
List<String> _captureClipboard(WidgetTester tester) {
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

/// Taps the dialog's confirm button (the dialog also repeats the action
/// name in its title, so find the button by type).
Future<void> _confirm(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(AlertDialog), matching: find.text(label)),
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
        'Rename Trip',
        'Change Cover Image',
        'Invite More Friends',
        'Share Invite Link',
        'Export Itinerary',
        'Duplicate Trip',
        'Archive Trip',
        'Leave Trip',
        'Delete Trip',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('Share Invite Link copies the trip link', (tester) async {
      final copied = _captureClipboard(tester);
      await pumpApp(tester, location: AppRoutes.tripSettings(melbourneId));

      await _tapText(tester, 'Share Invite Link');

      expect(copied, <String>[tripInviteLink(melbourneGolfWeekend)]);
      expect(find.text('Invite link copied'), findsOneWidget);
    });

    testWidgets('Duplicate makes a copy and opens it', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Duplicate Trip');
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

      await _tapText(tester, 'Archive Trip');
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

      expect(find.text('Archive Trip'), findsNothing);
      await _tapText(tester, 'Restore from Archive');

      expect(_trip(c, melbourneId)!.isUpcoming, isTrue);
    });

    testWidgets('Delete asks first, and Cancel keeps the trip', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Delete Trip');
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

      await _tapText(tester, 'Delete Trip');
      await _confirm(tester, 'Delete Trip');

      expect(_trip(c, melbourneId), isNull);
      expect(find.text('Melbourne Golf Weekend'), findsNothing);
      expect(find.text('Create Trip'), findsOneWidget);
    });

    testWidgets('Leave removes the trip from my list', (tester) async {
      final c = await pumpApp(
        tester,
        location: AppRoutes.tripSettings(melbourneId),
      );

      await _tapText(tester, 'Leave Trip');
      await _confirm(tester, 'Leave');

      expect(_trip(c, melbourneId), isNull);
    });

    testWidgets('trip details links to Edit Trip and Trip Settings', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripDetails(melbourneId));

      await tester.tap(find.byTooltip('Trip Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Duplicate Trip'), findsOneWidget);
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
      await tester.pump();
      await tester.tap(find.text('Invite 1 friend'));
      await tester.pumpAndSettle();

      expect(
        c.read(tripPlanProvider(id)).pendingMembers.map((m) => m.displayName),
        contains('Ben'),
      );
      expect(find.text('Invite sent'), findsOneWidget);
    });

    testWidgets('Copy Link copies the invite link', (tester) async {
      final copied = _captureClipboard(tester);
      await pumpApp(tester, location: AppRoutes.tripInvite(melbourneId));

      await _tapText(tester, 'Copy Link');

      expect(copied.single, startsWith('https://qaddy.example/join/'));
    });
  });

  group('export itinerary', () {
    testWidgets('previews the itinerary and copies it', (tester) async {
      final copied = _captureClipboard(tester);
      await pumpApp(tester, location: AppRoutes.tripExport(melbourneId));

      expect(find.textContaining('MELBOURNE GOLF WEEKEND'), findsOneWidget);

      await _tapText(tester, 'Copy Itinerary');

      expect(
        copied.single,
        itineraryText(melbourneGolfWeekend, melbourneGolfWeekendPlan),
      );
      expect(find.text('Itinerary copied'), findsOneWidget);
    });

    testWidgets('Download PDF is honest that it is not available yet', (
      tester,
    ) async {
      await pumpApp(tester, location: AppRoutes.tripExport(melbourneId));

      await _tapText(tester, 'Download PDF');

      expect(find.text('PDF export is coming soon'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
