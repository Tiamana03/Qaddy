/// Qaddy's trip card — summarises a single golf trip in a list.
///
/// See `docs/sprints/sprint-03-01-trips-foundation.md`'s "Trip Card"
/// section: cover image placeholder, name, destination, dates, player
/// count, status badge and a chevron, visually matching the Dashboard
/// cards from Sprint 2.1. Built on [QaddyCard], reusing [QaddyStatusBadge].
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/trips/models/trip.dart';

/// The tone and label a [Trip]'s status renders with.
(String, QaddyStatusBadgeTone) tripStatusBadgeContent(TripStatus status) {
  return switch (status) {
    TripStatus.planning => ('Planning', QaddyStatusBadgeTone.info),
    TripStatus.inviting => ('Inviting', QaddyStatusBadgeTone.warning),
    TripStatus.confirmed => ('Confirmed', QaddyStatusBadgeTone.success),
    TripStatus.inProgress => ('In Progress', QaddyStatusBadgeTone.premium),
    TripStatus.completed => ('Completed', QaddyStatusBadgeTone.success),
    TripStatus.cancelled => ('Cancelled', QaddyStatusBadgeTone.error),
    TripStatus.archived => ('Archived', QaddyStatusBadgeTone.info),
  };
}

/// A summary card for one [Trip], used in the Trips list.
class QaddyTripCard extends StatelessWidget {
  const QaddyTripCard({required this.trip, this.onTap, super.key});

  /// The trip to summarise.
  final Trip trip;

  /// Called when the card is tapped. Omit for a non-interactive card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final (statusLabel, statusTone) = tripStatusBadgeContent(trip.status);

    return QaddyCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(radius.medium),
            child: Container(
              width: spacing.hero,
              height: spacing.hero,
              color: colours.surface2,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_outlined,
                color: colours.textTertiary,
                size: spacing.xl,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        trip.name,
                        style: typography.h4.copyWith(
                          color: colours.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    QaddyStatusBadge(label: statusLabel, tone: statusTone),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  trip.destination,
                  style: typography.body.copyWith(color: colours.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  '${trip.startDate.toFriendlyDate()} – '
                  '${trip.endDate.toFriendlyDate()}  ·  '
                  '${trip.playerCount} Players',
                  style: typography.small.copyWith(color: colours.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null) ...<Widget>[
            SizedBox(width: spacing.sm),
            Icon(Icons.chevron_right, color: colours.textTertiary),
          ],
        ],
      ),
    );
  }
}
