/// Qaddy's base card — the app's most common elevated surface.
///
/// See `design/ui-components/cards/cards-library-v1.png` and
/// `design/design-tokens/elevation.md` (Cards → `level1`, paired with
/// `shadows.medium`, which is what actually renders here — see
/// `shadows.md`'s own Flutter Implementation example).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';

/// Qaddy's base card — a padded, rounded, shadowed elevated surface.
class QaddyCard extends StatelessWidget {
  const QaddyCard({required this.child, this.onTap, super.key});

  /// The card's content.
  final Widget child;

  /// Optional tap handler — omit for a non-interactive card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final shadows = theme.extension<QaddyShadows>()!;

    final borderRadius = BorderRadius.circular(radius.large);
    final content = Container(
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: borderRadius,
        boxShadow: shadows.medium,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
