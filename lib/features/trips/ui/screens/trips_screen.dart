/// Qaddy's Trips screen — the Trips destination and entry point to the full
/// Trips feature.
///
/// See `docs/features/trips-feature-integration.md`'s "Trips" section.
/// The screen leads with the next trip as a countdown hero (the thing a
/// golfer actually opens the app to check), then a compact summary, the
/// quick actions, and the remaining upcoming, past and archived trips. A
/// golfer with no trips yet sees a welcome instead of an empty list.
/// Selecting a trip opens Trip Details. Sections arrive in a gentle cascade.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_card_grid.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_hero_card.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_quick_actions.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_summary_card.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_welcome.dart';

/// The Trips destination (route `/trips`).
class TripsScreen extends ConsumerStatefulWidget {
  /// [now] defaults to the real clock; tests pass a fixed moment so the
  /// countdown doesn't depend on today's date.
  const TripsScreen({this.now, super.key});

  /// The moment the countdown is measured from.
  final DateTime? now;

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  /// Anchors the first list heading so "Browse Trips" can scroll to it.
  final GlobalKey _listKey = GlobalKey();

  void _browseTrips() {
    final target = _listKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: Theme.of(context).extension<QaddyMotion>()!.slow,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final upcoming = ref.watch(upcomingTripsProvider);
    final past = ref.watch(pastTripsProvider);
    final archived = ref.watch(archivedTripsProvider);
    final nextTrip = upcoming.isEmpty ? null : upcoming.first;
    final moreUpcoming = upcoming.skip(1).toList();
    final countries = <String>{
      for (final trip in <Trip>[...upcoming, ...past])
        if (trip.country.isNotEmpty) trip.country,
    };

    var listKeyUsed = false;
    Key? nextListKey() {
      if (listKeyUsed) {
        return null;
      }
      listKeyUsed = true;
      return _listKey;
    }

    // Each block after the title arrives a beat after the one before it.
    var step = 0;
    Widget arrive(Widget child) =>
        QaddyFadeSlideIn(delay: staggerDelay(step++), child: child);

    void createTrip() => context.push(AppRoutes.tripCreate);

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
            SizedBox(height: spacing.xl),
            if (nextTrip != null)
              arrive(_NextTripHero(trip: nextTrip, now: widget.now))
            else
              arrive(TripsWelcome(onCreateTrip: createTrip)),
            if (nextTrip != null) ...<Widget>[
              SizedBox(height: spacing.lg),
              arrive(
                TripsSummaryCard(
                  upcomingCount: upcoming.length,
                  pastCount: past.length,
                  countriesCount: countries.length,
                ),
              ),
              SizedBox(height: spacing.lg),
              arrive(
                TripsQuickActions(
                  onCreateTrip: createTrip,
                  onBrowseTrips: _browseTrips,
                ),
              ),
            ],
            if (moreUpcoming.isNotEmpty)
              _TripSection(
                label: 'Upcoming Trips',
                trips: moreUpcoming,
                headingKey: nextListKey(),
                firstStep: step++,
              ),
            if (past.isNotEmpty)
              _TripSection(
                label: 'Past Trips',
                trips: past,
                headingKey: nextListKey(),
                firstStep: step++,
              ),
            if (archived.isNotEmpty)
              _TripSection(
                label: 'Archived',
                trips: archived,
                headingKey: nextListKey(),
                firstStep: step++,
              ),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _NextTripHero extends ConsumerWidget {
  const _NextTripHero({required this.trip, required this.now});

  final Trip trip;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(tripPlanProvider(trip.id));
    final moment = now ?? ref.watch(tripsClockProvider)();
    final snapshot = tripSnapshot(plan, trip: trip, now: moment);

    return TripHeroCard(
      trip: trip,
      countdown: tripCountdown(trip, now: moment),
      snapshot: snapshot.isEmpty ? null : snapshot,
      onTap: () => context.push(AppRoutes.tripDetails(trip.id)),
    );
  }
}

class _TripSection extends StatelessWidget {
  const _TripSection({
    required this.label,
    required this.trips,
    required this.headingKey,
    required this.firstStep,
  });

  final String label;
  final List<Trip> trips;
  final Key? headingKey;
  final int firstStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyFadeSlideIn(
      delay: staggerDelay(firstStep),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: spacing.sectionGap),
          Semantics(
            header: true,
            child: Text(
              label,
              key: headingKey,
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
          ),
          SizedBox(height: spacing.md),
          TripCardGrid(
            children: <Widget>[
              for (final trip in trips)
                QaddyTripCard(
                  trip: trip,
                  isSample: TripsController.isSample(trip),
                  leading: TripCoverDateTile(trip: trip),
                  onTap: () => context.push(AppRoutes.tripDetails(trip.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
