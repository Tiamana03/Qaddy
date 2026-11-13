/// The row of pill tabs under a screen's title in the approved mockups
/// ("Upcoming (3)  Completed (12)  Invitations (2)"): equal pills, the chosen
/// one filled green, the others dark with a hairline, and an optional red dot
/// on the corner of one that has news.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/utils/haptics.dart';

/// One tab.
class QaddyPillTab {
  const QaddyPillTab({required this.label, this.alert = false});

  /// The tab's text, count included ("Completed (12)").
  final String label;

  /// Draws the red dot on its corner.
  final bool alert;
}

/// A row of equal pill tabs.
class QaddyPillTabs extends StatelessWidget {
  const QaddyPillTabs({
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.joined = false,
    super.key,
  });

  /// The tabs, left to right.
  final List<QaddyPillTab> tabs;

  /// The index of the chosen tab.
  final int selected;

  /// Called with the index that was tapped.
  final ValueChanged<int> onChanged;

  /// Draws the tabs as one strip, the chosen one inset in green (the Groups
  /// mockup), rather than as separate pills (the Rounds mockup).
  final bool joined;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    if (joined) {
      return Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colours.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colours.border),
        ),
        child: Row(
          children: <Widget>[
            for (final (index, tab) in tabs.indexed) ...<Widget>[
              if (index > 0)
                Container(
                  width: 1,
                  height: 18,
                  color: index == selected || index - 1 == selected
                      ? Colors.transparent
                      : colours.border,
                ),
              Expanded(
                child: Semantics(
                  button: true,
                  selected: index == selected,
                  label: tab.label,
                  excludeSemantics: true,
                  onTap: () => onChanged(index),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Material(
                        color: index == selected
                            ? colours.selected
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            QaddyHaptics.selection();
                            onChanged(index);
                          },
                          child: SizedBox(
                            height: 36,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    tab.label,
                                    maxLines: 1,
                                    style: QaddyText.tabLabel.copyWith(
                                      color: colours.textPrimary,
                                      fontWeight: index == selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (tab.alert)
                        Positioned(
                          right: 4,
                          top: 2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colours.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Row(
      children: <Widget>[
        for (final (index, tab) in tabs.indexed) ...<Widget>[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              button: true,
              selected: index == selected,
              label: tab.label,
              excludeSemantics: true,
              onTap: () => onChanged(index),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Material(
                    color: index == selected
                        ? colours.selected
                        : colours.surface1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: index == selected
                            ? colours.selected
                            : colours.border,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        QaddyHaptics.selection();
                        onChanged(index);
                      },
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                tab.label,
                                maxLines: 1,
                                style: QaddyText.tabLabel.copyWith(
                                  color: colours.textPrimary,
                                  fontWeight: index == selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (tab.alert)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colours.error,
                          border: Border.all(color: colours.background),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
