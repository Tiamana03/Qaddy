/// Qaddy's retry widget — a visual-only retry action.
///
/// See `docs/sprints/sprint-01-3-shared-components.md`'s "Error States"
/// section: visual component only, no networking logic. Built on
/// `QaddyTertiaryButton` so it inherits the same token-driven styling.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_tertiary_button.dart';

/// A "Retry" action for use inside error states (e.g. a `QaddyErrorCard`).
class QaddyRetryWidget extends StatelessWidget {
  const QaddyRetryWidget({required this.onRetry, super.key});

  /// Called when the user taps retry.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return QaddyTertiaryButton(
      label: 'Retry',
      icon: Icons.refresh,
      onPressed: onRetry,
    );
  }
}
