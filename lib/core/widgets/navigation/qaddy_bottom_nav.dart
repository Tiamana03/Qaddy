/// Qaddy's bottom navigation bar, built to the Navigation Library: a floating,
/// rounded bar on the `surface1` layer with the `medium` shadow, outlined icons
/// that fill when active, and a short indicator under the active destination.
///
/// The active item uses `accent` (gold in Dark Mode), per `colours.md`'s rule
/// for the selected bottom-navigation item. Labels use the `navigation` text
/// style (Inter 12 / 500).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';

/// One destination in a [QaddyBottomNav].
class QaddyNavDestination {
  const QaddyNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  /// The destination's name, shown under the icon.
  final String label;

  /// The icon while the destination is not active.
  final IconData icon;

  /// The icon while the destination is active.
  final IconData activeIcon;
}

/// A floating bottom navigation bar.
class QaddyBottomNav extends StatelessWidget {
  const QaddyBottomNav({
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  /// The destinations, left to right.
  final List<QaddyNavDestination> destinations;

  /// The active destination's index.
  final int currentIndex;

  /// Called with the index the user taps (including the active one).
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.md,
          spacing.xs,
          spacing.md,
          spacing.sm,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colours.surface1,
            borderRadius: BorderRadius.circular(radius.large),
            border: Border.all(color: colours.border),
            boxShadow: shadows.medium,
          ),
          child: Row(
            children: <Widget>[
              for (final (index, item) in destinations.indexed)
                Expanded(
                  child: _NavItem(
                    item: item,
                    active: index == currentIndex,
                    animate: animate,
                    onTap: () {
                      if (index != currentIndex) {
                        QaddyHaptics.selection();
                      }
                      onSelected(index);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.active,
    required this.animate,
    required this.onTap,
  });

  final QaddyNavDestination item;
  final bool active;
  final bool animate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final colour = active ? colours.accent : colours.textTertiary;

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.large),
        child: Padding(
          padding: EdgeInsets.only(top: spacing.sm, bottom: spacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                active ? item.activeIcon : item.icon,
                size: spacing.xl,
                color: colour,
              ),
              SizedBox(height: spacing.xs),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.navigation.copyWith(color: colour),
              ),
              SizedBox(height: spacing.xs),
              AnimatedContainer(
                duration: animate ? QaddyMotion.standard.normal : Duration.zero,
                curve: QaddyMotion.standard.enter,
                width: active ? spacing.xl : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: colours.accent,
                  borderRadius: BorderRadius.circular(radius.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
