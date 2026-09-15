/// Placeholder screen for the Rounds destination.
///
/// Sprint 1.2 builds navigation only — real rounds content lands in a
/// later milestone. See `docs/architecture/navigation.md`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Placeholder for the Rounds destination (route `/rounds`).
class RoundsScreen extends StatelessWidget {
  const RoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Scaffold(
      backgroundColor: colours.background,
      body: Center(
        child: Text(
          'Rounds',
          style: typography.h1.copyWith(color: colours.textPrimary),
        ),
      ),
    );
  }
}
