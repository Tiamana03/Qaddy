/// Qaddy's placeholder avatar — initials on a coloured circle.
///
/// See `design/ui-components/avatars/avatars-library-v1.png`'s "Initials
/// Avatars" panel ("Auto-generated from user's name") and its "Basic
/// Avatars" size scale (MD = 48px) — `spacing.display` (48, also
/// `iconButtonSize`) is used, which doubles as this sprint's minimum touch
/// target. `docs/standards/placeholder-data.md`'s "Placeholder Images"
/// section documents initials as the standard stand-in until real profile
/// photos exist.
///
/// The background colour is chosen deterministically from `name` using
/// `QaddyColours`' accent fields — purely decorative variety between
/// avatars, distinct from the semantic success/warning/error/info/premium
/// colours already used elsewhere (e.g. status badges) so the two never
/// carry conflicting meaning on the same card. The foreground reuses
/// `ColorScheme.onPrimary`, the theme's documented "white text on a
/// coloured button/badge surface" pairing (see `qaddy_theme.dart`).
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A circular, initials-based placeholder avatar.
class QaddyAvatar extends StatelessWidget {
  const QaddyAvatar({required this.name, super.key});

  /// The person's name — used to derive initials and a stable background
  /// colour.
  final String name;

  static String _initialsFor(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '';
    }
    if (words.length == 1) {
      final word = words.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return (words.first[0] + words.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final palette = <Color>[
      colours.accentTeal,
      colours.accentSky,
      colours.accentPink,
      colours.accentOrange,
      colours.accentIndigo,
    ];
    final background = palette[name.hashCode.abs() % palette.length];

    return Container(
      width: spacing.display,
      height: spacing.display,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _initialsFor(name),
        style: typography.small.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
