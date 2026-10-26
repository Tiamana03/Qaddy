/// Qaddy's Trips screen — the Trips destination and entry point to the full
/// Trips feature.
///
/// See `docs/features/trips-feature-integration.md`'s "Trips" section.
/// The screen leads with the next trip as a countdown hero (the thing a
/// golfer actually opens the app to check), then a compact summary, the
/// quick actions, and the remaining upcoming and past trips. Selecting a
/// trip opens Trip Details, matching that document's "Navigation Flow".
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_snapshot.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_card_grid.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_hero_card.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_quick_actions.dart';
import 'package:qaddy/features/trips/ui/widgets/trips_summary_card.dart';

/// The Trips destination (route `/trips`).
class TripsScreen extends StatefulWidget {
  /// [upcoming], [past] and [now] default to the shared placeholder trips and
  /// the real clock; tests pass their own so results don't depend on today's
  /// date.
  const TripsScreen({this.upcoming, this.past, this.now, super.key});

  /// Upcoming trips, soonest first. The first one is featured in the hero.
  final List<Trip>? upcoming;

  /// Past trips, newest first.
  final List<Trip>? past;

  /// The moment the countdown is measured from.
  final DateTime? now;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
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

    final upcoming = widget.upcoming ?? upcomingTrips;
    final past = widget.past ?? pastTrips;
    final nextTrip = upcoming.isEmpty ? null : upcoming.first;
    final moreUpcoming = upcoming.skip(1).toList();
    final countries = <String>{for (final trip in past) trip.country};

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
              QaddyFadeSlideIn(
                child: TripHeroCard(
                  trip: nextTrip,
                  countdown: tripCountdown(nextTrip, now: widget.now),
                  snapshot: tripSnapshot(nextTrip),
                  onTap: _isDetailed(nextTrip)
                      ? () => context.push(AppRoutes.tripDetails)
                      : null,
                ),
              )
            else
              const QaddyEmptyState(
                icon: Icons.flight_takeoff,
                title: 'No trips planned yet',
                message:
                    'Tap Create Trip to plan your next golf getaway — your '
                    'countdown will live right here.',
              ),
            SizedBox(height: spacing.lg),
            TripsSummaryCard(
              upcomingCount: upcoming.length,
              pastCount: past.length,
              countriesCount: countries.length,
            ),
            SizedBox(height: spacing.lg),
            TripsQuickActions(
              onCreateTrip: () => context.push(AppRoutes.tripDetails),
              onBrowseTrips: _browseTrips,
            ),
            if (moreUpcoming.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              _SectionHeading(label: 'Coming Up', headingKey: _listKey),
              SizedBox(height: spacing.md),
              TripCardGrid(
                children: <Widget>[
                  for (final trip in moreUpcoming) _TripListCard(trip: trip),
                ],
              ),
            ],
            if (past.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              _SectionHeading(
                label: 'Past Trips',
                headingKey: moreUpcoming.isEmpty ? _listKey : null,
              ),
              SizedBox(height: spacing.md),
              TripCardGrid(
                children: <Widget>[
                  for (final trip in past) _TripListCard(trip: trip),
                ],
              ),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Whether [trip] is the one trip with full detail data (see
/// `docs/features/trips-feature-integration.md`'s "Shared Placeholder Data").
bool _isDetailed(Trip trip) => trip.id == melbourneGolfWeekend.id;

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label, this.headingKey});

  final String label;
  final Key? headingKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      header: true,
      child: Text(
        label,
        key: headingKey,
        style: typography.h3.copyWith(color: colours.textPrimary),
      ),
    );
  }
}

/// A trip card that opens Trip Details only for Melbourne Golf Weekend — the
/// only trip with full detail data. Other trips render the same card without
/// navigation, since there's no detail data for them to open.
class _TripListCard extends StatelessWidget {
  const _TripListCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return QaddyTripCard(
      trip: trip,
      onTap: _isDetailed(trip)
          ? () => context.push(AppRoutes.tripDetails)
          : null,
    );
  }
}
