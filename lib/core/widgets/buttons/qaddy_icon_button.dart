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
    required IconData this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    super.key,
  }) : child = null;

  /// An icon button whose face is any widget (the bell with its unread
  /// badge, for example).
  const QaddyIconButton.custom({
    required Widget this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    super.key,
  }) : icon = null;

  /// The icon to display, or `null` when [child] is.
  final IconData? icon;

  /// A custom face, for [QaddyIconButton.custom].
  final Widget? child;

  /// Shown on hover and long-press, and read out by screen readers.
  final String? tooltip;

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

    final button = Material(
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
            child: child ?? Icon(icon, color: foreground),
          ),
        ),
      ),
    );
    final tip = tooltip;
    return tip == null ? button : Tooltip(message: tip, child: button);
  }
}
