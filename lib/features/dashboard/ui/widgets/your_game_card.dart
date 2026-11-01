/// "Your game": the handicap and, once rounds have been played, what they say
/// — wins, average points, best round and the last round. One card that
/// leads to the full story in Statistics.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/dashboard/models/placeholder_dashboard.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/logic/stats_story.dart';

/// A tappable card summarising the golfer's game.
class YourGameCard extends StatelessWidget {
  const YourGameCard({
    required this.handicap,
    required this.stats,
    required this.lastRound,
    required this.onOpen,
    this.onOpenLastRound,
    super.key,
  });

  /// The golfer's handicap index.
  final double handicap;

  /// What their finished rounds say, or `null` before the first one.
  final CareerStats? stats;

  /// The round they last finished, or `null`.
  final DashboardLastRound? lastRound;

  /// Opens the full statistics.
  final VoidCallback onOpen;

  /// Opens the last round's results. Omit when there are none to show.
  final VoidCallback? onOpenLastRound;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final career = stats;
    final last = lastRound;
    final won = last?.position == '1st';

    final chipText = career == null
        ? 'Play a round to build your game'
        : career.wins == 1
        ? '1 win in ${roundsLabel(career.rounds)}'
        : '${career.wins} wins in ${roundsLabel(career.rounds)}';

    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: typography.h2.copyWith(color: colours.textPrimary),
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: typography.caption.copyWith(color: colours.textSecondary),
          ),
        ],
      ),
    );

    final handicapFigure = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0 : handicap, end: handicap),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        value.toStringAsFixed(1),
        style: typography.display.copyWith(
          color: colours.textPrimary,
          fontSize: 56,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );

    final spokenStats = career == null
        ? ''
        : 'Average ${career.averagePoints.round()} points a round, best '
              'round ${career.bestRound.points} points. ';
    final spokenLast = last == null
        ? ''
        : 'Last round: ${last.position} at ${last.course}, '
              '${last.stableford} points. ';

    return Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          'Your game. Handicap ${handicap.toStringAsFixed(1)}. $chipText. '
          '$spokenStats$spokenLast'
          'Opens your statistics.',
      child: QaddyCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(child: QaddyEyebrow('YOUR GAME')),
                Text(
                  'All stats',
                  style: typography.small.copyWith(color: colours.accent),
                ),
                Icon(Icons.chevron_right, color: colours.accent, size: 18),
              ],
            ),
            SizedBox(height: spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                handicapFigure,
                SizedBox(width: spacing.md),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: spacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Handicap',
                          style: typography.body.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: colours.gold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(radius.large),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                career == null
                                    ? Icons.flag_outlined
                                    : Icons.emoji_events_outlined,
                                size: 16,
                                color: colours.gold,
                              ),
                              SizedBox(width: spacing.xs),
                              Flexible(
                                child: Text(
                                  chipText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: typography.small.copyWith(
                                    color: colours.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (career != null) ...<Widget>[
              SizedBox(height: spacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  stat('${career.rounds}', 'Rounds played'),
                  stat('${career.averagePoints.round()}', 'Avg points'),
                  stat('${career.bestRound.points}', 'Best round pts'),
                ],
              ),
            ],
            if (last != null) ...<Widget>[
              SizedBox(height: spacing.lg),
              Material(
                color: colours.surface2,
                borderRadius: BorderRadius.circular(radius.large),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onOpenLastRound,
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: Row(
                      children: <Widget>[
                        QaddyIconBadge(
                          icon: won ? Icons.emoji_events : Icons.golf_course,
                          colour: colours.gold,
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                won
                                    ? 'Won at ${last.course}'
                                    : '${last.position} at ${last.course}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: typography.body.copyWith(
                                  color: colours.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: spacing.xs),
                              Text(
                                '${last.stableford} pts · ${last.score} '
                                'strokes · ${last.when}',
                                style: typography.small.copyWith(
                                  color: colours.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
