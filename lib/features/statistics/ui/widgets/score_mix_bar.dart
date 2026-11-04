/// How every hole you have played broke down, as one coloured bar and a
/// legend: eagles and birdies at one end, doubles at the other.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

/// A segmented bar with a legend.
class ScoreMixBar extends StatelessWidget {
  const ScoreMixBar({required this.mix, super.key});

  /// The holes to show.
  final ScoreMix mix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final parts = <({String label, int count, Color colour})>[
      (
        label: 'Eagle or better',
        count: mix.eagleOrBetter,
        colour: colours.gold,
      ),
      (label: 'Birdie', count: mix.birdies, colour: colours.accentTeal),
      (label: 'Par', count: mix.pars, colour: colours.accentSky),
      (label: 'Bogey', count: mix.bogeys, colour: colours.accentOrange),
      (
        label: 'Double or worse',
        count: mix.doubleOrWorse,
        colour: colours.accentPink,
      ),
      (label: 'Picked up', count: mix.pickedUp, colour: colours.textTertiary),
    ];
    final shown = <({String label, int count, Color colour})>[
      for (final part in parts)
        if (part.count > 0) part,
    ];
    final description = shown.map((p) => '${p.label} ${p.count}').join(', ');

    return Semantics(
      container: true,
      label: 'Your holes: $description.',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.large),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
                duration: QaddyMotion.standard.loading,
                curve: QaddyMotion.standard.enter,
                builder: (context, t, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: t.clamp(0.001, 1),
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (final part in shown)
                            Expanded(
                              flex: part.count,
                              child: ColoredBox(color: part.colour),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.lg),
            Wrap(
              spacing: spacing.lg,
              runSpacing: spacing.sm,
              children: <Widget>[
                for (final part in shown)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: part.colour,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      Flexible(
                        child: Text(
                          '${part.label} ${part.count}',
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
          ],
        ),
      ),
    );
  }
}
