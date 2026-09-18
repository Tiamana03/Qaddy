/// Qaddy's linear loading indicator.
///
/// See `design/ui-components/loaders/loaders-library-v1.png`, panel 8
/// ("Progress Bar" — linear progress indicator).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';

/// Qaddy's linear loading indicator.
///
/// Pass [value] for a determinate progress bar (0.0–1.0), or omit it for an
/// indeterminate one.
class QaddyLinearLoader extends StatelessWidget {
  const QaddyLinearLoader({this.value, super.key});

  /// Progress from 0.0 to 1.0, or `null` for an indeterminate loader.
  final double? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.small),
      child: LinearProgressIndicator(
        value: value,
        color: colours.primary,
        backgroundColor: colours.surface2,
      ),
    );
  }
}
