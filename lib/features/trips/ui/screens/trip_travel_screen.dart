/// Qaddy's Travel screen — flight and airport transfer information.
///
/// See `docs/features/trips-feature-integration.md`'s "Travel" section
/// ("Displays: Flights, Airport, Transfer information, Departure times,
/// Arrival times").
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_info_row.dart';

/// Travel (route `/trips/travel`).
class TripTravelScreen extends StatelessWidget {
  const TripTravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    const flight = melbourneGolfWeekendFlight;
    final airportTransfer = melbourneGolfWeekendTransport.firstWhere(
      (leg) => leg.type == 'Airport Transfer',
    );

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Travel')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddySectionCard(
              title: 'Flight',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TripInfoRow(
                    label: 'Airline',
                    value: '${flight.airline} ${flight.flightNumber}',
                  ),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(label: 'Departure', value: flight.departure),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(label: 'Arrival', value: flight.arrival),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Airport Transfer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TripInfoRow(
                    label: airportTransfer.details,
                    value: airportTransfer.time,
                  ),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(label: 'Date', value: airportTransfer.date),
                ],
              ),
            ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
