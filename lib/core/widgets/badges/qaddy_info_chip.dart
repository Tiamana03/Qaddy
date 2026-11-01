/// A small translucent chip with an icon and a short fact ("21°C Sunny",
/// "Stableford", "18 holes"), for the details under a hero's headline.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A pill that sits on a gradient: white text on a faint white wash, with a
/// gold icon.
class QaddyInfoChip extends StatelessWidget {
  const QaddyInfoChip({required this.icon, required this.text, super.key});

  /// The leading icon.
  final IconData icon;

  /// The fact.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: onGradient.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radius.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colours.gold),
          SizedBox(width: spacing.xs),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.small.copyWith(color: onGradient),
            ),
          ),
        ],
      ),
    );
  }
}
