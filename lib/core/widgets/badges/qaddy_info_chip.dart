/// A small frosted chip with an icon and a short fact ("21°C Sunny",
/// "Stableford", "18 holes"), for the details under a hero's headline.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A pill that sits on a gradient: white text on a faint white wash, with a
/// gold icon. Frosted like the mockups' weather card: the wash is blurred and
/// has a hairline highlight.
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
    final shape = BorderRadius.circular(radius.large);

    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm + spacing.xs / 2,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: onGradient.withValues(alpha: 0.14),
            borderRadius: shape,
            border: Border.all(color: onGradient.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 14, color: colours.gold),
              SizedBox(width: spacing.xs),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.caption.copyWith(
                    color: onGradient,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
