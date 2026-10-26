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
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_trip_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_nav_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/logic/expense_ledger.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/models/trip_member.dart';
import 'package:qaddy/features/trips/models/trip_plan.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
import 'package:qaddy/features/trips/ui/widgets/chat/trip_message_bubble.dart';
import 'package:qaddy/features/trips/ui/widgets/detail/trip_detail_widgets.dart';
import 'package:qaddy/features/trips/ui/widgets/planning/planning_ring.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_not_found.dart';

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
    final done = plan.tasks.where((task) => task.done).length;

    return QaddyScaffold(
      appBar: AppBar(
        title: Text(trip.name),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit Trip',
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
          children: <Widget>[
            SizedBox(height: spacing.lg),
            _Overview(trip: trip, countdown: countdown),
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
                    label: 'Invite Friends',
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
              label: 'Complete Trip',
              onPressed: () => context.push(AppRoutes.tripComplete(tripId)),
            ),
            SizedBox(height: spacing.xl),
          ],
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
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final (statusLabel, statusTone) = tripStatusBadgeContent(trip.status);
    final description = trip.description;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              TripCoverTile(
                presetId: trip.coverImage,
                size: spacing.hero * 1.5,
              ),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      trip.name,
                      style: typography.h3.copyWith(color: colours.textPrimary),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      trip.destination,
                      style: typography.body.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                    Text(
                      trip.startDate.toFriendlyRange(trip.endDate),
                      style: typography.small.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              QaddyStatusBadge(label: statusLabel, tone: statusTone),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.large),
                  border: Border.all(color: colours.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      trip.visibility == TripVisibility.public
                          ? Icons.public
                          : Icons.lock_outline,
                      size: spacing.lg,
                      color: colours.textSecondary,
                    ),
                    SizedBox(width: spacing.xs),
                    Text(
                      trip.visibility == TripVisibility.public
                          ? 'Public'
                          : 'Private',
                      style: typography.small.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Countdown',
                style: typography.small.copyWith(color: colours.textTertiary),
              ),
              Text(
                '${countdown.value} ${countdown.label}',
                style: typography.small.copyWith(
                  color: colours.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...<Widget>[
            SizedBox(height: spacing.md),
            Text(
              description,
              style: typography.body.copyWith(color: colours.textPrimary),
            ),
          ],
        ],
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
