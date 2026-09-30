/// Qaddy's shared label/value row.
///
/// Every feature so far (Trips' `TripInfoRow`, Friends' `FriendInfoRow`,
/// Groups' and Profile's own private `_InfoRow`) has re-implemented this
/// exact row independently. Statistics is the first feature to adopt a
/// single shared version instead of adding a fifth copy — see
/// `docs/architecture/statistics-engineering-decisions.md`'s "Source of
/// Truth" section. The existing per-feature copies are left as-is; this
/// does not retroactively refactor them.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A label on the left, a value on the right.
class QaddyInfoRow extends StatelessWidget {
  const QaddyInfoRow({required this.label, required this.value, super.key});

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
