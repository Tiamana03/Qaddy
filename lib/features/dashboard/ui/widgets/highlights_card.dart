/// Recent highlights: the moments from the golfer's own game, each one a
/// shortcut to the place it belongs.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';

/// One highlight and where it leads.
class Highlight {
  const Highlight({
    required this.icon,
    required this.colour,
    required this.text,
    required this.onTap,
  });

  /// What kind of moment it was.
  final IconData icon;

  /// The accent behind the icon.
  final Color colour;

  /// What happened.
  final String text;

  /// Opens the related screen.
  final VoidCallback onTap;
}

/// A card listing [highlights], each row tappable.
class HighlightsCard extends StatelessWidget {
  const HighlightsCard({required this.highlights, super.key});

  /// The moments, newest first.
  final List<Highlight> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final item in highlights)
            Semantics(
              button: true,
              label: item.text,
              excludeSemantics: true,
              onTap: item.onTap,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.sm),
                    child: Row(
                      children: <Widget>[
                        QaddyIconBadge(
                          icon: item.icon,
                          colour: item.colour,
                          size: 36,
                          iconSize: 20,
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: Text(
                            item.text,
                            style: typography.body.copyWith(
                              color: colours.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colours.textTertiary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
