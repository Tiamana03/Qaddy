/// "Your game": the handicap and how it is moving, the career numbers and the
/// last round — one card that leads to the full statistics.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/dashboard/models/placeholder_dashboard.dart';
import 'package:qaddy/features/statistics/logic/stat_trend_formatting.dart';
import 'package:qaddy/features/statistics/models/stat_trend.dart';

/// A tappable card summarising the golfer's game.
class YourGameCard extends StatelessWidget {
  const YourGameCard({
    required this.handicap,
    required this.roundsPlayed,
    required this.averageScore,
    required this.bestRound,
    required this.lastRound,
    required this.onOpen,
    super.key,
  });

  /// How the handicap has moved.
  final StatTrend handicap;

  /// Career rounds played.
  final int roundsPlayed;

  /// Average score.
  final int averageScore;

  /// Best round.
  final int bestRound;

  /// The most recent completed round.
  final DashboardLastRound lastRound;

  /// Opens the full statistics.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final improving = handicap.isImprovement;
    final trendColour = improving ? colours.accent : colours.accentOrange;
    final won = lastRound.position == '1st';

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
      tween: Tween<double>(
        begin: animate ? 0 : handicap.currentValue,
        end: handicap.currentValue,
      ),
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

    return Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          'Your game. Handicap ${formatStatValue(handicap.currentValue)}, '
          '${formatTrendText(handicap)}. '
          '$roundsPlayed rounds played, average score $averageScore, '
          'best round $bestRound. '
          'Last round: ${lastRound.position} at ${lastRound.course}, '
          '${lastRound.score}. Opens your statistics.',
      child: QaddyCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'YOUR GAME',
                    style: typography.caption.copyWith(
                      color: colours.gold,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
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
                            color: trendColour.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(radius.large),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                improving
                                    ? Icons.trending_down
                                    : Icons.trending_up,
                                size: 16,
                                color: trendColour,
                              ),
                              SizedBox(width: spacing.xs),
                              Flexible(
                                child: Text(
                                  formatTrendText(handicap),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: typography.small.copyWith(
                                    color: trendColour,
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
            SizedBox(height: spacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                stat('$roundsPlayed', 'Rounds played'),
                stat('$averageScore', 'Average score'),
                stat('$bestRound', 'Best round'),
              ],
            ),
            SizedBox(height: spacing.lg),
            Container(
              padding: EdgeInsets.all(spacing.md),
              decoration: BoxDecoration(
                color: colours.surface2,
                borderRadius: BorderRadius.circular(radius.large),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colours.gold.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      won ? Icons.emoji_events : Icons.golf_course,
                      color: colours.gold,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          won
                              ? 'Won at ${lastRound.course}'
                              : '${lastRound.position} at ${lastRound.course}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.copyWith(
                            color: colours.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          '${lastRound.score} · ${lastRound.stableford} pts · '
                          '${lastRound.when}',
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
          ],
        ),
      ),
    );
  }
}
