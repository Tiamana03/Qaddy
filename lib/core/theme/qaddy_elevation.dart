/// Qaddy elevation tokens — see `design/design-tokens/elevation.md`.
///
/// No asset defines these values; every field here is an Engineering
/// Decision documented in that file, reusing Material Design 3's standard
/// elevation scale (0/1/3/6/8/12). Elevation levels do not change between
/// Light and Dark Mode, so there is a single shared instance:
/// [QaddyElevation.standard].
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Qaddy's elevation (stacking-order) scale, as a [ThemeExtension].
///
/// This is a layering concept, distinct from `qaddy_shadows.dart`, which
/// defines how each layer is visually rendered. See
/// `design/design-tokens/elevation.md` for the source of every value and
/// how each level maps to a shadow token.
class QaddyElevation extends ThemeExtension<QaddyElevation> {
  const QaddyElevation({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });

  /// The single instance used by both `QaddyTheme.light` and
  /// `QaddyTheme.dark` — elevation does not vary by theme.
  static const QaddyElevation standard = QaddyElevation(
    level0: 0,
    level1: 1,
    level2: 3,
    level3: 6,
    level4: 8,
    level5: 12,
  );

  /// Background — nothing sits below it. Paired shadow token: `none`.
  final double level0;

  /// Cards — Qaddy's most common elevated surface. Paired shadow: `medium`.
  final double level1;

  /// Navigation (bottom bar / top app bar). Paired shadow token: `small`.
  final double level2;

  /// Floating Action Button. Paired shadow token: `extraLarge`.
  final double level3;

  /// Dialog. Paired shadow token: `large`.
  final double level4;

  /// Modal (e.g. a large bottom sheet) — the top of the stack. Paired
  /// shadow token: `extraLarge`.
  final double level5;

  @override
  QaddyElevation copyWith({
    double? level0,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
    double? level5,
  }) {
    return QaddyElevation(
      level0: level0 ?? this.level0,
      level1: level1 ?? this.level1,
      level2: level2 ?? this.level2,
      level3: level3 ?? this.level3,
      level4: level4 ?? this.level4,
      level5: level5 ?? this.level5,
    );
  }

  @override
  QaddyElevation lerp(ThemeExtension<QaddyElevation>? other, double t) {
    if (other is! QaddyElevation) {
      return this;
    }
    return QaddyElevation(
      level0: lerpDouble(level0, other.level0, t)!,
      level1: lerpDouble(level1, other.level1, t)!,
      level2: lerpDouble(level2, other.level2, t)!,
      level3: lerpDouble(level3, other.level3, t)!,
      level4: lerpDouble(level4, other.level4, t)!,
      level5: lerpDouble(level5, other.level5, t)!,
    );
  }
}
