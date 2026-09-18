/// See `docs/architecture/responsive-layout.md`'s "ResponsiveSpacing"
/// section: a lightweight `SizedBox` wrapper that resolves a semantic
/// [ResponsiveSpacingSize] into the corresponding `QaddySpacing` token,
/// per that section's mapping table.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';

/// Semantic spacing sizes for [ResponsiveSpacing].
///
/// Maps to `QaddySpacing` tokens exactly as documented:
/// small → `sm`, medium → `md`, large → `lg`, extraLarge → `xl`.
enum ResponsiveSpacingSize { small, medium, large, extraLarge }

/// Adaptive spacing between widgets — a reusable wrapper around
/// [SizedBox] that resolves [ResponsiveSpacingSize] into a `QaddySpacing`
/// value. Use instead of manually creating responsive `SizedBox` widgets.
class ResponsiveSpacing extends StatelessWidget {
  /// A gap in the given [direction]. Defaults to
  /// [ResponsiveSpacingSize.medium].
  const ResponsiveSpacing({
    required this.direction,
    this.size = ResponsiveSpacingSize.medium,
    super.key,
  });

  /// A vertical gap. Defaults to [ResponsiveSpacingSize.medium].
  const ResponsiveSpacing.vertical({
    this.size = ResponsiveSpacingSize.medium,
    super.key,
  }) : direction = Axis.vertical;

  /// A horizontal gap. Defaults to [ResponsiveSpacingSize.medium].
  const ResponsiveSpacing.horizontal({
    this.size = ResponsiveSpacingSize.medium,
    super.key,
  }) : direction = Axis.horizontal;

  /// Which axis the gap occupies.
  final Axis direction;

  /// The semantic spacing size — resolved to a `QaddySpacing` token per
  /// `responsive-layout.md`'s mapping table.
  final ResponsiveSpacingSize size;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    final value = switch (size) {
      ResponsiveSpacingSize.small => spacing.sm,
      ResponsiveSpacingSize.medium => spacing.md,
      ResponsiveSpacingSize.large => spacing.lg,
      ResponsiveSpacingSize.extraLarge => spacing.xl,
    };

    return direction == Axis.vertical
        ? SizedBox(height: value)
        : SizedBox(width: value);
  }
}
