/// One golfer's line in a group's season table: rank, face, name, points and a
/// bar showing how close they are to the leader.
///
/// Sits inside a single card with the rest of the field (see the group page);
/// it draws no card of its own. Reuses `PositionBadge` from the Rounds feature
/// for the rank.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/rounds/ui/widgets/position_badge.dart';

/// One season table entry.
class GroupLeaderboardRow extends StatelessWidget {
  const GroupLeaderboardRow({
    required this.rank,
    required this.player,
    required this.points,
    required this.leaderPoints,
    this.isYou = false,
    super.key,
  });

  /// The player's rank (1 is first place).
  final int rank;

  /// The player's name.
  final String player;

  /// The player's season points.
  final int points;

  /// The leader's points: the bar is this player's share of them.
  final int leaderPoints;

  /// Whether this is the golfer keeping the app: shown as "You" on a gold
  /// tint.
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final share = leaderPoints <= 0
        ? 0.0
        : (points / leaderPoints).clamp(0.0, 1.0);
    final label = isYou ? 'You' : player;

    return Semantics(
      container: true,
      label: '${ordinal(rank)}, $label, $points points.',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isYou ? colours.gold.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(radius.medium),
            border: isYou
                ? Border.all(color: colours.gold.withValues(alpha: 0.7))
                : null,
          ),
          child: Row(
            children: <Widget>[
              PositionBadge(position: '$rank', isLeader: rank == 1),
              SizedBox(width: spacing.md),
              SizedBox(
                width: 32,
                height: 32,
                child: FittedBox(child: QaddyAvatar(name: player)),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.copyWith(
                        color: isYou ? colours.gold : colours.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(radius.large),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: animate ? 0 : share,
                          end: share,
                        ),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 4,
                          backgroundColor: colours.surface2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isYou
                                ? colours.gold
                                : colours.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.md),
              Text(
                '$points pts',
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
