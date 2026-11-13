/// The Statistics mockup's section card: a bordered dark panel with its title
/// at the left and a quiet "View Details ›" at the right, over whatever the
/// section shows.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';

/// A titled panel.
class StatsPanel extends StatelessWidget {
  const StatsPanel({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.titleTrailing,
    this.padding = const EdgeInsets.fromLTRB(9, 9, 9, 7),
    this.gap = 6,
    super.key,
  });

  /// The section's name.
  final String title;

  /// The text of the link at the right ("View Details").
  final String? actionLabel;

  /// Called when the link is tapped.
  final VoidCallback? onAction;

  /// A small widget beside the title (the handicap's info button).
  final Widget? titleTrailing;

  /// The panel's content.
  final Widget child;

  /// Space inside the border.
  final EdgeInsetsGeometry padding;

  /// Space between the title row and the content.
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: BorderRadius.circular(radius.medium - 2),
        border: Border.all(color: colours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: QaddyText.sectionTitle.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 20 / 13.5,
                      color: colours.textPrimary,
                    ),
                  ),
                ),
                ?titleTrailing,
                const Spacer(),
                if (actionLabel != null)
                  Semantics(
                    button: true,
                    label: '$actionLabel, $title',
                    excludeSemantics: true,
                    onTap: onAction,
                    child: InkWell(
                      onTap: onAction,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              actionLabel!,
                              style: QaddyText.listMeta.copyWith(
                                fontSize: 11,
                                height: 16 / 11,
                                color: colours.textPrimary,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: colours.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: gap),
          child,
        ],
      ),
    );
  }
}
