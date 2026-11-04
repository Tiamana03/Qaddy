/// Qaddy's eyebrow: the short label above a headline ("Next round",
/// "Your game", "Season race"). Every hero and card that opens with one uses
/// this, so they read as the same family.
///
/// It is written in natural sentence case at the `small` size: calm and
/// confident rather than shouting in spaced capitals.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A short label in the premium gold (or [colour]).
class QaddyEyebrow extends StatelessWidget {
  const QaddyEyebrow(this.text, {this.colour, this.maxLines, super.key});

  /// The label, in sentence case ("Next round").
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
      style: typography.small.copyWith(
        color: colour ?? colours.accent,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
