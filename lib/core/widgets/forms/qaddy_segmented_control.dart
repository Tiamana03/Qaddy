/// Qaddy's segmented control — pick exactly one of a few short options.
///
/// Used where a dropdown would hide the choices (e.g. Private / Public).
/// Built from the design tokens rather than Material's `SegmentedButton`,
/// whose selected state uses `primary` (dark green) and so reads poorly on
/// Dark Mode surfaces.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';

/// One option in a [QaddySegmentedControl].
class QaddySegment<T> {
  const QaddySegment({required this.value, required this.label, this.icon});

  /// The value reported when this segment is chosen.
  final T value;

  /// The segment's text.
  final String label;

  /// An optional leading icon.
  final IconData? icon;
}

/// A row of mutually exclusive options.
class QaddySegmentedControl<T> extends StatelessWidget {
  const QaddySegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The options, in display order.
  final List<QaddySegment<T>> segments;

  /// The currently chosen value.
  final T selected;

  /// Called with the value the user taps.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Container(
      padding: EdgeInsets.all(spacing.xs),
      decoration: BoxDecoration(
        color: colours.surface1,
        borderRadius: BorderRadius.circular(radius.medium),
        border: Border.all(color: colours.border),
      ),
      child: Row(
        children: <Widget>[
          for (final segment in segments)
            Expanded(
              child: Semantics(
                button: true,
                selected: segment.value == selected,
                label: segment.label,
                excludeSemantics: true,
                onTap: () {
                  QaddyHaptics.selection();
                  onChanged(segment.value);
                },
                child: Material(
                  color: segment.value == selected
                      ? colours.secondary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(radius.small),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(radius.small),
                    onTap: () {
                      QaddyHaptics.selection();
                      onChanged(segment.value);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: spacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (segment.icon != null) ...<Widget>[
                            Icon(
                              segment.icon,
                              size: spacing.lg,
                              color: segment.value == selected
                                  ? theme.colorScheme.onPrimary
                                  : colours.textSecondary,
                            ),
                            SizedBox(width: spacing.xs),
                          ],
                          Flexible(
                            child: Text(
                              segment.label,
                              overflow: TextOverflow.ellipsis,
                              style: typography.button.copyWith(
                                color: segment.value == selected
                                    ? theme.colorScheme.onPrimary
                                    : colours.textSecondary,
                              ),
                            ),
                          ),
                        ],
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
