/// Qaddy typography tokens — see `design/design-tokens/typography.md`.
///
/// Font size, weight, line height and letter spacing are transcribed from
/// the Typography Library asset for `display` through `caption`. `button`,
/// `navigation` and every statistics style's line height/letter spacing are
/// Engineering Decisions documented in that file — see the inline comments
/// below for which. The font family (Inter) is also an Engineering
/// Decision; it is not bundled as an asset yet (see the Engineering
/// Decisions note in the Sprint 1.1 summary), so it currently falls back to
/// the system sans-serif, which is the documented fallback behaviour.
///
/// Typography does not change between Light and Dark Mode (no colour is
/// embedded in these styles), so there is a single shared instance:
/// [QaddyTypography.standard].
library;

import 'package:flutter/material.dart';

/// Qaddy's text-style scale, as a [ThemeExtension].
///
/// See `design/design-tokens/typography.md` for the source of every value.
class QaddyTypography extends ThemeExtension<QaddyTypography> {
  const QaddyTypography({
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.bodyLarge,
    required this.body,
    required this.small,
    required this.caption,
    required this.button,
    required this.navigation,
    required this.statLarge,
    required this.statHoleNumber,
    required this.statHandicap,
    required this.statScore,
    required this.statDistance,
    required this.statDistanceLong,
  });

  static const String _fontFamily = 'Inter';

  /// The single instance used by both `QaddyTheme.light` and
  /// `QaddyTheme.dark` — typography does not vary by theme.
  static const QaddyTypography standard = QaddyTypography(
    display: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 72,
      fontWeight: FontWeight.w700,
      height: 80 / 72,
      letterSpacing: -1.5,
    ),
    h1: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 48 / 40,
      letterSpacing: -0.5,
    ),
    h2: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 40 / 32,
      letterSpacing: -0.25,
    ),
    h3: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
    ),
    h4: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 28 / 20,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 28 / 18,
    ),
    body: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
    ),
    small: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
    ),
    caption: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
      letterSpacing: 0.25,
    ),
    // Engineering Decision (typography.md): not sourced from the asset.
    button: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 24 / 16,
      letterSpacing: 0.1,
    ),
    // Engineering Decision (typography.md): not sourced from the asset.
    navigation: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      letterSpacing: 0.2,
    ),
    // Size/weight sourced; line height is an Engineering Decision matching
    // `display`. Letter spacing is not decided — left unset per the doc.
    statLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 72,
      fontWeight: FontWeight.w700,
      height: 80 / 72,
    ),
    // Size/weight sourced; line height and letter spacing are Engineering
    // Decisions (56px line height for an 8px vertical rhythm; 0 spacing).
    statHoleNumber: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 56 / 48,
      letterSpacing: 0,
    ),
    // Size/weight sourced; line height is an Engineering Decision matching
    // `h1`. Letter spacing is not decided — left unset per the doc.
    statHandicap: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 48 / 40,
    ),
    // Size/weight sourced; line height is an Engineering Decision matching
    // `h1`. Letter spacing is not decided — left unset per the doc.
    statScore: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 48 / 40,
    ),
    // Size/weight sourced; line height is an Engineering Decision matching
    // `h1`. Letter spacing is not decided — left unset per the doc.
    statDistance: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 48 / 40,
    ),
    // Size/weight sourced; line height is an Engineering Decision. Letter
    // spacing is not decided — left unset per the doc.
    statDistanceLong: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 40 / 32,
    ),
  );

  /// Hero titles and key messaging.
  final TextStyle display;

  /// Main page headings.
  final TextStyle h1;

  /// Section headings.
  final TextStyle h2;

  /// Subsection headings.
  final TextStyle h3;

  /// Smaller headings.
  final TextStyle h4;

  /// Important body content.
  final TextStyle bodyLarge;

  /// Standard body text.
  final TextStyle body;

  /// Secondary information.
  final TextStyle small;

  /// Hints, labels and metadata.
  final TextStyle caption;

  /// Button labels.
  final TextStyle button;

  /// Bottom navigation and tab labels.
  final TextStyle navigation;

  /// Large hero-sized statistics (e.g. a round's final score total).
  final TextStyle statLarge;

  /// The current hole number in scoring/live-scoring UI.
  final TextStyle statHoleNumber;

  /// Handicap index display.
  final TextStyle statHandicap;

  /// A single score value (e.g. "-3").
  final TextStyle statScore;

  /// Short-form distances (e.g. "254m").
  final TextStyle statDistance;

  /// Longer-form distances (e.g. "15.4 km").
  final TextStyle statDistanceLong;

  @override
  QaddyTypography copyWith({
    TextStyle? display,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? bodyLarge,
    TextStyle? body,
    TextStyle? small,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? navigation,
    TextStyle? statLarge,
    TextStyle? statHoleNumber,
    TextStyle? statHandicap,
    TextStyle? statScore,
    TextStyle? statDistance,
    TextStyle? statDistanceLong,
  }) {
    return QaddyTypography(
      display: display ?? this.display,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      body: body ?? this.body,
      small: small ?? this.small,
      caption: caption ?? this.caption,
      button: button ?? this.button,
      navigation: navigation ?? this.navigation,
      statLarge: statLarge ?? this.statLarge,
      statHoleNumber: statHoleNumber ?? this.statHoleNumber,
      statHandicap: statHandicap ?? this.statHandicap,
      statScore: statScore ?? this.statScore,
      statDistance: statDistance ?? this.statDistance,
      statDistanceLong: statDistanceLong ?? this.statDistanceLong,
    );
  }

  @override
  QaddyTypography lerp(ThemeExtension<QaddyTypography>? other, double t) {
    if (other is! QaddyTypography) {
      return this;
    }
    return QaddyTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      h4: TextStyle.lerp(h4, other.h4, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      small: TextStyle.lerp(small, other.small, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      navigation: TextStyle.lerp(navigation, other.navigation, t)!,
      statLarge: TextStyle.lerp(statLarge, other.statLarge, t)!,
      statHoleNumber: TextStyle.lerp(statHoleNumber, other.statHoleNumber, t)!,
      statHandicap: TextStyle.lerp(statHandicap, other.statHandicap, t)!,
      statScore: TextStyle.lerp(statScore, other.statScore, t)!,
      statDistance: TextStyle.lerp(statDistance, other.statDistance, t)!,
      statDistanceLong: TextStyle.lerp(
        statDistanceLong,
        other.statDistanceLong,
        t,
      )!,
    );
  }
}
