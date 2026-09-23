/// A single player's row in the Round Setup screen's Players Section.
///
/// See `docs/architecture/round-data-model.md`'s "Player Status" section
/// (Confirmed / Pending / Declined — attendance, not online presence) and
/// `docs/sprints/sprint-02-02-round-setup.md`'s "Players Section".
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';

/// A placeholder player's participation status for a round — see
/// round-data-model.md's "Player Status" section.
enum PlayerStatus { confirmed, pending, declined }

/// Name, handicap, placeholder avatar and status for one round participant.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    required this.name,
    required this.handicap,
    required this.status,
    super.key,
  });

  /// The player's name.
  final String name;

  /// The player's handicap, as sourced (e.g. "8").
  final String handicap;

  /// The player's participation status for this round.
  final PlayerStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final (label, tone) = switch (status) {
      PlayerStatus.confirmed => ('Confirmed', QaddyStatusBadgeTone.success),
      PlayerStatus.pending => ('Pending', QaddyStatusBadgeTone.warning),
      PlayerStatus.declined => ('Declined', QaddyStatusBadgeTone.error),
    };

    return QaddyCard(
      child: Row(
        children: <Widget>[
          QaddyAvatar(name: name),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  name,
                  style: typography.body.copyWith(
                    color: colours.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  'HCP $handicap',
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          QaddyStatusBadge(label: label, tone: tone),
        ],
      ),
    );
  }
}
