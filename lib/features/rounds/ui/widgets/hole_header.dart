/// The current hole's number, par, stroke index and distance.
///
/// See `docs/sprints/sprint-02-03-live-scoring.md`'s "Score Entry" section.
/// The hole number uses `typography.statHoleNumber`, documented in
/// `typography.md` as existing specifically for "the current hole number in
/// scoring/live-scoring UI." Par/Index/Distance reuse `QaddyStatisticCard`
/// rather than a new label/value widget.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/features/rounds/models/hole_score.dart';

/// Displays the current hole's number and its three static attributes.
class HoleHeader extends StatelessWidget {
  const HoleHeader({required this.hole, super.key});

  /// The hole to display.
  final HoleScore hole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Column(
      children: <Widget>[
        Text(
          'Hole ${hole.holeNumber}',
          style: typography.statHoleNumber.copyWith(color: colours.textPrimary),
        ),
        SizedBox(height: spacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: QaddyStatisticCard(label: 'Par', value: '${hole.par}'),
            ),
            SizedBox(width: spacing.cardGap),
            Expanded(
              child: QaddyStatisticCard(
                label: 'Stroke Index',
                value: '${hole.strokeIndex}',
              ),
            ),
            SizedBox(width: spacing.cardGap),
            Expanded(
              child: QaddyStatisticCard(
                label: 'Distance',
                value: '${hole.distance}m',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
