/// Qaddy's icon button — square/circle control for a single quick action.
///
/// See `design/ui-components/buttons/buttons-library-v1.png`, panel 5
/// ("Icon Button" — Back, Share, Edit). Size is `spacing.iconButtonSize`
/// (48px, an Engineering Decision — see `spacing.md`); shape is fully
/// rounded via `radius.pill`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';

/// Qaddy's icon button — for a single, common quick action.
class QaddyIconButton extends StatelessWidget {
  const QaddyIconButton({
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    super.key,
  });

  /// The icon to display.
  final IconData icon;

  /// Called when tapped. Pass `null` to render the disabled state.
  final VoidCallback? onPressed;

  /// Accessibility label describing the action (e.g. "Share").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    final enabled = onPressed != null;
    final background = enabled ? colours.surface1 : colours.disabledBackground;
    final foreground = enabled
        ? colours.textPrimary
        : colours.disabledForeground;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.pill),
        ),
        child: Container(
          width: spacing.iconButtonSize,
          height: spacing.iconButtonSize,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Semantics(
            label: semanticLabel,
            button: true,
            child: Icon(icon, color: foreground),
          ),
        ),
      ),
    );
  }
}
