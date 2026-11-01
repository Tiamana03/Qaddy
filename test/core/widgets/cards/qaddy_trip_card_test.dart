import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/features/trips/models/trip.dart';

void main() {
  final trip = Trip(
    id: 'melbourne',
    name: 'Melbourne Golf Weekend',
    destination: 'Melbourne, Australia',
    country: 'Australia',
    startDate: DateTime(2026, 11, 28),
    endDate: DateTime(2026, 12),
    status: TripStatus.confirmed,
    organiserId: 'Tiamana',
    playerCount: 8,
  );

  Widget app(Widget card) => MaterialApp(
    theme: QaddyTheme.dark,
    home: Scaffold(body: card),
  );

  testWidgets('shows name, destination, dates, duration, players, status', (
    tester,
  ) async {
    await tester.pumpWidget(app(QaddyTripCard(trip: trip)));

    expect(find.text('Melbourne Golf Weekend'), findsOneWidget);
    expect(find.text('Melbourne, Australia'), findsOneWidget);
    expect(find.text('28 Nov – 1 Dec 2026  ·  4 days'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('8 Players'), findsOneWidget);
  });

  testWidgets('leads with a month/day tile for the start date', (tester) async {
    await tester.pumpWidget(app(QaddyTripCard(trip: trip)));

    expect(find.text('NOV'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
  });

  testWidgets('lets a long name wrap instead of truncating it', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(QaddyTripCard(trip: trip)));

    final title = tester.widget<Text>(find.text('Melbourne Golf Weekend'));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
  });

  testWidgets('shows a chevron only when tappable', (tester) async {
    await tester.pumpWidget(app(QaddyTripCard(trip: trip)));
    expect(find.byIcon(Icons.chevron_right), findsNothing);

    await tester.pumpWidget(app(QaddyTripCard(trip: trip, onTap: () {})));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('says "1 Player" for a single player', (tester) async {
    await tester.pumpWidget(
      app(QaddyTripCard(trip: trip.copyWith(playerCount: 1))),
    );

    expect(find.text('1 Player'), findsOneWidget);
    expect(find.text('1 Players'), findsNothing);
  });

  testWidgets('can lead with a custom tile instead of the date', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(QaddyTripCard(trip: trip, leading: const Text('COVER'))),
    );

    expect(find.text('COVER'), findsOneWidget);
    expect(find.text('NOV'), findsNothing);
  });

  testWidgets('presses down a touch while a finger is on a tappable card', (
    tester,
  ) async {
    await tester.pumpWidget(app(QaddyTripCard(trip: trip, onTap: () {})));
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    expect(scale(), 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Melbourne Golf Weekend')),
    );
    await tester.pump();
    expect(scale(), lessThan(1));

    await gesture.up();
    await tester.pump();
    expect(scale(), 1);
  });
}
