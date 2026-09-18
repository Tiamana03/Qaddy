/// Qaddy's statistic card — highlights a single key statistic.
///
/// Built on [QaddyCard]; see `design/ui-components/cards/cards-library-v1.png`
/// ("Statistic Card": label, large value, optional trend) and
/// `design/design-tokens/typography.md`'s Statistics Typography (`statLarge`).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';

/// A [QaddyCard] that highlights one statistic (label, value, optional
/// trend).
class QaddyStatisticCard extends StatelessWidget {
  const QaddyStatisticCard({
    required this.label,
    required this.value,
    this.trend,
    this.isPositiveTrend = true,
    super.key,
  });

  /// The statistic's label (e.g. "Handicap").
  final String label;

  /// The statistic's value (e.g. "12.4"), styled with `statLarge`.
  final String value;

  /// Optional trend text (e.g. "↓1.2 (Last 3 months)").
  final String? trend;

  /// Whether [trend] represents an improvement (`success`) or a decline
  /// (`error`). Ignored if [trend] is null.
  final bool isPositiveTrend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: typography.caption.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            value,
            style: typography.statLarge.copyWith(color: colours.textPrimary),
          ),
          if (trend != null) ...<Widget>[
            SizedBox(height: spacing.xs),
            Text(
              trend!,
              style: typography.small.copyWith(
                color: isPositiveTrend ? colours.success : colours.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
