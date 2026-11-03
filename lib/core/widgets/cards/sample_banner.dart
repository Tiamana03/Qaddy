/// The plain explanation that what is on screen is the Sample Clubhouse, with
/// the way to keep, edit or remove it.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A banner that says the screen shows sample content. [message] says what is
/// sample here; [onManage] opens where it can be kept, edited or removed.
class SampleBanner extends StatelessWidget {
  const SampleBanner({
    required this.message,
    required this.onManage,
    super.key,
  });

  /// What on this screen is sample.
  final String message;

  /// Opens the Sample Clubhouse settings.
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      button: true,
      onTap: onManage,
      excludeSemantics: true,
      label: 'Sample Clubhouse. $message Opens its settings.',
      child: Material(
        color: colours.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius.large),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius.large),
          onTap: onManage,
          child: Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.large),
              border: Border.all(color: colours.accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.theaters_outlined, size: 20, color: colours.accent),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sample Clubhouse',
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        message,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        'Keep it, edit it or remove it in Settings',
                        style: typography.small.copyWith(
                          color: colours.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
