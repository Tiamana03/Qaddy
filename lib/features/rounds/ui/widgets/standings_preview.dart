/// The top of the table, in a card that opens the full leaderboard.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/round.dart';
import 'package:qaddy/features/rounds/ui/widgets/position_badge.dart';

/// "Leaderboard · after 7 holes": the top three and where the golfer stands.
class StandingsPreview extends StatelessWidget {
  const StandingsPreview({
    required this.round,
    required this.onOpen,
    super.key,
  });

  /// The round to summarise.
  final Round round;

  /// Opens the full leaderboard.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final standings = standingsOf(round);
    final played = round.holesPlayed;
    final chase = chaseLine(standings, currentUserName);
    final top = <String>[
      for (final s in standings.take(3))
        '${s.position} ${s.player.name} ${s.points} points',
    ].join(', ');
    final unit = played == 1 ? 'hole' : 'holes';

    return Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          'Leaderboard after $played $unit. $top. '
          '${chase ?? ''} Opens the full leaderboard.',
      child: QaddyCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: QaddyEyebrow(
                    'Leaderboard · after $played $unit',
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colours.textSecondary,
                  size: 18,
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            for (final standing in standings.take(3)) ...<Widget>[
              Row(
                children: <Widget>[
                  PositionBadge(
                    position: standing.position,
                    isLeader: standing.isLeader,
                  ),
                  SizedBox(width: spacing.md),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: FittedBox(
                      child: QaddyAvatar(name: standing.player.name),
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      standing.player.name == currentUserName
                          ? 'You'
                          : standing.player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.copyWith(
                        color: colours.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${standing.points} pts',
                    style: typography.body.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
            ],
            if (chase != null)
              Text(
                chase,
                style: typography.small.copyWith(color: colours.accent),
              ),
          ],
        ),
      ),
    );
  }
}
