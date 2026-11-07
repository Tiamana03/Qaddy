/// Qaddy's secondary button — supporting actions.
///
/// See `design/ui-components/buttons/buttons-library-v1.png` ("Secondary
/// Button") and `docs/ui-component-library.md`: transparent background,
/// green border, green text.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Qaddy's secondary button — for supporting actions (e.g. Cancel, Back).
class QaddySecondaryButton extends StatelessWidget {
  const QaddySecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconBefore = false,
    this.compact = false,
    this.height,
    super.key,
  });

  /// Button label.
  final String label;

  /// Called when tapped. Pass `null` to render the disabled state.
  final VoidCallback? onPressed;

  /// Optional icon, after the label unless [iconBefore].
  final IconData? icon;

  /// Puts the [icon] before the label (a pencil before "Hole notes").
  final bool iconBefore;

  /// The Small (40) size, to sit beside a compact gold button.
  final bool compact;

  /// Overrides the height (the mockup's Next Hole pill is 40).
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final enabled = onPressed != null;
    // The mockups' quiet button ("View Details", "Hole Notes", "Edit Round"):
    // a dark fill, a hairline and white text, in a pill when compact.
    final foreground = colours.textPrimary;
    final borderColour = colours.border;
    final borderRadius = BorderRadius.circular(compact ? 999 : radius.medium);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Container(
            height: height ?? (compact ? 36 : spacing.display),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? spacing.md : spacing.buttonPadding,
            ),
            decoration: BoxDecoration(
              color: colours.surface1,
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColour,
                width: radius.borderWidthDefault,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null && iconBefore) ...<Widget>[
                  Icon(icon, color: foreground, size: compact ? 18 : 22),
                  SizedBox(width: spacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (compact ? QaddyText.pillLabel : typography.button)
                        .copyWith(color: foreground),
                  ),
                ),
                if (icon != null && !iconBefore) ...<Widget>[
                  SizedBox(width: spacing.sm),
                  Icon(icon, color: foreground, size: compact ? 18 : 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
