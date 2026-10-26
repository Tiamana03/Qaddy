/// Qaddy's trip card — summarises a single golf trip in a list.
///
/// Built on [QaddyCard], reusing [QaddyStatusBadge]. A month/day tile leads
/// the card (replacing the earlier empty "cover image" icon box, which looked
/// unfinished and squeezed trip names into a truncated "Melbourne …"); the
/// name now has the full row to itself and may wrap to two lines. Shows the
/// trip's date range, duration, status and player count.
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
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final (statusLabel, statusTone) = tripStatusBadgeContent(trip.status);
    final days = trip.durationInDays;

    return QaddyCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _DateTile(date: trip.startDate),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  trip.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.h4.copyWith(color: colours.textPrimary),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  trip.destination,
                  overflow: TextOverflow.ellipsis,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  '${trip.startDate.toFriendlyRange(trip.endDate)}  ·  '
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Row(
                  children: <Widget>[
                    QaddyStatusBadge(label: statusLabel, tone: statusTone),
                    SizedBox(width: spacing.sm),
                    Icon(
                      Icons.people_outline,
                      size: spacing.lg,
                      color: colours.textSecondary,
                    ),
                    SizedBox(width: spacing.xs),
                    Flexible(
                      child: Text(
                        '${trip.playerCount} Players',
                        overflow: TextOverflow.ellipsis,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onTap != null) ...<Widget>[
            SizedBox(width: spacing.sm),
            Icon(Icons.chevron_right, color: colours.textSecondary),
          ],
        ],
      ),
    );
  }
}

/// A small calendar-style tile showing the trip's start month and day.
class _DateTile extends StatelessWidget {
  const _DateTile({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      width: spacing.display + spacing.sm,
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      decoration: BoxDecoration(
        color: colours.surface2,
        borderRadius: BorderRadius.circular(radius.medium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            date.monthAbbreviation.toUpperCase(),
            style: typography.caption.copyWith(
              color: colours.accent,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          Text(
            '${date.day}',
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
        ],
      ),
    );
  }
}
