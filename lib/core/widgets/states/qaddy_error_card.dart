/// Qaddy's error card — a visual-only error display.
///
/// See `docs/sprints/sprint-01-3-shared-components.md`'s "Error States"
/// section: visual component only, no networking logic.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A card explaining what went wrong, styled with `colours.error`.
class QaddyErrorCard extends StatelessWidget {
  const QaddyErrorCard({required this.message, this.child, super.key});

  /// What happened, in plain language — never technical jargon, per
  /// `docs/ui-component-library.md`'s Error States guidance.
  final String message;

  /// Optional content shown below the message (e.g. a `QaddyRetryWidget`).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(radius.large),
        border: Border.all(
          color: colours.error,
          width: radius.borderWidthDefault,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.error_outline, color: colours.error),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
              ),
            ],
          ),
          if (child != null) ...<Widget>[SizedBox(height: spacing.md), child!],
        ],
      ),
    );
  }
}
