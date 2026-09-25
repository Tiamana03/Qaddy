/// The Trips screen's summary — Upcoming, Past and Countries Visited.
///
/// See `docs/sprints/sprint-03-01-trips-foundation.md`'s "Trips Summary"
/// section. Reuses `QaddyStatisticCard`. Mobile stacks vertically; tablet
/// and desktop show all three horizontally, per that sprint's Responsive
/// Behaviour section.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/responsive/responsive_extensions.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';

/// Upcoming/Past/Countries summary cards.
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
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final cards = <Widget>[
      QaddyStatisticCard(label: 'Upcoming', value: '$upcomingCount'),
      QaddyStatisticCard(label: 'Past', value: '$pastCount'),
      QaddyStatisticCard(label: 'Countries', value: '$countriesCount'),
    ];

    if (context.isMobile) {
      return Column(
        children: <Widget>[
          for (final (index, card) in cards.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.cardGap),
            card,
          ],
        ],
      );
    }

    return Row(
      children: <Widget>[
        for (final (index, card) in cards.indexed) ...<Widget>[
          if (index > 0) SizedBox(width: spacing.cardGap),
          Expanded(child: card),
        ],
      ],
    );
  }
}
