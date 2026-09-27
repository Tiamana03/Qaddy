/// A single player's row on a Group's Season Leaderboard — see
/// `docs/architecture/group-details.md`'s "Leaderboard" section (rank,
/// player, points). Reuses `PositionBadge` from the Rounds feature as a
/// reference pattern (see `docs/architecture/friends-engineering-decisions.md`'s
/// "Potential New Widgets"), but not `LeaderboardRow` itself — that widget
/// is tied to Rounds' gross-score/relative-to-par/through-hole fields,
/// which a Season Leaderboard's simpler rank/player/points shape doesn't
/// have.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/rounds/ui/widgets/position_badge.dart';

/// One Season Leaderboard entry.
class GroupLeaderboardRow extends StatelessWidget {
  const GroupLeaderboardRow({
    required this.rank,
    required this.player,
    required this.points,
    super.key,
  });

  /// The player's rank (1 is first place).
  final int rank;

  /// The player's name.
  final String player;

  /// The player's season points.
  final int points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Row(
        children: <Widget>[
          PositionBadge(position: '$rank', isLeader: rank == 1),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              player,
              style: typography.body.copyWith(
                color: colours.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$points pts',
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
        ],
      ),
    );
  }
}
