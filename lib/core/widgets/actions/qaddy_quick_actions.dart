/// A row of shortcut tiles: the few things a golfer most often opens a screen
/// to do, each one tap from the place it leads (the Dashboard, Profile).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';

/// One shortcut: an icon, a short label and where it goes.
class QaddyQuickAction {
  const QaddyQuickAction({
    required this.icon,
    required this.label,
    required this.colour,
    required this.onTap,
  });

  /// The shortcut's icon.
  final IconData icon;

  /// A short label, e.g. "Score a round".
  final String label;

  /// The accent the icon sits on.
  final Color colour;

  /// Opens the destination.
  final VoidCallback onTap;
}

/// A row of equal shortcut tiles that arrive one after another.
class QaddyQuickActions extends StatelessWidget {
  const QaddyQuickActions({required this.actions, super.key});

  /// The shortcuts, left to right.
  final List<QaddyQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (index, action) in actions.indexed) ...<Widget>[
            if (index > 0) SizedBox(width: spacing.cardGap),
            Expanded(
              child: QaddyFadeSlideIn(
                offset: 10,
                delay: staggerDelay(index, stepMs: 50),
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
    final typography = theme.extension<QaddyTypography>()!;
    final borderRadius = BorderRadius.circular(radius.large);

    return Semantics(
      button: true,
      label: action.label,
      excludeSemantics: true,
      onTap: action.onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colours.card,
          borderRadius: borderRadius,
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
              padding: EdgeInsets.symmetric(
                vertical: spacing.md,
                horizontal: spacing.xs,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    QaddyIconBadge(
                      icon: action.icon,
                      colour: action.colour,
                      size: 44,
                    ),
                    SizedBox(height: spacing.sm),
                    Text(
                      action.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: typography.small.copyWith(
                        color: colours.textPrimary,
                        fontWeight: FontWeight.w600,
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
