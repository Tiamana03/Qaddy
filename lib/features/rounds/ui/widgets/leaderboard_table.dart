/// The "Live Leaderboard" panel, as the approved Live Scoring mockup draws it:
/// one card with a title, a header row (Pos, Player, Thru, Pts) and a row per
/// golfer. Stableford points decide it, so the last column is points; how they
/// stand against par is the small line under the name.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/rounds/logic/standings.dart';
import 'package:qaddy/features/rounds/models/round.dart';

/// The table for [round].
class LeaderboardTable extends StatelessWidget {
  const LeaderboardTable({
    required this.round,
    required this.standings,
    super.key,
  });

  /// The round being shown.
  final Round round;

  /// Its standings, best first.
  final List<PlayerStanding> standings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final played = round.holesPlayed;

    final header = typography.small.copyWith(
      color: colours.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(radius.large),
        border: Border.all(color: colours.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    round.isCompleted
                        ? 'Final leaderboard'
                        : 'Live leaderboard',
                    style: typography.h4.copyWith(
                      color: colours.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colours.surface1,
                    borderRadius: BorderRadius.circular(radius.large),
                    border: Border.all(color: colours.border),
                  ),
                  child: Text(
                    round.format,
                    style: typography.small.copyWith(
                      color: colours.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: colours.surface1,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            child: Row(
              children: <Widget>[
                SizedBox(width: 36, child: Text('Pos', style: header)),
                Expanded(child: Text('Player', style: header)),
                SizedBox(
                  width: 44,
                  child: Text(
                    'Thru',
                    textAlign: TextAlign.center,
                    style: header,
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text('Pts', textAlign: TextAlign.end, style: header),
                ),
              ],
            ),
          ),
          for (final (index, standing) in standings.indexed) ...<Widget>[
            if (index > 0) Divider(height: 1, color: colours.border),
            _Row(
              standing: standing,
              isYou: standing.player.name == currentUserName,
              holesPlayed: played,
              through: _through(standing.player.name),
            ),
          ],
        ],
      ),
    );
  }

  /// How many holes this golfer has a score on.
  int _through(String name) =>
      round.scores[name]?.where((s) => s != null).length ?? 0;
}

class _Row extends StatelessWidget {
  const _Row({
    required this.standing,
    required this.isYou,
    required this.holesPlayed,
    required this.through,
  });

  final PlayerStanding standing;
  final bool isYou;
  final int holesPlayed;
  final int through;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final leads = standing.isLeader && holesPlayed > 0;
    final name = isYou ? 'You' : standing.player.name;
    final detail = holesPlayed == 0
        ? 'Not started'
        : '${formatScore(standing.toPar)} · ${standing.gross} strokes';

    return Semantics(
      container: true,
      label:
          'Position ${standing.position}, $name, ${standing.points} points, '
          'through $through, $detail.',
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm + 2,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 36,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: leads
                          ? Border.all(color: colours.gold, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      standing.position,
                      style: typography.small.copyWith(
                        color: leads ? colours.gold : colours.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: FittedBox(
                        child: QaddyAvatar(name: standing.player.name),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: typography.body.copyWith(
                                    color: colours.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (leads) ...<Widget>[
                                SizedBox(width: spacing.xs),
                                Icon(
                                  Icons.workspace_premium,
                                  size: 16,
                                  color: colours.gold,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.caption.copyWith(
                              color: colours.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '$through',
                  textAlign: TextAlign.center,
                  style: typography.body.copyWith(color: colours.textSecondary),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${standing.points}',
                  textAlign: TextAlign.end,
                  style: typography.h4.copyWith(
                    color: colours.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
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
