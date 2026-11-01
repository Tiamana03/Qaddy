import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/widgets/forms/qaddy_date_time_fields.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/screens/create_trip_screen.dart';

import '../../trips_test_harness.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 2600);

  final container = await pumpTripsRouter(
    tester,
    initialLocation: '/trips/create',
    routes: <RouteBase>[
      GoRoute(
        path: '/trips',
        builder: (context, state) =>
            const Scaffold(body: Text('Trips Overview')),
        routes: <RouteBase>[
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateTripScreen(),
          ),
          GoRoute(
            path: ':tripId',
            builder: (context, state) => Scaffold(
              body: Text('Details of ${state.pathParameters['tripId']}'),
            ),
          ),
        ],
      ),
    ],
  );
  await tester.pumpAndSettle();
  return container;
}

/// Opens a date field and accepts the picker's default (today).
Future<void> _pickToday(WidgetTester tester, int fieldIndex) async {
  await tester.tap(find.byType(QaddyDateField).at(fieldIndex));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextField, 'Trip Name'),
    'Barossa',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Destination'),
    'Barossa Valley, Australia',
  );
  await _pickToday(tester, 0);
  await _pickToday(tester, 1);
}

void main() {
  testWidgets('is a full screen with every field the brief asks for', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Trip Name'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('Public'), findsOneWidget);
    expect(find.text('Invite Friends'), findsOneWidget);
    expect(find.textContaining('Cover image'), findsOneWidget);
    expect(find.text('Save Trip'), findsOneWidget);
  });

  testWidgets('previews the trip live as it is filled in', (tester) async {
    await _pump(tester);

    expect(find.text('Name your trip'), findsOneWidget);
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.text('When?'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Trip Name'),
      'Barossa Weekend',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Destination'),
      'Barossa Valley, Australia',
    );
    await tester.pump();

    expect(find.text('Barossa Weekend'), findsWidgets);
    expect(find.text('Barossa Valley, Australia'), findsWidgets);
    expect(find.text('Name your trip'), findsNothing);
    expect(find.text('Where to?'), findsNothing);
  });

  testWidgets('the preview takes on the chosen cover', (tester) async {
    await _pump(tester);

    await tester.tap(find.bySemanticsLabel('Coast cover'));
    await tester.pumpAndSettle();

    expect(find.text('Cover image — Coast'), findsOneWidget);
  });

  testWidgets('shows no errors until the first save attempt', (tester) async {
    await _pump(tester);

    expect(find.text('Give your trip a name'), findsNothing);

    await tester.tap(find.text('Save Trip'));
    await tester.pumpAndSettle();

    expect(find.text('Give your trip a name'), findsOneWidget);
    expect(find.text('Where are you going?'), findsOneWidget);
    expect(find.text('Pick a start date'), findsOneWidget);
    expect(find.text('Pick an end date'), findsOneWidget);
  });

  testWidgets('does not save an invalid form', (tester) async {
    final container = await _pump(tester);
    final before = container.read(tripsProvider).trips.length;

    await tester.tap(find.text('Save Trip'));
    await tester.pumpAndSettle();

    expect(container.read(tripsProvider).trips, hasLength(before));
    expect(find.text('Trips Overview'), findsNothing);
  });

  testWidgets('saving adds an upcoming, private trip and opens it', (
    tester,
  ) async {
    final container = await _pump(tester);

    await _fillValidForm(tester);
    await tester.tap(find.text('Save Trip'));
    await tester.pumpAndSettle();

    final created = container
        .read(upcomingTripsProvider)
        .firstWhere((trip) => trip.name == 'Barossa');
    expect(created.destination, 'Barossa Valley, Australia');
    expect(created.country, 'Australia');
    expect(created.status, TripStatus.planning);
    expect(created.visibility, TripVisibility.private);
    // Straight into the new trip, with the Trips list behind it.
    expect(find.text('Details of ${created.id}'), findsOneWidget);
    expect(find.text('Barossa added to Upcoming Trips'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(find.text('Trips Overview'), findsOneWidget);
  });

  testWidgets('Public is saved as the trip visibility', (tester) async {
    final container = await _pump(tester);

    await _fillValidForm(tester);
    await tester.tap(find.text('Public'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Anyone with the invite link'), findsOneWidget);
    await tester.tap(find.text('Save Trip'));
    await tester.pumpAndSettle();

    final created = container
        .read(tripsProvider)
        .trips
        .firstWhere((trip) => trip.name == 'Barossa');
    expect(created.visibility, TripVisibility.public);
  });

  testWidgets('ticked friends are invited as pending members', (tester) async {
    final container = await _pump(tester);

    await _fillValidForm(tester);
    await tester.tap(find.text('Ben'));
    await tester.pumpAndSettle();
    expect(find.text('Save Trip & Invite 1'), findsOneWidget);
    await tester.tap(find.text('Save Trip & Invite 1'));
    await tester.pumpAndSettle();

    final state = container.read(tripsProvider);
    final created = state.trips.firstWhere((trip) => trip.name == 'Barossa');
    final members = state.planFor(created.id).members;
    expect(members.map((m) => m.displayName), contains('Ben'));
    expect(
      members.firstWhere((m) => m.displayName == 'Ben').status,
      ParticipantStatus.pending,
    );
  });
}
