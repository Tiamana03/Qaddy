/// Qaddy colour tokens — see `design/design-tokens/colours.md`.
///
/// Every value here traces back to that document: either the Colour Library
/// asset directly, or an explicitly labelled Engineering Decision
/// (`surface2`, `divider` and `textTertiary` for Light Mode; the 135°
/// gradient direction for both themes). See colours.md for the reasoning
/// behind each Engineering Decision — it is not repeated here.
library;

import 'package:flutter/material.dart';

/// Qaddy's colour palette, as a [ThemeExtension].
///
/// See `design/design-tokens/colours.md` for the source of every value.
/// Unlike spacing/radius/shadows/elevation/motion, colour genuinely differs
/// between themes, so there are two concrete instances: [QaddyColours.dark]
/// (Qaddy's primary theme) and [QaddyColours.light] (the optional/secondary
/// theme).
class QaddyColours extends ThemeExtension<QaddyColours> {
  const QaddyColours({
    required this.primary,
    required this.gold,
    required this.secondary,
    required this.backgroundBase,
    required this.background,
    required this.surface1,
    required this.surface2,
    required this.card,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.premium,
    required this.accentTeal,
    required this.accentSky,
    required this.accentPink,
    required this.accentOrange,
    required this.accentIndigo,
    required this.gradientGreen,
    required this.gradientGold,
    required this.gradientPremium,
  });

  /// Dark Mode — Qaddy's primary theme.
  static const QaddyColours dark = QaddyColours(
    primary: Color(0xFF0F3D2E),
    gold: Color(0xFFD4AF37),
    secondary: Color(0xFF1E6B4B),
    backgroundBase: Color(0xFF081B14),
    background: Color(0xFF081B14),
    surface1: Color(0xFF102820),
    surface2: Color(0xFF163B2E),
    card: Color(0xFF1F2F29),
    border: Color(0xFF2E4A3F),
    divider: Color(0xFF3F5E52),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9FB3AA),
    textTertiary: Color(0xFF6B867B),
    textInverse: Color(0xFF081B14),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    premium: Color(0xFF8B5CF6),
    accentTeal: Color(0xFF14B8A6),
    accentSky: Color(0xFF0EA5E9),
    accentPink: Color(0xFFEC4899),
    accentOrange: Color(0xFFF97316),
    accentIndigo: Color(0xFF6366F1),
    gradientGreen: _greenGradient,
    gradientGold: _goldGradient,
    gradientPremium: _premiumGradient,
  );

  /// Light Mode — Qaddy's optional/secondary theme.
  ///
  /// `surface2`, `divider` and `textTertiary` are Engineering Decisions
  /// (not asset-sourced); see colours.md's "Light Theme" section.
  static const QaddyColours light = QaddyColours(
    primary: Color(0xFF0F3D2E),
    gold: Color(0xFFD4AF37),
    secondary: Color(0xFF1E6B4B),
    backgroundBase: Color(0xFF081B14),
    background: Color(0xFFF8FAF9),
    surface1: Color(0xFFFFFFFF),
    surface2: Color(0xFFF5F7F6),
    card: Color(0xFFF1F5F3),
    border: Color(0xFFD1DAD6),
    divider: Color(0xFFD7DDD9),
    textPrimary: Color(0xFF0F3D2E),
    textSecondary: Color(0xFF6B867B),
    textTertiary: Color(0xFF8CA196),
    textInverse: Color(0xFF081B14),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF3B82F6),
    premium: Color(0xFF8B5CF6),
    accentTeal: Color(0xFF14B8A6),
    accentSky: Color(0xFF0EA5E9),
    accentPink: Color(0xFFEC4899),
    accentOrange: Color(0xFFF97316),
    accentIndigo: Color(0xFF6366F1),
    gradientGreen: _greenGradient,
    gradientGold: _goldGradient,
    gradientPremium: _premiumGradient,
  );

  // Gradient stops are identical in both themes — declared once and shared.
  // 135° (top-left to bottom-right) is an Engineering Decision; see
  // colours.md's "Gradients" section.
  static const LinearGradient _greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF0F3D2E), Color(0xFF1E6B4B)],
  );
  static const LinearGradient _goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFD4AF37), Color(0xFFF4D676)],
  );
  static const LinearGradient _premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );

  // Brand
  /// Main brand colour. Buttons, highlights and key elements.
  final Color primary;

  /// Premium accents. Icons, highlights and special elements.
  final Color gold;

  /// Supporting colour. Secondary buttons and accents.
  final Color secondary;

  /// Raw brand background value that [background] and [textInverse]
  /// resolve to.
  final Color backgroundBase;

  // Neutral
  /// Main app background.
  final Color background;

  /// Cards, modals and elevated surfaces.
  final Color surface1;

  /// Alternate surface and containers.
  final Color surface2;

  /// Card backgrounds.
  final Color card;

  /// Dividers and borders.
  final Color border;

  /// Subtle dividers.
  final Color divider;

  // Text
  /// Headings, primary text, high emphasis.
  final Color textPrimary;

  /// Body text, secondary info.
  final Color textSecondary;

  /// Captions, placeholders, disabled text.
  final Color textTertiary;

  /// Text placed on light backgrounds. Identical in both themes.
  final Color textInverse;

  // Semantic
  /// Success states, completed actions.
  final Color success;

  /// Errors, destructive actions.
  final Color error;

  /// Warnings, caution states.
  final Color warning;

  /// Information, tips and hints.
  final Color info;

  /// Premium features, exclusive content.
  final Color premium;

  // Accent
  /// Charts, data visualisation.
  final Color accentTeal;

  /// Links, interactive elements.
  final Color accentSky;

  /// Highlights, special elements.
  final Color accentPink;

  /// CTAs, active states.
  final Color accentOrange;

  /// Charts, secondary accents.
  final Color accentIndigo;

  // Gradients
  /// Buttons, headers.
  final LinearGradient gradientGreen;

  /// Premium elements.
  final LinearGradient gradientGold;

  /// Special/exclusive features.
  final LinearGradient gradientPremium;

  @override
  QaddyColours copyWith({
    Color? primary,
    Color? gold,
    Color? secondary,
    Color? backgroundBase,
    Color? background,
    Color? surface1,
    Color? surface2,
    Color? card,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textInverse,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? premium,
    Color? accentTeal,
    Color? accentSky,
    Color? accentPink,
    Color? accentOrange,
    Color? accentIndigo,
    LinearGradient? gradientGreen,
    LinearGradient? gradientGold,
    LinearGradient? gradientPremium,
  }) {
    return QaddyColours(
      primary: primary ?? this.primary,
      gold: gold ?? this.gold,
      secondary: secondary ?? this.secondary,
      backgroundBase: backgroundBase ?? this.backgroundBase,
      background: background ?? this.background,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      card: card ?? this.card,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textInverse: textInverse ?? this.textInverse,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      premium: premium ?? this.premium,
      accentTeal: accentTeal ?? this.accentTeal,
      accentSky: accentSky ?? this.accentSky,
      accentPink: accentPink ?? this.accentPink,
      accentOrange: accentOrange ?? this.accentOrange,
      accentIndigo: accentIndigo ?? this.accentIndigo,
      gradientGreen: gradientGreen ?? this.gradientGreen,
      gradientGold: gradientGold ?? this.gradientGold,
      gradientPremium: gradientPremium ?? this.gradientPremium,
    );
  }

  @override
  QaddyColours lerp(ThemeExtension<QaddyColours>? other, double t) {
    if (other is! QaddyColours) {
      return this;
    }
    return QaddyColours(
      primary: Color.lerp(primary, other.primary, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      premium: Color.lerp(premium, other.premium, t)!,
      accentTeal: Color.lerp(accentTeal, other.accentTeal, t)!,
      accentSky: Color.lerp(accentSky, other.accentSky, t)!,
      accentPink: Color.lerp(accentPink, other.accentPink, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentIndigo: Color.lerp(accentIndigo, other.accentIndigo, t)!,
      gradientGreen: LinearGradient.lerp(
        gradientGreen,
        other.gradientGreen,
        t,
      )!,
      gradientGold: LinearGradient.lerp(gradientGold, other.gradientGold, t)!,
      gradientPremium: LinearGradient.lerp(
        gradientPremium,
        other.gradientPremium,
        t,
      )!,
    );
  }
}
