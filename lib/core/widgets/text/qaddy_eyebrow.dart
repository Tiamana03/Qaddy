/// Qaddy's eyebrow: the small, spaced-out capitals above a headline
/// ("NEXT ROUND", "YOUR GAME", "RIVALRY"). Every hero and card that opens with
/// one uses this, so they read as the same family.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A short, spaced capital label in the premium gold (or [colour]).
class QaddyEyebrow extends StatelessWidget {
  const QaddyEyebrow(this.text, {this.colour, this.maxLines, super.key});

  /// The label. Write it in capitals.
  final String text;

  /// The text colour. Defaults to the theme's gold.
  final Color? colour;

  /// Limits the label to this many lines, ellipsised.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: typography.caption.copyWith(
        color: colour ?? colours.gold,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}
