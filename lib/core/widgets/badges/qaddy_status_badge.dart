/// Qaddy's status badge — a small, pill-shaped status indicator.
///
/// See `design/ui-components/badges/badges-library-v1.png`'s "Status
/// Pills" category (a filled, coloured pill) and `qaddy_radius.dart`'s
/// `pill` token, documented there for exactly this purpose ("fully-rounded
/// status pills"). `tone` maps 1:1 onto `QaddyColours`' existing Semantic
/// Colours and `premium` field — no new colour is introduced. The
/// foreground reuses `ColorScheme.onPrimary`, already the theme's
/// documented "white text on a coloured button/badge surface" pairing (see
/// `qaddy_theme.dart`), so every tone stays theme-correct without a
/// dedicated "on-colour" token per tone.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// The semantic tone of a [QaddyStatusBadge], mirroring `QaddyColours`'
/// Semantic Colours (plus `premium`).
enum QaddyStatusBadgeTone { info, success, warning, error, premium }

/// A small, filled, pill-shaped label communicating a status at a glance
/// (e.g. a round's "Upcoming" status).
class QaddyStatusBadge extends StatelessWidget {
  const QaddyStatusBadge({
    required this.label,
    this.tone = QaddyStatusBadgeTone.info,
    super.key,
  });

  /// The badge's text (e.g. "Upcoming").
  final String label;

  /// Which semantic colour the badge is filled with.
  final QaddyStatusBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final background = switch (tone) {
      QaddyStatusBadgeTone.info => colours.info,
      QaddyStatusBadgeTone.success => colours.success,
      QaddyStatusBadgeTone.warning => colours.warning,
      QaddyStatusBadgeTone.error => colours.error,
      QaddyStatusBadgeTone.premium => colours.premium,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
