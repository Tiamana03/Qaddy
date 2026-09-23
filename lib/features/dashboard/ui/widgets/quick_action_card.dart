/// A single Quick Action tile on the Dashboard.
///
/// See `docs/sprints/sprint-02-01-dashboard.md`'s "Quick Actions" section:
/// four of these appear on the Dashboard with no navigation wired up yet,
/// so this widget takes no `onTap` — it is visual-only for this sprint.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';

/// A non-interactive icon-and-label tile used by the Dashboard's Quick
/// Actions section.
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({required this.icon, required this.label, super.key});

  /// The action's icon.
  final IconData icon;

  /// The action's label (e.g. "Create Round").
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
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
