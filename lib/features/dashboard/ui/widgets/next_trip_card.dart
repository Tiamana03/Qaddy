/// The next golf trip on the Dashboard, as a countdown — or, when nothing is
/// planned, an invitation to plan one.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/trips/logic/trip_countdown.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/ui/widgets/trip_cover_tile.dart';

/// A card for [trip] that opens it. Pass `null` for [trip] to invite the
/// golfer to plan one instead.
class NextTripCard extends StatelessWidget {
  const NextTripCard({
    required this.trip,
    required this.now,
    required this.onOpen,
    super.key,
  });

  /// The next trip, or `null` when none is planned.
  final Trip? trip;

  /// The moment the countdown is measured from.
  final DateTime now;

  /// Opens [trip], or the Create Trip form when there is none.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final borderRadius = BorderRadius.circular(radius.extraLarge);
    final planned = trip;

    final countdown = planned == null ? null : tripCountdown(planned, now: now);
    final eyebrow = countdown == null
        ? 'NEXT TRIP'
        : tripCountdownEyebrow(countdown);
    final title = planned?.name ?? 'Plan your next golf trip';
    final detail = planned == null
        ? 'Pick the dates and bring the Saturday Boys.'
        : '${planned.destination} · '
              '${planned.startDate.toFriendlyRange(planned.endDate)}';

    final spoken = countdown == null
        ? ''
        : ' ${countdown.value} ${countdown.label}.';

    return Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label: '$eyebrow. $title. $detail.$spoken',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadows.medium,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: tripCoverGradient(colours, planned?.coverImage),
              ),
              child: InkWell(
                onTap: onOpen,
                child: Padding(
                  padding: EdgeInsets.all(spacing.xl),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            QaddyEyebrow(eyebrow),
                            SizedBox(height: spacing.sm),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: typography.h3.copyWith(color: onGradient),
                            ),
                            SizedBox(height: spacing.xs),
                            Text(
                              detail,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: typography.small.copyWith(
                                color: onGradient.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      if (countdown != null)
                        Column(
                          children: <Widget>[
                            Text(
                              countdown.value,
                              style: typography.display.copyWith(
                                color: onGradient,
                              ),
                            ),
                            Text(
                              countdown.label,
                              style: typography.caption.copyWith(
                                color: onGradient.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        )
                      else
                        Icon(
                          Icons.add_circle_outline,
                          color: colours.gold,
                          size: 36,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
