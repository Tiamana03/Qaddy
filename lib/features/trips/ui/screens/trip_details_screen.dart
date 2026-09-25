/// Qaddy's Trip Details screen — the central hub for a trip.
///
/// See `docs/features/trips-feature-integration.md`'s "Trip Details"
/// section ("Acts as the central hub for every trip") and "Button
/// Behaviour" table. Displays Melbourne Golf Weekend — the shared
/// placeholder trip (see `placeholder_trips.dart`).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/trips/models/placeholder_trips.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_info_row.dart';

/// Trip Details (route `/trips/details`) — destination, dates, members,
/// countdown, weather and quick actions for the shared placeholder trip.
class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final trip = melbourneGolfWeekend;

    return QaddyScaffold(
      appBar: AppBar(title: Text(trip.name)),
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
                  TripInfoRow(label: 'Destination', value: trip.destination),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(
                    label: 'Dates',
                    value:
                        '${trip.startDate.toFriendlyDate()} – '
                        '${trip.endDate.toFriendlyDate()}',
                  ),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(
                    label: 'Countdown',
                    value: trip.daysUntilStart > 0
                        ? '${trip.daysUntilStart} Days'
                        : 'Underway',
                  ),
                  SizedBox(height: spacing.sm),
                  TripInfoRow(label: 'Players', value: '${trip.playerCount}'),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            const _MembersCard(),
            SizedBox(height: spacing.sectionGap),
            const _WeatherCard(),
            SizedBox(height: spacing.sectionGap),
            const _QuickActionsCard(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddySectionCard(
      title: 'Members',
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.md,
        children: <Widget>[
          for (final member in melbourneGolfWeekendMembers)
            SizedBox(
              width: spacing.hero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  QaddyAvatar(name: member.displayName),
                  SizedBox(height: spacing.xs),
                  Text(
                    member.displayName,
                    textAlign: TextAlign.center,
                    style: typography.small.copyWith(
                      color: colours.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Weather',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, day)
              in melbourneGolfWeekendWeather.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            TripInfoRow(
              label: day.day,
              value: '${day.forecast}  ${day.high} / ${day.low}',
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    const actions = <(IconData, String, String)>[
      (Icons.edit_outlined, 'Edit Trip', AppRoutes.tripPlanning),
      (Icons.flight_outlined, 'View Flights', AppRoutes.tripTravel),
      (Icons.hotel_outlined, 'View Accommodation', AppRoutes.tripAccommodation),
      (Icons.golf_course_outlined, 'View Golf', AppRoutes.tripGolf),
      (Icons.receipt_long_outlined, 'View Expenses', AppRoutes.tripExpenses),
      (Icons.chat_bubble_outline, 'Open Chat', AppRoutes.tripChat),
      (Icons.flag_outlined, 'Complete Trip', AppRoutes.tripComplete),
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
