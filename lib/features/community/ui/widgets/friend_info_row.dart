/// A label/value row shared by the Friends feature's detail screens
/// (Friend Profile, Rivalries) — mirrors `TripInfoRow`'s pattern for the
/// Trips feature; kept feature-scoped rather than shared, matching that
/// precedent.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A label on the left, a value on the right.
class FriendInfoRow extends StatelessWidget {
  const FriendInfoRow({required this.label, required this.value, super.key});

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
