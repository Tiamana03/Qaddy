/// "Your Game": four small stat tiles, as the approved Home mockup draws them.
/// Handicap, rounds, best score and wins; the shared `QaddyStatTiles` draws
/// them.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/cards/qaddy_stat_tiles.dart';
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
    final career = stats;

    return QaddyStatTiles(
      onOpen: onOpen,
      stats: <QaddyStat>[
        QaddyStat(
          figure: handicap == null ? '–' : handicapLabel(handicap!),
          label: 'Handicap',
        ),
        QaddyStat(figure: '${career?.rounds ?? 0}', label: 'Rounds'),
        QaddyStat(
          figure: career == null
              ? '–'
              : '${career.bestRound.pointsPer18.round()}',
          label: 'Best score',
        ),
        QaddyStat(figure: '${career?.wins ?? 0}', label: 'Wins'),
      ],
    );
  }
}
