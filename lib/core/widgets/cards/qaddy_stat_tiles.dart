/// A row of small stat tiles, as the approved Home ("Your Game") and Profile
/// mockups draw them: a figure over its label, an optional icon above, the
/// first tile tinted green. Used wherever a golfer's headline numbers sit in a
/// row.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// One tile's content.
class QaddyStat {
  const QaddyStat({required this.figure, required this.label, this.icon});

  /// The number (or "–" while it is not known).
  final String figure;

  /// What it is.
  final String label;

  /// An icon above the figure.
  final IconData? icon;
}

/// Tiles for [stats], sharing the width equally.
class QaddyStatTiles extends StatelessWidget {
  const QaddyStatTiles({
    required this.stats,
    required this.onOpen,
    this.semanticPrefix = 'Your game',
    super.key,
  });

  /// What to show.
  final List<QaddyStat> stats;

  /// Opens the place the numbers come from.
  final VoidCallback onOpen;

  /// What the whole row is called to a screen reader.
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          '$semanticPrefix. '
          '${stats.map((t) => '${t.label} ${t.figure}').join(', ')}. '
          'Opens your statistics.',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (index, stat) in stats.indexed) ...<Widget>[
              if (index > 0) SizedBox(width: spacing.cardGap),
              Expanded(
                child: _Tile(stat: stat, tinted: index == 0, onTap: onOpen),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.stat, required this.tinted, required this.onTap});

  final QaddyStat stat;
  final bool tinted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final shape = BorderRadius.circular(radius.large);
    final figureColour = tinted
        ? theme.colorScheme.onPrimary
        : colours.textPrimary;
    final labelColour = tinted
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.85)
        : colours.textSecondary;

    return Material(
      color: tinted ? colours.secondary.withValues(alpha: 0.55) : colours.card,
      shape: RoundedRectangleBorder(
        borderRadius: shape,
        side: BorderSide(
          color: tinted
              ? colours.selected.withValues(alpha: 0.45)
              : colours.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (stat.icon != null) ...<Widget>[
                Icon(stat.icon, size: 20, color: colours.gold),
                SizedBox(height: spacing.sm),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stat.figure,
                  style: typography.h3.copyWith(
                    color: figureColour,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                stat.label,
                maxLines: 2,
                style: typography.caption.copyWith(color: labelColour),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
