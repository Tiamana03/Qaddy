/// Qaddy's chip selectors — pick one or several of a handful of options.
///
/// Built from the design tokens rather than Material's `ChoiceChip` /
/// `FilterChip`, whose selected state is tinted from `primary` (dark green) and
/// so reads poorly on Dark Mode surfaces. Use [QaddyChipSelector] for exactly
/// one choice and [QaddyMultiChipSelector] for any number.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// One option in a chip selector.
class QaddyChipOption<T> {
  const QaddyChipOption({required this.value, required this.label, this.icon});

  /// The value reported when the chip is chosen.
  final T value;

  /// The chip's text.
  final String label;

  /// An optional leading icon.
  final IconData? icon;
}

/// Exactly one of [options] is chosen.
class QaddyChipSelector<T> extends StatelessWidget {
  const QaddyChipSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The choices, in display order.
  final List<QaddyChipOption<T>> options;

  /// The chosen value.
  final T selected;

  /// Called with the value the user taps.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: <Widget>[
        for (final option in options)
          _QaddyChip(
            label: option.label,
            icon: option.icon,
            selected: option.value == selected,
            onTap: () => onChanged(option.value),
          ),
      ],
    );
  }
}

/// Any number of [options] are chosen.
class QaddyMultiChipSelector<T> extends StatelessWidget {
  const QaddyMultiChipSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The choices, in display order.
  final List<QaddyChipOption<T>> options;

  /// The chosen values.
  final Set<T> selected;

  /// Called with the new selection whenever a chip is toggled.
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: <Widget>[
        for (final option in options)
          _QaddyChip(
            label: option.label,
            icon: option.icon,
            selected: selected.contains(option.value),
            onTap: () {
              final next = Set<T>.of(selected);
              if (!next.remove(option.value)) {
                next.add(option.value);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _QaddyChip extends StatelessWidget {
  const _QaddyChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final foreground = selected ? colours.accent : colours.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? colours.surface2 : Colors.transparent,
        borderRadius: BorderRadius.circular(radius.large),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius.large),
          onTap: onTap,
          child: Container(
            // 44px keeps the chip comfortably tappable.
            constraints: const BoxConstraints(minHeight: 44),
            padding: EdgeInsets.symmetric(horizontal: spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.large),
              border: Border.all(
                color: selected ? colours.accent : colours.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (selected)
                  Icon(Icons.check, size: spacing.lg, color: foreground)
                else if (icon != null)
                  Icon(icon, size: spacing.lg, color: foreground),
                if (selected || icon != null) SizedBox(width: spacing.xs),
                Text(
                  label,
                  style: typography.button.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
