/// The Trips screen's summary — Upcoming, Past and Countries Visited.
///
/// One compact card with three figures in a single row at every width,
/// replacing three full-size statistic tiles that used to fill almost half
/// of a phone's first screen with numbers the golfer can't act on. The
/// figures and labels are unchanged.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';

/// Upcoming/Past/Countries summary.
class TripsSummaryCard extends StatelessWidget {
  const TripsSummaryCard({
    required this.upcomingCount,
    required this.pastCount,
    required this.countriesCount,
    super.key,
  });

  /// How many upcoming trips exist.
  final int upcomingCount;

  /// How many past trips exist.
  final int pastCount;

  /// How many distinct countries have been visited.
  final int countriesCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;

    return Semantics(
      container: true,
      label:
          '$upcomingCount upcoming trips, $pastCount past trips, '
          '$countriesCount countries visited',
      child: ExcludeSemantics(
        child: QaddyCard(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _SummaryStat(value: upcomingCount, label: 'Upcoming'),
                ),
                Container(width: 1, color: colours.divider),
                Expanded(
                  child: _SummaryStat(value: pastCount, label: 'Past'),
                ),
                Container(width: 1, color: colours.divider),
                Expanded(
                  child: _SummaryStat(
                    value: countriesCount,
                    label: 'Countries',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$value',
          style: typography.h2.copyWith(color: colours.textPrimary),
        ),
        Text(
          label,
          style: typography.caption.copyWith(color: colours.textSecondary),
        ),
      ],
    );
  }
}
