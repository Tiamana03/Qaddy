/// Qaddy shadow tokens — see `design/design-tokens/shadows.md`.
///
/// No asset defines these values; every field here is an Engineering
/// Decision documented in that file (a soft, steadily-progressing scale).
/// The same values apply in both Light and Dark Mode, so there is a single
/// shared instance: [QaddyShadows.standard].
library;

import 'package:flutter/material.dart';

/// Qaddy's drop-shadow scale, as a [ThemeExtension].
///
/// See `design/design-tokens/shadows.md` for the source of every value.
class QaddyShadows extends ThemeExtension<QaddyShadows> {
  const QaddyShadows({
    required this.none,
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
  });

  /// The single instance used by both `QaddyTheme.light` and
  /// `QaddyTheme.dark` — shadow values do not vary by theme; see
  /// shadows.md's "Dark Mode vs. Light Mode" note.
  static const QaddyShadows standard = QaddyShadows(
    none: <BoxShadow>[],
    small: <BoxShadow>[
      BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        color: Color.fromRGBO(0, 0, 0, 0.12),
      ),
    ],
    medium: <BoxShadow>[
      BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 8,
        color: Color.fromRGBO(0, 0, 0, 0.16),
      ),
    ],
    large: <BoxShadow>[
      BoxShadow(
        offset: Offset(0, 8),
        blurRadius: 16,
        color: Color.fromRGBO(0, 0, 0, 0.20),
      ),
    ],
    extraLarge: <BoxShadow>[
      BoxShadow(
        offset: Offset(0, 16),
        blurRadius: 24,
        color: Color.fromRGBO(0, 0, 0, 0.24),
      ),
    ],
  );

  /// Flat surfaces: the base background, full-bleed content.
  final List<BoxShadow> none;

  /// Buttons.
  final List<BoxShadow> small;

  /// Cards — Qaddy's most common elevated surface.
  final List<BoxShadow> medium;

  /// Dialogs.
  final List<BoxShadow> large;

  /// Floating elements: FABs, bottom sheets.
  final List<BoxShadow> extraLarge;

  @override
  QaddyShadows copyWith({
    List<BoxShadow>? none,
    List<BoxShadow>? small,
    List<BoxShadow>? medium,
    List<BoxShadow>? large,
    List<BoxShadow>? extraLarge,
  }) {
    return QaddyShadows(
      none: none ?? this.none,
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
    );
  }

  @override
  QaddyShadows lerp(ThemeExtension<QaddyShadows>? other, double t) {
    if (other is! QaddyShadows) {
      return this;
    }
    return QaddyShadows(
      none: BoxShadow.lerpList(none, other.none, t) ?? none,
      small: BoxShadow.lerpList(small, other.small, t) ?? small,
      medium: BoxShadow.lerpList(medium, other.medium, t) ?? medium,
      large: BoxShadow.lerpList(large, other.large, t) ?? large,
      extraLarge:
          BoxShadow.lerpList(extraLarge, other.extraLarge, t) ?? extraLarge,
    );
  }
}
