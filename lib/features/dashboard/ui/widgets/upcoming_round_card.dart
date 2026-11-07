/// "Upcoming Round": the next round as a card, as the approved mockup draws
/// it. A thumbnail slot, the course, the day, the tee time and who is playing,
/// then two actions: the quiet one (View details) and the gold one.
///
/// The thumbnail is a `QaddyMediaPlaceholder` until the course photograph
/// arrives. While a round is under way the card is the way back into it.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar_huddle.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';

/// The next-round card.
class UpcomingRoundCard extends StatelessWidget {
  const UpcomingRoundCard({
    required this.course,
    required this.primaryLabel,
    required this.onPrimary,
    this.day,
    this.when,
    this.teeTime,
    this.players = const <String>[],
    this.total = 0,
    this.sample = false,
    this.onDetails,
    super.key,
  });

  /// The course.
  final String course;

  /// The day, "Saturday".
  final String? day;

  /// How close it is, "In 3 days" or "Today".
  final String? when;

  /// The tee time, "8:20 AM".
  final String? teeTime;

  /// Who is playing, for the little faces.
  final List<String> players;

  /// How many are playing in all.
  final int total;

  /// Whether the round is the Sample Clubhouse's.
  final bool sample;

  /// The gold action ("Get ready", "Start round", "Continue round").
  final String primaryLabel;

  /// Runs the gold action.
  final VoidCallback onPrimary;

  /// The quiet action, "View details". Omit for none.
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 76,
                height: 76,
                child: QaddyMediaPlaceholder(
                  borderRadius: BorderRadius.circular(radius.medium),
                  tone: 1,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodyLarge.copyWith(
                        color: colours.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (day != null)
                      Text(
                        day!,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    if (when != null)
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: colours.textSecondary,
                          ),
                          SizedBox(width: spacing.xs),
                          Flexible(
                            child: Text(
                              when!,
                              maxLines: 1,
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
              if (teeTime != null || sample) ...<Widget>[
                SizedBox(width: spacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (teeTime != null)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            teeTime!,
                            style: typography.h4.copyWith(
                              color: colours.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (sample) ...<Widget>[
                        SizedBox(height: spacing.xs),
                        const SampleBadge(),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (players.length > 1) ...<Widget>[
            SizedBox(height: spacing.md),
            QaddyAvatarHuddle(
              names: players,
              total: total,
              textColour: colours.textSecondary,
            ),
          ],
          SizedBox(height: spacing.md),
          Row(
            children: <Widget>[
              if (onDetails != null) ...<Widget>[
                Expanded(
                  child: QaddySecondaryButton(
                    label: 'View details',
                    compact: true,
                    onPressed: onDetails,
                  ),
                ),
                SizedBox(width: spacing.sm),
              ],
              Expanded(
                child: QaddyGoldButton(
                  label: primaryLabel,
                  compact: true,
                  icon: Icons.flag_rounded,
                  onPressed: onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
