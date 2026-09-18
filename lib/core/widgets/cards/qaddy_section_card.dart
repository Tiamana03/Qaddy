/// Qaddy's section card — a titled grouping of related content.
///
/// Built on [QaddyCard]; see `design/ui-components/cards/cards-library-v1.png`
/// (Card Anatomy: Title + content).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';

/// A [QaddyCard] with a title heading above its content.
class QaddySectionCard extends StatelessWidget {
  const QaddySectionCard({
    required this.title,
    required this.child,
    this.onTap,
    super.key,
  });

  /// The section's title.
  final String title;

  /// The section's content, shown below the title.
  final Widget child;

  /// Optional tap handler — omit for a non-interactive card.
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.sm),
          child,
        ],
      ),
    );
  }
}
