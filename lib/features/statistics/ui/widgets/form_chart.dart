/// The form guide: one bar per recent round, tall for a good day. The latest
/// round is gold; a trophy marks the rounds you won.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

/// A bar chart of Stableford points per eighteen holes, oldest round first.
class FormChart extends StatelessWidget {
  const FormChart({required this.rounds, super.key});

  /// The rounds to chart, oldest first.
  final List<YourRound> rounds;

  static const double _barArea = 112;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final top = rounds.fold<double>(
      36,
      (max, r) => r.pointsPer18 > max ? r.pointsPer18 : max,
    );
    final description = rounds
        .map(
          (r) =>
              '${r.date.day} ${r.date.monthAbbreviation}: '
              '${r.pointsPer18.round()} points${r.won ? ', won' : ''}',
        )
        .join('. ');

    return Semantics(
      container: true,
      label: 'Points per round, oldest first. $description.',
      child: ExcludeSemantics(
        child: SizedBox(
          height: _barArea + 96,
          child: Row(
            // A bar is never wider than a sensible column, so one or two
            // rounds read as bars rather than a slab.
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (final (index, round) in rounds.indexed)
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 64),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
                      duration: Duration(milliseconds: 600 + index * 70),
                      curve: QaddyMotion.standard.enter,
                      builder: (context, t, _) {
                        final latest = index == rounds.length - 1;
                        final height = (round.pointsPer18 / top) * _barArea * t;
                        final colour = latest
                            ? colours.gold
                            : round.won
                            ? colours.accentTeal
                            : colours.textTertiary;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: 18,
                              child: round.won
                                  ? Icon(
                                      Icons.emoji_events,
                                      size: 14,
                                      color: colours.gold,
                                    )
                                  : null,
                            ),
                            Text(
                              '${(round.pointsPer18 * t).round()}',
                              style: typography.small.copyWith(
                                color: latest
                                    ? colours.gold
                                    : colours.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: spacing.xs),
                            Container(
                              height: height < 4 ? 4 : height,
                              margin: EdgeInsets.symmetric(
                                horizontal: spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colour.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(radius.medium),
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              '${round.date.day}\n'
                              '${round.date.monthAbbreviation}',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: typography.caption.copyWith(
                                color: colours.textSecondary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
