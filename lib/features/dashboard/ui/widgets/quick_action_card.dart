/// A single Quick Action tile on the Dashboard.
///
/// See `docs/sprints/sprint-02-01-dashboard.md`'s "Quick Actions" section:
/// four of these appear on the Dashboard. Most had no navigation wired up
/// for that sprint, so `onTap` is optional — omitting it keeps a tile
/// visual-only. The Friends tile wires it once the Friends feature exists
/// (see `docs/features/friends-feature-integration.md`'s "Dashboard"
/// section, "Selecting it opens Friends Home").
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';

/// An icon-and-label tile used by the Dashboard's Quick Actions section.
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  /// The action's icon.
  final IconData icon;

  /// The action's label (e.g. "Create Round").
  final String label;

  /// Called when tapped. Omit for a non-interactive, visual-only tile.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // `gold` is documented as "Premium accents. Icons, highlights and
          // special elements" (colours.md) — the correct token for a
          // standalone icon on a card, unlike `primary`, which is too dark
          // to read against a dark-theme card.
          Icon(icon, color: colours.gold, size: spacing.xl),
          SizedBox(height: spacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: typography.small.copyWith(color: colours.textPrimary),
          ),
        ],
      ),
    );
  }
}
