/// The Round Complete screen's Winner Card.
///
/// See `docs/sprints/sprint-02-05-round-complete.md`'s "Winner Card"
/// section. Displays every player sharing first place — the placeholder
/// leaderboard has a genuine tie for first (Tom and Tiamana), and the
/// sprint's Final Leaderboard section already requires displaying ties
/// correctly, so the Winner Card extends that same rule rather than
/// arbitrarily picking one name and hiding the other.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/features/rounds/models/leaderboard_entry.dart';

/// Announces the round's winner (or co-winners, on a tie).
class WinnerCard extends StatelessWidget {
  const WinnerCard({required this.winners, super.key});

  /// Every player sharing first place — see `rankLeaderboard`'s `isLeader`.
  final List<RankedLeaderboardEntry> winners;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        children: <Widget>[
          Icon(Icons.emoji_events, color: colours.gold, size: spacing.xxl),
          SizedBox(height: spacing.sm),
          Text(
            winners.length > 1 ? 'Winners' : 'Winner',
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.lg),
          for (final (index, winner) in winners.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                QaddyAvatar(name: winner.entry.name),
                SizedBox(width: spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      winner.entry.name,
                      style: typography.h4.copyWith(color: colours.textPrimary),
                    ),
                    SizedBox(height: spacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${winner.entry.grossScore}',
                          style: typography.body.copyWith(
                            color: colours.textSecondary,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        QaddyStatusBadge(
                          label: formatScore(winner.entry.relativeToPar),
                          tone: winner.entry.relativeToPar < 0
                              ? QaddyStatusBadgeTone.success
                              : winner.entry.relativeToPar > 0
                              ? QaddyStatusBadgeTone.error
                              : QaddyStatusBadgeTone.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
