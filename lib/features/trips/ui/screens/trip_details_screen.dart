/// Qaddy's Trip Details screen — the central hub for a trip.
///
/// See `docs/features/trips-feature-integration.md`'s "Trip Details"
/// section ("Acts as the central hub for every trip") and "Button
/// Behaviour" table. A cover and countdown lead; below it are planning
/// progress, a row for every part of the trip (each with a live summary),
/// the players, the weather and the notes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/rows/qaddy_nav_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/logic/trip_setup.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_cover.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/chat/trip_message_bubble.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_setup_card.dart';

/// Trip Details (route `/trips/:tripId`).
class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({required this.tripId, super.key});

  /// The trip to show.
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    if (trip == null) {
      return const TripNotFound();
    }
    final plan = ref.watch(tripPlanProvider(tripId));
    final now = ref.watch(tripsClockProvider)();
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final countdown = tripCountdown(trip, now: now);

    String count(int n, String singular, String plural) =>
        n == 0 ? 'Nothing added yet' : '$n ${n == 1 ? singular : plural}';

    final summary = summariseExpenses(plan.expenses);
    final latest = plan.messages.isEmpty ? null : plan.messages.last;
    final progress = plan.planningProgress;
    final setup = tripSetupSteps(tripId, plan);
    final done = plan.tasks.where((task) => task.done).length;

    return QaddyScaffold(
      appBar: AppBar(
        title: Text(trip.name),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit trip',
            onPressed: () => context.push(AppRoutes.tripEdit(tripId)),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Trip Settings',
            onPressed: () => context.push(AppRoutes.tripSettings(tripId)),
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            _Overview(trip: trip, countdown: countdown),
            if (setup.any((step) => !step.done)) ...<Widget>[
              SizedBox(height: spacing.cardGap),
              TripSetupCard(steps: setup),
            ],
            SizedBox(height: spacing.cardGap),
            QaddyCard(
              onTap: () => context.push(AppRoutes.tripPlanning(tripId)),
              child: Row(
                children: <Widget>[
                  PlanningRing(
                    progress: progress ?? 0,
                    label: progress == null
                        ? '—'
                        : '${(progress * 100).round()}%',
                    semanticLabel: progress == null
                        ? 'No planning tasks yet'
                        : 'Planning ${(progress * 100).round()} percent '
                              'complete',
                  ),
                  SizedBox(width: spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Planning',
                          style: typography.h4.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                        Text(
                          plan.tasks.isEmpty
                              ? 'Start your daily plan and checklist'
                              : plan.nextTask == null
                              ? 'Everything is done'
                              : '$done of ${plan.tasks.length} done · '
                                    'Next: ${plan.nextTask!.title}',
                          style: typography.small.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colours.textTertiary),
                ],
              ),
            ),
            const DetailSectionTitle('The Trip'),
            QaddyCard(
              child: Column(
                children: <Widget>[
                  QaddyNavRow(
                    icon: Icons.flight_takeoff,
                    title: 'Flights',
                    subtitle: count(plan.flights.length, 'flight', 'flights'),
                    onTap: () => context.push(AppRoutes.tripFlights(tripId)),
                  ),
                  QaddyNavRow(
                    icon: Icons.hotel_outlined,
                    title: 'Accommodation',
                    subtitle: count(
                      plan.accommodations.length,
                      'stay',
                      'stays',
                    ),
                    onTap: () =>
                        context.push(AppRoutes.tripAccommodation(tripId)),
                  ),
                  QaddyNavRow(
                    icon: Icons.directions_car_outlined,
                    title: 'Transport',
                    subtitle: count(
                      plan.transport.length,
                      'booking',
                      'bookings',
                    ),
                    onTap: () => context.push(AppRoutes.tripTransport(tripId)),
                  ),
                  QaddyNavRow(
                    icon: Icons.golf_course_outlined,
                    title: 'Golf',
                    subtitle: count(plan.courses.length, 'course', 'courses'),
                    onTap: () => context.push(AppRoutes.tripGolf(tripId)),
                  ),
                  QaddyNavRow(
                    icon: Icons.payments_outlined,
                    title: 'Expenses',
                    subtitle: plan.expenses.isEmpty
                        ? 'Nothing added yet'
                        : summary.isSettled
                        ? '${formatMoney(summary.total)} · all settled'
                        : '${formatMoney(summary.total)} · '
                              '${formatMoney(summary.outstanding)} to pay',
                    onTap: () => context.push(AppRoutes.tripExpenses(tripId)),
                  ),
                  QaddyNavRow(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chat',
                    subtitle: latest == null
                        ? 'No messages yet'
                        : '${latest.sender}: ${latest.text}',
                    onTap: () => context.push(AppRoutes.tripChat(tripId)),
                  ),
                ],
              ),
            ),
            const DetailSectionTitle('Players'),
            QaddyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: spacing.md,
                    runSpacing: spacing.md,
                    children: <Widget>[
                      for (final member in plan.members)
                        _Player(
                          name: member.displayName,
                          pending: member.status != ParticipantStatus.confirmed,
                        ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  QaddySecondaryButton(
                    label: 'Invite friends',
                    onPressed: () => context.push(AppRoutes.tripInvite(tripId)),
                  ),
                ],
              ),
            ),
            if (plan.weather.isNotEmpty) ...<Widget>[
              const DetailSectionTitle('Weather'),
              _WeatherStrip(plan: plan),
            ],
            if (plan.notes.trim().isNotEmpty) ...<Widget>[
              const DetailSectionTitle('Notes'),
              QaddyCard(
                child: Text(
                  plan.notes,
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
              ),
            ],
            SizedBox(height: spacing.sectionGap),
            QaddySecondaryButton(
              label: 'Complete trip',
              onPressed: () => context.push(AppRoutes.tripComplete(tripId)),
            ),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.trip, required this.countdown});

  final Trip trip;
  final TripCountdown countdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.78);
    final (statusLabel, statusTone) = tripStatusBadgeContent(trip.status);
    final description = trip.description;
    final borderRadius = BorderRadius.circular(radius.extraLarge);

    Widget chip(IconData icon, String label) => Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: onGradient.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radius.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: spacing.lg, color: onGradient),
          SizedBox(width: spacing.xs),
          Text(label, style: typography.small.copyWith(color: onGradient)),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows.large,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: tripCoverGradient(colours, trip.coverImage),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -spacing.xl,
                top: -spacing.lg,
                child: ExcludeSemantics(
                  child: Icon(
                    tripCoverFor(trip.coverImage).icon,
                    size: 220,
                    color: onGradient.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: QaddyEyebrow(tripCountdownEyebrow(countdown)),
                        ),
                        if (TripsController.isSample(trip)) ...<Widget>[
                          const SampleBadge(onGradient: true),
                          const SizedBox(width: 8),
                        ],
                        QaddyStatusBadge(label: statusLabel, tone: statusTone),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    Semantics(
                      label: 'Countdown: ${countdown.value} ${countdown.label}',
                      excludeSemantics: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Text(
                            countdown.value,
                            style:
                                (countdown.value.length <= 3
                                        ? typography.display
                                        : typography.h1)
                                    .copyWith(color: colours.gold),
                          ),
                          SizedBox(width: spacing.sm),
                          Flexible(
                            child: Text(
                              countdown.label,
                              style: typography.bodyLarge.copyWith(
                                color: muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.sm),
                    Text(
                      trip.name,
                      style: typography.h2.copyWith(color: onGradient),
                    ),
                    SizedBox(height: spacing.xs),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on_outlined,
                          size: spacing.lg,
                          color: muted,
                        ),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            trip.destination,
                            style: typography.body.copyWith(color: muted),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${trip.startDate.toFriendlyRange(trip.endDate)}  ·  '
                      '${trip.durationInDays} days',
                      style: typography.small.copyWith(color: muted),
                    ),
                    SizedBox(height: spacing.md),
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.sm,
                      children: <Widget>[
                        chip(
                          trip.visibility == TripVisibility.public
                              ? Icons.public
                              : Icons.lock_outline,
                          trip.visibility == TripVisibility.public
                              ? 'Public'
                              : 'Private',
                        ),
                        chip(
                          Icons.groups_outlined,
                          trip.playerCount == 1
                              ? '1 player'
                              : '${trip.playerCount} players',
                        ),
                      ],
                    ),
                    if (description != null && description.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: spacing.md),
                        child: Text(
                          description,
                          style: typography.body.copyWith(color: onGradient),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player({required this.name, required this.pending});

  final String name;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Opacity(
          opacity: pending ? 0.5 : 1,
          child: ChatAvatar(name: name),
        ),
        SizedBox(width: spacing.sm),
        Text(
          pending ? '$name (invited)' : name,
          style: typography.body.copyWith(
            color: pending ? colours.textSecondary : colours.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _WeatherStrip extends StatelessWidget {
  const _WeatherStrip({required this.plan});

  final TripPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Row(
        children: <Widget>[
          for (final day in plan.weather)
            Expanded(
              child: Semantics(
                label:
                    '${day.day}: ${day.forecast}, high ${day.highLabel}, '
                    'low ${day.lowLabel}',
                excludeSemantics: true,
                child: Column(
                  children: <Widget>[
                    Text(
                      day.day.length > 3 ? day.day.substring(0, 3) : day.day,
                      style: typography.small.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Icon(day.condition.icon, color: colours.accent),
                    SizedBox(height: spacing.xs),
                    Text(
                      day.highLabel,
                      style: typography.small.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                    Text(
                      day.lowLabel,
                      style: typography.small.copyWith(
                        color: colours.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
