/// A leaderboard row's position (e.g. "1", "T1", "3").
///
/// See `docs/sprints/sprint-02-04-leaderboard.md`'s "Player Cards" section
/// ("Highlight the current leader"). The leader uses `colours.gold` —
/// documented as "Premium accents... highlights" — everyone else uses the
/// neutral surface colour.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A circular badge showing a player's leaderboard position.
class PositionBadge extends StatelessWidget {
  const PositionBadge({
    required this.position,
    required this.isLeader,
    super.key,
  });

  /// The position text (e.g. "1", "T1", "3").
  final String position;

  /// Whether this player holds (or shares) first place.
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final background = isLeader ? colours.gold : colours.surface1;
    final foreground = isLeader
        ? theme.colorScheme.onPrimary
        : colours.textPrimary;

    return Container(
      width: spacing.display,
      height: spacing.display,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        position,
        style: typography.small.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
