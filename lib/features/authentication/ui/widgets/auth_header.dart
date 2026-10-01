/// The Qaddy wordmark + subtitle header shared by Login and Sign Up.
///
/// See `docs/architecture/authentication-engineering-decisions.md`'s "Login
/// and Sign Up Are Two Screens, Not One Screen With a Toggle" — extracted
/// so this treatment is written once rather than duplicated across both
/// screens that need it.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// The Qaddy wordmark with a screen-specific subtitle beneath it.
class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.subtitle, super.key});

  /// Short text beneath the wordmark (e.g. "Sign in to continue").
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Column(
      children: <Widget>[
        Text(
          'Qaddy',
          textAlign: TextAlign.center,
          style: typography.h1.copyWith(color: colours.gold),
        ),
        SizedBox(height: spacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: typography.body.copyWith(color: colours.textSecondary),
        ),
      ],
    );
  }
}
