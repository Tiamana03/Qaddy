/// Qaddy's Transport screen — rental cars, transfers, rides and parking,
/// grouped by day.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/services/link_launcher.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/models/trip_edit_section.dart';
import 'package:qaddy/features/trips/models/trip_transport.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

/// Transport (route `/trips/:tripId/transport`).
class TripTransportScreen extends ConsumerWidget {
  const TripTransportScreen({required this.tripId, super.key});

  /// The trip whose transport is shown.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tripProvider(tripId)) == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final legs = <TripTransport>[...plan.transport]
      ..sort((a, b) => a.pickup.compareTo(b.pickup));
    final addRoute = AppRoutes.tripEditItem(
      tripId,
      TripEditSection.transport.slug,
      'new',
    );

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Transport'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add Transport',
            onPressed: () => context.push(addRoute),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            if (legs.isEmpty)
              QaddyEmptyState(
                icon: Icons.directions_car_outlined,
                title: 'No transport yet',
                message:
                    'Add rental cars, airport transfers, rides and parking so '
                    'everyone knows how they are getting around.',
                actionLabel: 'Add Transport',
                onAction: () => context.push(addRoute),
              )
            else ...<Widget>[
              for (final (index, leg) in legs.indexed) ...<Widget>[
                if (index == 0 || !legs[index - 1].pickup.isSameDay(leg.pickup))
                  Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 0 : spacing.lg,
                      bottom: spacing.sm,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        leg.pickup.toWeekdayAndDate(),
                        style: typography.h3.copyWith(
                          color: colours.textPrimary,
                        ),
                      ),
                    ),
                  ),
                _TransportCard(tripId: tripId, leg: leg),
                SizedBox(height: spacing.cardGap),
              ],
              SizedBox(height: spacing.md),
              QaddyGoldButton(
                label: 'Add Transport',
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

class _TransportCard extends ConsumerWidget {
  const _TransportCard({required this.tripId, required this.leg});

  final String tripId;
  final TripTransport leg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final place = leg.to.isNotEmpty
        ? leg.to
        : (leg.from.isNotEmpty ? leg.from : leg.type.label);

    return QaddyCard(
      onTap: () => context.push(
        AppRoutes.tripEditItem(tripId, TripEditSection.transport.slug, leg.id),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(leg.type.icon, color: colours.accent),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  leg.type.label,
                  style: typography.h4.copyWith(color: colours.textPrimary),
                ),
              ),
              Text(
                leg.pickup.toFriendlyTime(),
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
            ],
          ),
          if (leg.routeLabel.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.sm),
            Text(
              leg.routeLabel,
              style: typography.body.copyWith(color: colours.textPrimary),
            ),
          ],
          if (leg.driver.isNotEmpty || leg.vehicle.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.xs),
            Text(
              <String>[
                if (leg.driver.isNotEmpty) 'Driver: ${leg.driver}',
                if (leg.vehicle.isNotEmpty) leg.vehicle,
              ].join(' · '),
              style: typography.small.copyWith(color: colours.textSecondary),
            ),
          ],
          if (leg.bookingReference.isNotEmpty)
            CopyableRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Booking reference',
              value: leg.bookingReference,
              copiedMessage: 'Booking reference copied',
            ),
          if (leg.notes.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.xs),
            Text(
              leg.notes,
              style: typography.small.copyWith(color: colours.textTertiary),
            ),
          ],
          SizedBox(height: spacing.md),
          MapPlaceholder(
            label: place,
            height: 90,
            onTap: leg.routeLabel.isEmpty
                ? null
                : () => openLinkOrCopy(
                    context,
                    ref,
                    uri: leg.to.isNotEmpty
                        ? mapDirectionsUri(
                            destination: leg.to,
                            origin: leg.from,
                          )
                        : mapSearchUri(leg.from),
                    fallback: leg.routeLabel,
                    label: 'the route',
                  ),
          ),
        ],
      ),
    );
  }
}
