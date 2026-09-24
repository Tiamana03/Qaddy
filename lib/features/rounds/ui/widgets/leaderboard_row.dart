/// A single player's row on the Live Leaderboard.
///
/// See `docs/sprints/sprint-02-04-leaderboard.md`'s "Player Cards" section.
/// Reuses `QaddyAvatar` (Sprint 2.2) for the placeholder avatar and
/// `QaddyStatusBadge` for the relative-to-par chip — golf's own
/// under/over-par convention maps directly onto the existing
/// success (green) / info (blue) / error (red) semantic tones, so no new
/// component is introduced for this.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';
import 'package:qaddy/features/rounds/ui/widgets/position_badge.dart';

/// Position, avatar, name, gross score, relative-to-par and through-hole
/// progress for one player.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({required this.ranked, super.key});

  /// The ranked player standing to display.
  final RankedLeaderboardEntry ranked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final entry = ranked.entry;
    final tone = entry.relativeToPar < 0
        ? QaddyStatusBadgeTone.success
        : entry.relativeToPar > 0
        ? QaddyStatusBadgeTone.error
        : QaddyStatusBadgeTone.info;

    final content = Row(
      children: <Widget>[
        PositionBadge(position: ranked.position, isLeader: ranked.isLeader),
        SizedBox(width: spacing.md),
        QaddyAvatar(name: entry.name),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                entry.name,
                style: typography.body.copyWith(
                  color: colours.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Thru ${entry.throughHole}',
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${entry.grossScore}',
              style: typography.body.copyWith(
                color: colours.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: spacing.xs),
            QaddyStatusBadge(
              label: formatScore(entry.relativeToPar),
              tone: tone,
            ),
          ],
        ),
      ],
    );

    if (!ranked.isLeader) {
      return QaddyCard(child: content);
    }

    // The leader's card gets a gold border in addition to the leader's
    // gold PositionBadge, per "Highlight the current leader".
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.large),
        border: Border.all(
          color: colours.gold,
          width: radius.borderWidthFocused,
        ),
      ),
      child: QaddyCard(child: content),
    );
  }
}
