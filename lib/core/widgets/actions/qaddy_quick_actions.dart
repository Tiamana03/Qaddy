/// A row of shortcut tiles: the few things a golfer most often opens a screen
/// to do, each one tap from the place it leads (the Dashboard, Profile).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';

/// One shortcut: an icon, a short label and where it goes.
class QaddyQuickAction {
  const QaddyQuickAction({
    required this.icon,
    required this.label,
    required this.colour,
    required this.onTap,
    this.featured = false,
  });

  /// The shortcut's icon.
  final IconData icon;

  /// A short label, e.g. "Score a round".
  final String label;

  /// The accent the icon sits on.
  final Color colour;

  /// Opens the destination.
  final VoidCallback onTap;

  /// The one tile that is filled green, as "Book a Round" is in the mockups:
  /// the shortcut to the thing a golfer most often wants.
  final bool featured;
}

/// A row of equal shortcut tiles that arrive one after another.
class QaddyQuickActions extends StatelessWidget {
  const QaddyQuickActions({required this.actions, super.key});

  /// The shortcuts, left to right.
  final List<QaddyQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    // The mockup's tiles are 80 tall, whatever their labels do.
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (index, action) in actions.indexed) ...<Widget>[
            if (index > 0) SizedBox(width: spacing.cardGap),
            Expanded(
              child: QaddyFadeSlideIn(
                offset: 10,
                delay: staggerDelay(index),
                child: _ActionTile(action: action),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final QaddyQuickAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final borderRadius = BorderRadius.circular(radius.medium);

    return Semantics(
      button: true,
      label: action.label,
      excludeSemantics: true,
      onTap: action.onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: action.featured ? colours.secondary : colours.card,
          borderRadius: borderRadius,
          border: Border.all(
            color: action.featured
                ? colours.selected.withValues(alpha: 0.55)
                : colours.border,
            width: radius.borderWidthDefault,
          ),
          boxShadow: shadows.medium,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              QaddyHaptics.selection();
              action.onTap();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    action.icon,
                    size: 26,
                    color: action.featured
                        ? theme.colorScheme.onPrimary
                        : colours.textPrimary,
                  ),
                  SizedBox(height: spacing.sm - 1),
                  Text(
                    action.label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: QaddyText.doorLabel.copyWith(
                      color: action.featured
                          ? theme.colorScheme.onPrimary
                          : colours.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
