/// Qaddy border-radius tokens — see `design/design-tokens/radius.md`.
///
/// No asset defines these values; every field here is an Engineering
/// Decision documented in that file, reusing `spacing.md`'s own scale
/// (8/16/24/32). Radius does not change between Light and Dark Mode, so
/// there is a single shared instance: [QaddyRadius.standard].
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Qaddy's corner-radius scale, as a [ThemeExtension].
///
/// See `design/design-tokens/radius.md` for the source of every value.
class QaddyRadius extends ThemeExtension<QaddyRadius> {
  const QaddyRadius({
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
    required this.pill,
    required this.borderWidthDefault,
    required this.borderWidthFocused,
  });

  /// The single instance used by both `QaddyTheme.light` and
  /// `QaddyTheme.dark` — radius does not vary by theme.
  static const QaddyRadius standard = QaddyRadius(
    small: 8,
    medium: 16,
    large: 24,
    extraLarge: 32,
    pill: 999,
    borderWidthDefault: 1,
    borderWidthFocused: 2,
  );

  /// Compact controls: input fields, badges, tags, small filter chips.
  final double small;

  /// Buttons.
  final double medium;

  /// Cards, dialogs.
  final double large;

  /// Bottom sheets.
  final double extraLarge;

  /// Chips, fully-rounded status pills.
  ///
  /// Larger than any realistic component height, which forces
  /// [BorderRadius.circular] to cap at a true stadium/pill shape.
  final double pill;

  /// Default state for input fields and any other outlined control.
  final double borderWidthDefault;

  /// Focused state for input fields and any other outlined control.
  final double borderWidthFocused;

  @override
  QaddyRadius copyWith({
    double? small,
    double? medium,
    double? large,
    double? extraLarge,
    double? pill,
    double? borderWidthDefault,
    double? borderWidthFocused,
  }) {
    return QaddyRadius(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
      pill: pill ?? this.pill,
      borderWidthDefault: borderWidthDefault ?? this.borderWidthDefault,
      borderWidthFocused: borderWidthFocused ?? this.borderWidthFocused,
    );
  }

  @override
  QaddyRadius lerp(ThemeExtension<QaddyRadius>? other, double t) {
    if (other is! QaddyRadius) {
      return this;
    }
    return QaddyRadius(
      small: lerpDouble(small, other.small, t)!,
      medium: lerpDouble(medium, other.medium, t)!,
      large: lerpDouble(large, other.large, t)!,
      extraLarge: lerpDouble(extraLarge, other.extraLarge, t)!,
      pill: lerpDouble(pill, other.pill, t)!,
      borderWidthDefault: lerpDouble(
        borderWidthDefault,
        other.borderWidthDefault,
        t,
      )!,
      borderWidthFocused: lerpDouble(
        borderWidthFocused,
        other.borderWidthFocused,
        t,
      )!,
    );
  }
}
