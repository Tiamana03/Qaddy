/// Placeholder screen for the Trips destination.
///
/// Uses `QaddyScaffold` for consistent layout and responsive behaviour —
/// see `docs/sprints/sprint-01-5-foundation-integration.md`. Real trips
/// content lands in a later milestone; see `docs/architecture/navigation.md`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';

/// Placeholder for the Trips destination (route `/trips`).
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyScaffold(
      body: Center(
        child: Text(
          'Trips',
          style: typography.h1.copyWith(color: colours.textPrimary),
        ),
      ),
    );
  }
}
