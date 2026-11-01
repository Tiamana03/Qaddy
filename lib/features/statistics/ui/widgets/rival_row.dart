/// One playing partner and the head-to-head: how many rounds you have played
/// together and who has come out on top.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

/// A head-to-head row with a split bar: gold for your wins, blue for theirs.
class RivalRow extends StatelessWidget {
  const RivalRow({required this.rival, super.key});

  /// The record to show.
  final Rival rival;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final rounds = rival.together == 1
        ? '1 round together'
        : '${rival.together} rounds together';
    final verdict = rival.youWon == rival.theyWon
        ? 'All square'
        : rival.youWon > rival.theyWon
        ? 'You lead'
        : '${rival.name} leads';

    return Semantics(
      container: true,
      label:
          '${rival.name}: $rounds. You won ${rival.youWon}, '
          '${rival.name} won ${rival.theyWon}, ${rival.halved} level. '
          '$verdict.',
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: FittedBox(child: QaddyAvatar(name: rival.name)),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        rival.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        rounds,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${rival.youWon} – ${rival.theyWon}',
                      style: typography.h3.copyWith(
                        color: colours.textPrimary,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    Text(
                      verdict,
                      style: typography.caption.copyWith(
                        color: rival.youWon > rival.theyWon
                            ? colours.gold
                            : colours.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.large),
              child: SizedBox(
                height: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (rival.youWon > 0)
                      Expanded(
                        flex: rival.youWon,
                        child: ColoredBox(color: colours.gold),
                      ),
                    if (rival.halved > 0)
                      Expanded(
                        flex: rival.halved,
                        child: ColoredBox(color: colours.textTertiary),
                      ),
                    if (rival.theyWon > 0)
                      Expanded(
                        flex: rival.theyWon,
                        child: ColoredBox(color: colours.accentSky),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
