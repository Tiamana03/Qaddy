/// Qaddy's gold call-to-action: the one bright button on a hero, a sheet or a
/// card that says "do this next" ("Get ready", "Accept", "Send a challenge").
///
/// Built to the Buttons Library: the Gold Gradient token (`gradientGold`) on a
/// `medium`-radius shape with the `small` shadow, in the library's three
/// heights (Large 56, Medium 48, Small 40), with a distinct disabled state.
/// Gold on the app's deep greens is what makes it the obvious tap, so use it
/// once per surface. The green `QaddyPrimaryButton` remains available for
/// quieter primary actions.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// The Buttons Library's standard heights, in logical pixels.
abstract final class QaddyButtonHeight {
  /// Large (56): a hero's single main action.
  static const double large = 56;

  /// Medium (48): the default.
  static const double medium = 48;

  /// Small (40): compact, inline actions.
  static const double small = 40;
}

/// A full-width (or [Expanded]-sized) gold button with an optional leading
/// icon.
class QaddyGoldButton extends StatelessWidget {
  const QaddyGoldButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.tall = false,
    this.compact = false,
    super.key,
  });

  /// The button's text.
  final String label;

  /// Called when tapped. `null` disables the button.
  final VoidCallback? onPressed;

  /// An optional leading icon.
  final IconData? icon;

  /// The Large (56) size, for a hero's single main action.
  final bool tall;

  /// The Small (40) size, for compact inline actions.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final enabled = onPressed != null;
    final height = tall
        ? QaddyButtonHeight.large
        : compact
        ? QaddyButtonHeight.small
        : QaddyButtonHeight.medium;
    final foreground = enabled
        ? colours.backgroundBase
        : colours.disabledForeground;
    final shape = BorderRadius.circular(radius.medium);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? colours.gradientGold : null,
          color: enabled ? null : colours.disabledBackground,
          borderRadius: shape,
          boxShadow: enabled ? shadows.small : shadows.none,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: shape,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: double.infinity,
                minHeight: height,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: 18, color: foreground),
                      SizedBox(width: spacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.button.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
