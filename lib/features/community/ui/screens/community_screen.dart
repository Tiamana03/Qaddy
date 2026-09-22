/// Placeholder screen for the Friends destination.
///
/// The route and bottom-nav label are "Friends" (navigation.md); the
/// feature folder is "community" per navigation.md's Route Names vs
/// Feature Folders Engineering Decision — the two are allowed to differ.
/// Uses `QaddyScaffold` for consistent layout and responsive behaviour —
/// see `docs/sprints/sprint-01-5-foundation-integration.md`. Real content
/// lands in a later milestone; see `docs/architecture/navigation.md`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';

/// Placeholder for the Friends destination (route `/friends`).
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyScaffold(
      body: Center(
        child: Text(
          'Friends',
          style: typography.h1.copyWith(color: colours.textPrimary),
        ),
      ),
    );
  }
}
