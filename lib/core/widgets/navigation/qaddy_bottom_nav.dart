/// Qaddy's bottom navigation bar, as the approved mockups draw it: a rounded
/// bar that runs almost edge to edge on the `surface1` layer, filled icons and
/// a gold label for the active destination, with a soft green pill behind the
/// active icon. (The mockups, not the Navigation Library sheet, are the
/// source of truth; the library follows them.)
///
/// The active item uses `accent` (gold in Dark Mode). Labels use the
/// `navigation` text style (Inter 12 / 500).
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
          spacing.sm,
          spacing.xs,
          spacing.sm,
          spacing.sm,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colours.surface1,
            borderRadius: BorderRadius.circular(radius.extraLarge),
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
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: animate ? QaddyMotion.standard.normal : Duration.zero,
                curve: QaddyMotion.standard.enter,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.lg,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? colours.selected.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(radius.medium),
                  border: Border.all(
                    color: active
                        ? colours.selected.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Icon(
                  active ? item.activeIcon : item.icon,
                  size: spacing.xl + spacing.xs,
                  color: colour,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.navigation.copyWith(color: colour),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
