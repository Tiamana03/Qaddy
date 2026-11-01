/// Qaddy's section heading: a title on the left and, optionally, a "See all"
/// style action on the right. Used to introduce a block of content on a
/// screen so the heading both names the block and leads into it.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A heading with an optional trailing action.
class QaddySectionHeading extends StatelessWidget {
  const QaddySectionHeading({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.badge,
    super.key,
  });

  /// The heading text.
  final String title;

  /// The action's label, e.g. "See all". Shown only with [onAction].
  final String? actionLabel;

  /// Called when the action is tapped.
  final VoidCallback? onAction;

  /// A small count shown beside the title (e.g. pending requests).
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final count = badge;

    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.h3.copyWith(color: colours.textPrimary),
                  ),
                ),
                if (count != null && count > 0) ...<Widget>[
                  SizedBox(width: spacing.sm),
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colours.gold,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: typography.caption.copyWith(
                        color: colours.backgroundBase,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 44),
              padding: EdgeInsets.symmetric(horizontal: spacing.sm),
            ),
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
