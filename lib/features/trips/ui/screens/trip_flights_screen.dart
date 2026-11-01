/// Qaddy's Flights screen — every flight booked for the trip as a boarding
/// pass, soonest first.
///
/// See `docs/features/trips-feature-integration.md`'s "Travel" section. Each
/// flight opens its own page.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_flight.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// The label for a check-in status.
String checkInLabel(FlightCheckInStatus status) => switch (status) {
  FlightCheckInStatus.notOpen => 'Check-in not open',
  FlightCheckInStatus.open => 'Check-in open',
  FlightCheckInStatus.checkedIn => 'Checked in',
};

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
    final flights = <TripFlight>[...plan.flights]
      ..sort((a, b) => a.departure.compareTo(b.departure));
    final addRoute = AppRoutes.tripEditItem(
      tripId,
      TripEditSection.flights.slug,
      'new',
    );

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Flights'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add Flight',
            onPressed: () => context.push(addRoute),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            if (flights.isEmpty)
              QaddyEmptyState(
                icon: Icons.flight_takeoff,
                title: 'No flights yet',
                message:
                    'Add your flights to keep times, gates and booking '
                    'references in one place.',
                actionLabel: 'Add Flight',
                onAction: () => context.push(addRoute),
              )
            else ...<Widget>[
              for (final flight in flights) ...<Widget>[
                _BoardingPass(tripId: tripId, flight: flight),
                SizedBox(height: spacing.cardGap),
              ],
              SizedBox(height: spacing.md),
              QaddyPrimaryButton(
                label: 'Add Flight',
                onPressed: () => context.push(addRoute),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

class _BoardingPass extends StatelessWidget {
  const _BoardingPass({required this.tripId, required this.flight});

  final String tripId;
  final TripFlight flight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final checkedIn = flight.checkInStatus == FlightCheckInStatus.checkedIn;
    final duration = flight.arrival.difference(flight.departure);

    Widget fact(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: typography.small.copyWith(color: colours.textTertiary),
          ),
          Text(
            value.isEmpty ? '—' : value,
            style: typography.body.copyWith(color: colours.textPrimary),
          ),
        ],
      ),
    );

    return QaddyCard(
      onTap: () => context.push(AppRoutes.tripFlight(tripId, flight.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.flight_takeoff, color: colours.accent),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  '${flight.airline} ${flight.flightNumber}',
                  style: typography.h4.copyWith(color: colours.textPrimary),
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: checkedIn ? colours.surface2 : Colors.transparent,
                    borderRadius: BorderRadius.circular(radius.large),
                    border: Border.all(
                      color: checkedIn ? colours.accent : colours.border,
                    ),
                  ),
                  child: Text(
                    checkInLabel(flight.checkInStatus),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.small.copyWith(
                      color: checkedIn ? colours.accent : colours.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            flight.routeLabel,
            style: typography.body.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            '${flight.departure.toDayAndTime()} → '
            '${flight.arrival.toFriendlyTime()} · ${duration.toShortLabel()}',
            style: typography.small.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.md),
          Divider(color: colours.divider, height: 1),
          SizedBox(height: spacing.md),
          Row(
            children: <Widget>[
              fact('Terminal', flight.terminal),
              fact('Gate', flight.gate),
              fact('Seat', flight.seat),
            ],
          ),
        ],
      ),
    );
  }
}
