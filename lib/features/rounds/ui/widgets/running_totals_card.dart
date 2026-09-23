/// Front 9 / Back 9 / 18-hole totals and total-vs-par, recalculated in
/// memory from the current [HoleScore] list.
///
/// See `docs/sprints/sprint-02-03-live-scoring.md`'s "Running Totals"
/// section. Front nine is holes 1-9, back nine is holes 10-18 — the
/// standard golf convention, not a placeholder value requiring sourcing.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/features/rounds/models/hole_score.dart';

/// Displays running Front 9 / Back 9 / Total / Total vs Par, computed from
/// [holes].
class RunningTotalsCard extends StatelessWidget {
  const RunningTotalsCard({required this.holes, super.key});

  /// All 18 holes, in order.
  final List<HoleScore> holes;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final frontNine = holes.take(9);
    final backNine = holes.skip(9).take(9);
    final frontNineTotal = frontNine.fold<int>(
      0,
      (sum, hole) => sum + hole.grossScore,
    );
    final backNineTotal = backNine.fold<int>(
      0,
      (sum, hole) => sum + hole.grossScore,
    );
    final total = frontNineTotal + backNineTotal;
    final totalPar = holes.fold<int>(0, (sum, hole) => sum + hole.par);

    return QaddySectionCard(
      title: 'Running Totals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TotalRow(label: 'Front 9', value: '$frontNineTotal'),
          SizedBox(height: spacing.sm),
          _TotalRow(label: 'Back 9', value: '$backNineTotal'),
          SizedBox(height: spacing.sm),
          _TotalRow(label: '18 Hole Total', value: '$total'),
          SizedBox(height: spacing.sm),
          _TotalRow(
            label: 'Total vs Par',
            value: formatScore(total - totalPar),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: typography.body.copyWith(color: colours.textSecondary),
        ),
        Text(
          value,
          style: typography.body.copyWith(
            color: colours.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
