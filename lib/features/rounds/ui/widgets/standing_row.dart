/// One row of the leaderboard: position, face, name, how far through they are
/// and their Stableford points, with a bar showing how close they are to the
/// leader.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/ui/widgets/position_badge.dart';

/// A player's place in the table.
class StandingRow extends StatelessWidget {
  const StandingRow({
    required this.standing,
    required this.isYou,
    required this.leaderPoints,
    required this.holesPlayed,
    super.key,
  });

  /// The row's data.
  final PlayerStanding standing;

  /// Whether this is the golfer keeping the score.
  final bool isYou;

  /// The leader's points, which the bar is measured against.
  final int leaderPoints;

  /// How many holes the table covers.
  final int holesPlayed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final name = isYou ? 'You' : standing.player.name;
    final share = leaderPoints <= 0
        ? 0.0
        : (standing.points / leaderPoints).clamp(0.0, 1.0);
    final detail = holesPlayed == 0
        ? 'Not started'
        : '${formatScore(standing.toPar)} · ${standing.gross} strokes';

    return Semantics(
      container: true,
      label:
          'Position ${standing.position}, $name, ${standing.points} points, '
          '$detail.',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colours.card,
            borderRadius: BorderRadius.circular(radius.large),
            border: Border.all(
              color: standing.isLeader && holesPlayed > 0
                  ? colours.gold
                  : isYou
                  ? colours.border
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  PositionBadge(
                    position: standing.position,
                    isLeader: standing.isLeader && holesPlayed > 0,
                  ),
                  SizedBox(width: spacing.md),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: FittedBox(
                      child: QaddyAvatar(name: standing.player.name),
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.copyWith(
                            color: colours.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                        '${standing.points}',
                        style: typography.h2.copyWith(
                          color: colours.textPrimary,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      Text(
                        'pts',
                        style: typography.caption.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(radius.large),
                child: Stack(
                  children: <Widget>[
                    Container(height: 4, color: colours.surface2),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: animate ? 0 : share,
                        end: share,
                      ),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: 4,
                          color: standing.isLeader && holesPlayed > 0
                              ? colours.gold
                              : colours.accent,
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
    );
  }
}
