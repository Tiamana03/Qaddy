/// A label/value row shared by every Trips detail screen (Trip Details,
/// Planning, Travel, Accommodation, Golf Schedule, Expenses, Trip
/// Complete) — avoids duplicating the same row layout across each one.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A label on the left, a value on the right. The value wraps onto
/// multiple lines rather than overflowing — several Trips values (e.g. a
/// full address or a list of player names) are longer than a single line.
class TripInfoRow extends StatelessWidget {
  const TripInfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: typography.body.copyWith(color: colours.textSecondary),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: typography.body.copyWith(
              color: colours.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
