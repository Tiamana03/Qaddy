/// Qaddy's empty state.
///
/// See `docs/sprints/sprint-01-3-shared-components.md`'s "Empty States"
/// section: exactly one generic, configurable component. Empty Rounds,
/// Empty Trips, Empty Friends, Empty Statistics and Empty Golf Bag are
/// illustrative future uses of this same component — none of them exist as
/// separate widgets.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_primary_button.dart';

/// A generic, configurable empty-state placeholder.
///
/// See `design/ui-components/README.md`'s "Empty States" guidance: explain
/// why the screen is empty and encourage the next action.
class QaddyEmptyState extends StatelessWidget {
  const QaddyEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Icon representing the empty content.
  final IconData icon;

  /// Short heading (e.g. "No rounds yet").
  final String title;

  /// Supporting message (e.g. "Let's play your first one.").
  final String message;

  /// Optional call-to-action label. Requires [onAction].
  final String? actionLabel;

  /// Called when the optional action is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Padding(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: spacing.display, color: colours.textTertiary),
          SizedBox(height: spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            SizedBox(height: spacing.lg),
            QaddyPrimaryButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
