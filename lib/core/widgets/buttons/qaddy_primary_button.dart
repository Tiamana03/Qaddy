/// Qaddy's primary call-to-action button.
///
/// See `design/ui-components/buttons/buttons-library-v1.png` ("Primary
/// Button") and `docs/ui-component-library.md`. Filled with `colours.primary`
/// and white text (Flutter's `ColorScheme.onPrimary`, already derived from
/// `QaddyColours` in `qaddy_theme.dart` — there is no dedicated "on-primary"
/// field on `QaddyColours` itself, so this reuses the theme's own derived
/// pairing rather than hardcoding white).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Qaddy's primary button — the main call-to-action for a screen.
class QaddyPrimaryButton extends StatelessWidget {
  const QaddyPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  /// Button label.
  final String label;

  /// Called when tapped. Pass `null` to render the disabled state.
  final VoidCallback? onPressed;

  /// Optional trailing icon (e.g. an arrow), per the source mock-ups.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final enabled = onPressed != null;
    final background = enabled ? colours.primary : colours.disabledBackground;
    final foreground = enabled
        ? theme.colorScheme.onPrimary
        : colours.disabledForeground;
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
            color: background,
            borderRadius: borderRadius,
            boxShadow: enabled ? shadows.small : shadows.none,
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
