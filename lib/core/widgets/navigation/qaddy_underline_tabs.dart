/// The text tabs under a screen's title in the Golf Bag and Trips mockups
/// ("My Clubs  Distances  Insights"): equal columns, the chosen one in white
/// with a gold line beneath it and a soft lift behind it, the others quiet.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/utils/haptics.dart';

/// Underlined text tabs.
class QaddyUnderlineTabs extends StatelessWidget {
  const QaddyUnderlineTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The tabs' text, left to right.
  final List<String> labels;

  /// The index of the chosen tab.
  final int selected;

  /// Called with the index that was tapped.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colours.border)),
      ),
      child: Row(
        children: <Widget>[
          for (final (index, label) in labels.indexed)
            Expanded(
              child: Semantics(
                button: true,
                selected: index == selected,
                label: label,
                excludeSemantics: true,
                onTap: () => onChanged(index),
                child: InkWell(
                  onTap: () {
                    QaddyHaptics.selection();
                    onChanged(index);
                  },
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: index == selected
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                colours.selected.withValues(alpha: 0),
                                colours.selected.withValues(alpha: 0.22),
                              ],
                            )
                          : null,
                      border: Border(
                        bottom: BorderSide(
                          color: index == selected
                              ? colours.gold
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      style: QaddyText.tabLabel.copyWith(
                        color: index == selected
                            ? colours.textPrimary
                            : colours.textSecondary,
                        fontWeight: index == selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
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
