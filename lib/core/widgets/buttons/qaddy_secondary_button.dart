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
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Qaddy's secondary button — for supporting actions (e.g. Cancel, Back).
class QaddySecondaryButton extends StatelessWidget {
  const QaddySecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  /// Button label.
  final String label;

  /// Called when tapped. Pass `null` to render the disabled state.
  final VoidCallback? onPressed;

  /// Optional trailing icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final enabled = onPressed != null;
    final foreground = enabled ? colours.primary : colours.disabledForeground;
    final borderColour = enabled ? colours.primary : colours.disabledBorder;
    final borderRadius = BorderRadius.circular(radius.medium);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          height: spacing.display,
          padding: EdgeInsets.symmetric(horizontal: spacing.buttonPadding),
          decoration: BoxDecoration(
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
              Text(label, style: typography.button.copyWith(color: foreground)),
              if (icon != null) ...<Widget>[
                SizedBox(width: spacing.sm),
                Icon(icon, color: foreground, size: spacing.md * 2),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
