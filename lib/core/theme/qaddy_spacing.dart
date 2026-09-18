/// Qaddy spacing tokens — see `design/design-tokens/spacing.md`.
///
/// No asset defines these values; every field here is an Engineering
/// Decision documented in that file (a 4px base unit, widening to 8px
/// steps). Spacing does not change between Light and Dark Mode, so there is
/// a single shared instance: [QaddySpacing.standard].
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Qaddy's spacing scale, as a [ThemeExtension].
///
/// See `design/design-tokens/spacing.md` for the source of every value.
class QaddySpacing extends ThemeExtension<QaddySpacing> {
  const QaddySpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.display,
    required this.hero,
    required this.pagePadding,
    required this.cardPadding,
    required this.buttonPadding,
    required this.sectionGap,
    required this.cardGap,
    required this.iconButtonSize,
  });

  /// The single instance used by both `QaddyTheme.light` and
  /// `QaddyTheme.dark` — spacing does not vary by theme.
  static const QaddySpacing standard = QaddySpacing(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
    xxxl: 40,
    display: 48,
    hero: 64,
    pagePadding: 24,
    cardPadding: 16,
    buttonPadding: 12,
    sectionGap: 32,
    cardGap: 16,
    iconButtonSize: 48,
  );

  /// Tiny spacing: icon padding, space between an icon and its label.
  final double xs;

  /// Small gaps: space between closely related inline elements.
  final double sm;

  /// Compact layouts: internal padding for dense components.
  final double md;

  /// Standard spacing: default card padding, standard list-item gaps.
  final double lg;

  /// Section-level spacing: default screen/page padding.
  final double xl;

  /// Large sections: separation between distinct sections on a screen.
  final double xxl;

  /// Major separation: separation between unrelated content groups.
  final double xxxl;

  /// Hero layouts: padding around hero/feature content.
  final double display;

  /// Landing screens: generous top-level padding.
  final double hero;

  /// Default horizontal padding for a screen's content area.
  ///
  /// Alias of [xl].
  final double pagePadding;

  /// Default internal padding for a card or elevated surface.
  ///
  /// Alias of [lg].
  final double cardPadding;

  /// Default internal padding for a button's content.
  ///
  /// Alias of [md].
  final double buttonPadding;

  /// Default vertical gap between distinct sections on a screen.
  ///
  /// Alias of [xxl].
  final double sectionGap;

  /// Default gap between adjacent cards in a list or grid.
  ///
  /// Alias of [lg].
  final double cardGap;

  /// Diameter / tap-target size for icon buttons.
  ///
  /// Alias of [display].
  final double iconButtonSize;

  @override
  QaddySpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? display,
    double? hero,
    double? pagePadding,
    double? cardPadding,
    double? buttonPadding,
    double? sectionGap,
    double? cardGap,
    double? iconButtonSize,
  }) {
    return QaddySpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      display: display ?? this.display,
      hero: hero ?? this.hero,
      pagePadding: pagePadding ?? this.pagePadding,
      cardPadding: cardPadding ?? this.cardPadding,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      sectionGap: sectionGap ?? this.sectionGap,
      cardGap: cardGap ?? this.cardGap,
      iconButtonSize: iconButtonSize ?? this.iconButtonSize,
    );
  }

  @override
  QaddySpacing lerp(ThemeExtension<QaddySpacing>? other, double t) {
    if (other is! QaddySpacing) {
      return this;
    }
    return QaddySpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      xxxl: lerpDouble(xxxl, other.xxxl, t)!,
      display: lerpDouble(display, other.display, t)!,
      hero: lerpDouble(hero, other.hero, t)!,
      pagePadding: lerpDouble(pagePadding, other.pagePadding, t)!,
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t)!,
      buttonPadding: lerpDouble(buttonPadding, other.buttonPadding, t)!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t)!,
      cardGap: lerpDouble(cardGap, other.cardGap, t)!,
      iconButtonSize: lerpDouble(iconButtonSize, other.iconButtonSize, t)!,
    );
  }
}
