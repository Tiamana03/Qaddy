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
    this.compact = false,
    super.key,
  });

  /// Button label.
  final String label;

  /// Called when tapped. Pass `null` to render the disabled state.
  final VoidCallback? onPressed;

  /// Optional trailing icon.
  final IconData? icon;

  /// The Small (40) size, to sit beside a compact gold button.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final enabled = onPressed != null;
    // The compact button is the mockups' quiet pill ("View Details"): a dark
    // fill, a hairline and white text, not the green-outlined button.
    final foreground = !enabled
        ? colours.disabledForeground
        : compact
        ? colours.textPrimary
        : colours.accent;
    final borderColour = !enabled
        ? colours.disabledBorder
        : compact
        ? colours.border
        : colours.accent;
    final borderRadius = BorderRadius.circular(compact ? 999 : radius.medium);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          height: compact ? 36 : spacing.display,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? spacing.md : spacing.buttonPadding,
          ),
          decoration: BoxDecoration(
            color: compact && enabled ? colours.surface1 : null,
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? QaddyText.pillLabel : typography.button)
                      .copyWith(color: foreground),
                ),
              ),
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
