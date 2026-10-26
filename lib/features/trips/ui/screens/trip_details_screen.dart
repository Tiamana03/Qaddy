/// Qaddy's Trip Details screen — the central hub for a trip.
///
/// See `docs/features/trips-feature-integration.md`'s "Trip Details"
/// section ("Acts as the central hub for every trip") and "Button
/// Behaviour" table.
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
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/rows/qaddy_info_row.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';
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
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

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
            QaddySectionCard(
              title: 'Trip Overview',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  QaddyInfoRow(label: 'Destination', value: trip.destination),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(
                    label: 'Dates',
                    value: trip.startDate.toFriendlyRange(trip.endDate),
                  ),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(
                    label: 'Countdown',
                    value: trip.daysUntilStart > 0
                        ? '${trip.daysUntilStart} Days'
                        : 'Underway',
                  ),
                  SizedBox(height: spacing.sm),
                  QaddyInfoRow(label: 'Players', value: '${trip.playerCount}'),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Members',
              child: Wrap(
                spacing: spacing.md,
                runSpacing: spacing.md,
                children: <Widget>[
                  for (final member in plan.members)
                    _MemberTile(name: member.displayName),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Weather',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (index, day) in plan.weather.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.sm),
                    QaddyInfoRow(
                      label: day.day,
                      value:
                          '${day.forecast}  ${day.highLabel} / ${day.lowLabel}',
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            _QuickActionsCard(tripId: tripId),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return SizedBox(
      width: spacing.hero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          QaddyAvatar(name: name),
          SizedBox(height: spacing.xs),
          Text(
            name,
            textAlign: TextAlign.center,
            style: typography.small.copyWith(color: colours.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final actions = <(IconData, String, String)>[
      (Icons.edit_outlined, 'Planning', AppRoutes.tripPlanning(tripId)),
      (Icons.flight_outlined, 'View Flights', AppRoutes.tripFlights(tripId)),
      (
        Icons.hotel_outlined,
        'View Accommodation',
        AppRoutes.tripAccommodation(tripId),
      ),
      (Icons.golf_course_outlined, 'View Golf', AppRoutes.tripGolf(tripId)),
      (
        Icons.receipt_long_outlined,
        'View Expenses',
        AppRoutes.tripExpenses(tripId),
      ),
      (Icons.chat_bubble_outline, 'Open Chat', AppRoutes.tripChat(tripId)),
      (Icons.flag_outlined, 'Complete Trip', AppRoutes.tripComplete(tripId)),
    ];

    return QaddySectionCard(
      title: 'Quick Actions',
      child: Column(
        children: <Widget>[
          for (final (index, action) in actions.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            _ActionTile(
              icon: action.$1,
              label: action.$2,
              onTap: () => context.push(action.$3),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.medium),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Row(
            children: <Widget>[
              Icon(icon, color: colours.gold),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  label,
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
              ),
              Icon(Icons.chevron_right, color: colours.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
