/// "Your Game": four small stat tiles, as the approved mockup draws them.
/// Handicap, rounds, best score and wins, each a figure over its label; the
/// first tile carries the green tint.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';

/// Four stat tiles. A figure the golfer does not have yet reads as a dash.
class YourGameTiles extends StatelessWidget {
  const YourGameTiles({
    required this.handicap,
    required this.stats,
    required this.onOpen,
    super.key,
  });

  /// The golfer's handicap, or `null`.
  final double? handicap;

  /// What their rounds say, or `null` before the first.
  final CareerStats? stats;

  /// Opens Statistics.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final career = stats;
    final tiles = <(String, String)>[
      (handicap == null ? '–' : handicapLabel(handicap!), 'Handicap'),
      ('${career?.rounds ?? 0}', 'Rounds'),
      (
        career == null ? '–' : '${career.bestRound.pointsPer18.round()}',
        'Best score',
      ),
      ('${career?.wins ?? 0}', 'Wins'),
    ];

    return Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          'Your game. ${tiles.map((t) => '${t.$2} ${t.$1}').join(', ')}. '
          'Opens your statistics.',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (index, tile) in tiles.indexed) ...<Widget>[
              if (index > 0) SizedBox(width: spacing.cardGap),
              Expanded(
                child: _Tile(
                  figure: tile.$1,
                  label: tile.$2,
                  tinted: index == 0,
                  onTap: onOpen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.figure,
    required this.label,
    required this.tinted,
    required this.onTap,
  });

  final String figure;
  final String label;
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
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  figure,
                  style: typography.h3.copyWith(
                    color: tinted
                        ? theme.colorScheme.onPrimary
                        : colours.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                label,
                maxLines: 2,
                style: typography.caption.copyWith(
                  color: tinted
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.85)
                      : colours.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
