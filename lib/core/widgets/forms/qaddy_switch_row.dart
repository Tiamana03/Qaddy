/// A labelled on/off setting.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';

/// A title (and optional explanation) with a switch on the right. The whole
/// row is tappable, and reads as a single switch to screen readers.
class QaddySwitchRow extends StatelessWidget {
  const QaddySwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  /// What the setting is.
  final String title;

  /// Optional one-line explanation.
  final String? subtitle;

  /// Whether the setting is on.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      toggled: value,
      label: title,
      hint: subtitle,
      excludeSemantics: true,
      onTap: () {
        QaddyHaptics.selection();
        onChanged(!value);
      },
      child: InkWell(
        onTap: () {
          QaddyHaptics.selection();
          onChanged(!value);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: typography.body.copyWith(
                        color: colours.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: spacing.md),
              ExcludeSemantics(
                child: Switch(value: value, onChanged: onChanged),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
