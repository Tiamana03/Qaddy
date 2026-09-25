/// Qaddy's Trips screen — the Trips destination and entry point to the
/// full Trips feature.
///
/// See `docs/sprints/sprint-03-01-trips-foundation.md` and
/// `docs/features/trips-feature-integration.md`. Selecting a trip opens
/// Trip Details, matching that document's "Navigation Flow" ("Selecting a
/// trip opens the Trip Details screen").
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_quick_actions.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_summary_card.dart';

/// The Trips destination (route `/trips`) — every upcoming and past trip.
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final upcomingTripsKey = GlobalKey();

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Trips',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.sectionGap),
            const TripsSummaryCard(
              upcomingCount: upcomingTripsCount,
              pastCount: pastTripsCount,
              countriesCount: countriesVisitedCount,
            ),
            SizedBox(height: spacing.sectionGap),
            TripsQuickActions(
              onCreateTrip: () => context.push(AppRoutes.tripDetails),
              onBrowseTrips: () {
                final target = upcomingTripsKey.currentContext;
                if (target != null) {
                  Scrollable.ensureVisible(
                    target,
                    duration: const Duration(milliseconds: 300),
                  );
                }
              },
            ),
            SizedBox(height: spacing.sectionGap),
            Text(
              'Upcoming Trips',
              key: upcomingTripsKey,
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.md),
            for (final (index, trip) in upcomingTrips.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              _TripListCard(trip: trip),
            ],
            SizedBox(height: spacing.sectionGap),
            Text(
              'Past Trips',
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.md),
            for (final (index, trip) in pastTrips.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              _TripListCard(trip: trip),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

/// A trip card that opens Trip Details when the trip is Melbourne Golf
/// Weekend — the only trip with full detail data (see
/// `docs/features/trips-feature-integration.md`'s "Shared Placeholder
/// Data"). Other trips render the same card without navigation, since
/// there's no detail data for them to open.
class _TripListCard extends StatelessWidget {
  const _TripListCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final isDetailed = trip.id == melbourneGolfWeekend.id;

    return QaddyTripCard(
      trip: trip,
      onTap: isDetailed ? () => context.push(AppRoutes.tripDetails) : null,
    );
  }
}
