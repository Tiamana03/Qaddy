/// Qaddy's Flights screen — every flight booked for the trip.
///
/// See `docs/features/trips-feature-integration.md`'s "Travel" section.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Flights (route `/trips/:tripId/flights`).
class TripFlightsScreen extends ConsumerWidget {
  const TripFlightsScreen({required this.tripId, super.key});

  /// The trip whose flights are shown.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Flights')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final flight in plan.flights) ...<Widget>[
              QaddySectionCard(
                title: '${flight.airline} ${flight.flightNumber}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    QaddyInfoRow(
                      label: 'Departure',
                      value:
                          '${flight.fromAirport} '
                          '${flight.departure.toFriendlyTime()}',
                    ),
                    SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: 'Arrival',
                      value:
                          '${flight.toAirport} '
                          '${flight.arrival.toFriendlyTime()}',
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.sectionGap),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
