/// Placeholder screen for the Rounds destination.
///
/// Uses `QaddyScaffold` for consistent layout and responsive behaviour —
/// see `docs/sprints/sprint-01-5-foundation-integration.md`. Real rounds
/// content lands in a later milestone; see `docs/architecture/navigation.md`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';

/// Placeholder for the Rounds destination (route `/rounds`).
class RoundsScreen extends StatelessWidget {
  const RoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyScaffold(
      body: Center(
        child: Text(
          'Rounds',
          style: typography.h1.copyWith(color: colours.textPrimary),
        ),
      ),
    );
  }
}
