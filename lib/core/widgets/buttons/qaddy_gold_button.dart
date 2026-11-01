/// Qaddy's gold call-to-action: the one bright button on a hero, a sheet or a
/// card that says "do this next" ("Get ready", "Accept", "Send a challenge").
///
/// Gold on the app's deep greens is what makes it the obvious tap, so use it
/// once per surface. The standard green `QaddyPrimaryButton` remains the
/// everyday primary action on plain screens.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A full-width (or [Expanded]-sized) gold button with an optional leading
/// icon.
class QaddyGoldButton extends StatelessWidget {
  const QaddyGoldButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.tall = false,
    super.key,
  });

  /// The button's text.
  final String label;

  /// Called when tapped. `null` disables the button.
  final VoidCallback? onPressed;

  /// An optional leading icon.
  final IconData? icon;

  /// A slightly taller button, for a hero's single main action.
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final style = FilledButton.styleFrom(
      backgroundColor: colours.gold,
      foregroundColor: colours.backgroundBase,
      minimumSize: Size.fromHeight(spacing.display + (tall ? 4 : 0)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.medium),
      ),
    );
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: typography.button,
    );

    if (icon == null) {
      return FilledButton(style: style, onPressed: onPressed, child: text);
    }
    return FilledButton.icon(
      style: style,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: text,
    );
  }
}
