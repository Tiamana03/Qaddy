/// One flight's page: times, gate and seat, booking reference, check-in
/// status and maps of both airports.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/forms/qaddy_chip_selector.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/screens/trip_flights_screen.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Flight page (route `/trips/:tripId/flights/:flightId`).
class TripFlightScreen extends ConsumerWidget {
  const TripFlightScreen({
    required this.tripId,
    required this.flightId,
    super.key,
  });

  /// The trip the flight belongs to.
  final String tripId;

  /// The flight to show.
  final String flightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    TripFlight? flight;
    for (final candidate in plan.flights) {
      if (candidate.id == flightId) {
        flight = candidate;
      }
    }
    if (flight == null) {
      return const TripNotFound();
    }
    final shown = flight;

    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final duration = shown.arrival.difference(shown.departure);
    final boarding = shown.boarding;

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Flight'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit Flight',
            onPressed: () => context.push(
              AppRoutes.tripEditItem(
                tripId,
                TripEditSection.flights.slug,
                shown.id,
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            DetailHeader(
              icon: Icons.flight_takeoff,
              title: '${shown.airline} ${shown.flightNumber}',
              subtitle: shown.routeLabel,
              facts: <String>[
                shown.departure.toShortWeekdayAndDate(),
                duration.toShortLabel(),
                checkInLabel(shown.checkInStatus),
              ],
            ),
            const DetailSectionTitle('Times'),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  FactRow(
                    label: 'Departs',
                    value: shown.departure.toDayAndTime(),
                  ),
                  FactRow(
                    label: 'Arrives',
                    value: shown.arrival.toDayAndTime(),
                  ),
                  FactRow(label: 'Duration', value: duration.toShortLabel()),
                  if (boarding != null)
                    FactRow(
                      label: 'Boarding',
                      value: boarding.toFriendlyTime(),
                    ),
                ],
              ),
            ),
            const DetailSectionTitle('At the Airport'),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  FactRow(
                    label: 'Terminal',
                    value: shown.terminal.isEmpty ? 'TBC' : shown.terminal,
                  ),
                  FactRow(
                    label: 'Gate',
                    value: shown.gate.isEmpty ? 'TBC' : shown.gate,
                  ),
                  FactRow(
                    label: 'Seat',
                    value: shown.seat.isEmpty ? 'Not assigned' : shown.seat,
                  ),
                ],
              ),
            ),
            const DetailSectionTitle('Booking'),
            QaddyCard(
              child: shown.bookingReference.isEmpty
                  ? Text(
                      'No booking reference yet.',
                      style: typography.body.copyWith(
                        color: colours.textSecondary,
                      ),
                    )
                  : CopyableRow(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Booking reference',
                      value: shown.bookingReference,
                      copiedMessage: 'Booking reference copied',
                    ),
            ),
            const DetailSectionTitle('Check-in'),
            QaddyChipSelector<FlightCheckInStatus>(
              options: const <QaddyChipOption<FlightCheckInStatus>>[
                QaddyChipOption(
                  value: FlightCheckInStatus.notOpen,
                  label: 'Not open',
                ),
                QaddyChipOption(value: FlightCheckInStatus.open, label: 'Open'),
                QaddyChipOption(
                  value: FlightCheckInStatus.checkedIn,
                  label: 'Checked in',
                ),
              ],
              selected: shown.checkInStatus,
              onChanged: (status) => ref
                  .read(tripsProvider.notifier)
                  .updatePlan(
                    tripId,
                    (plan) => plan.copyWith(
                      flights: <TripFlight>[
                        for (final f in plan.flights)
                          if (f.id == shown.id)
                            f.copyWith(checkInStatus: status)
                          else
                            f,
                      ],
                    ),
                  ),
            ),
            const DetailSectionTitle('Airports'),
            MapPlaceholder(label: shown.fromAirport, height: 120),
            SizedBox(height: spacing.sm),
            MapPlaceholder(label: shown.toAirport, height: 120),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}
