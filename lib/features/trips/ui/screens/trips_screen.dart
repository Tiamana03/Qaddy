/// Placeholder screen for the Trips destination.
///
/// Sprint 1.2 builds navigation only — real trips content lands in a
/// later milestone. See `docs/architecture/navigation.md`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// Placeholder for the Trips destination (route `/trips`).
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Scaffold(
      backgroundColor: colours.background,
      body: Center(
        child: Text(
          'Trips',
          style: typography.h1.copyWith(color: colours.textPrimary),
        ),
      ),
    );
  }
}
