/// Qaddy's full-screen loader.
///
/// See `docs/sprints/sprint-01-3-shared-components.md`'s "`FullScreenLoader`"
/// section: a single generic component showing the Qaddy logo and a loading
/// indicator, with the message supplied by the caller rather than
/// hardcoded — the asset's own example message ("Getting your round
/// ready…") belongs to a future Rounds feature and is not implemented here.
///
/// The "logo" is rendered as the Qaddy wordmark in styled text rather than
/// a bundled image asset, to avoid an unrequested `pubspec.yaml`/asset-
/// registration change for this sprint — see the Sprint 1.3 report.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/loaders/qaddy_circular_loader.dart';

/// Qaddy's full-screen loading overlay: logo, indicator, and a
/// caller-supplied message.
class QaddyFullScreenLoader extends StatelessWidget {
  const QaddyFullScreenLoader({required this.message, super.key});

  /// The message shown beneath the loading indicator. Required — this
  /// component never hardcodes its own copy.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return ColoredBox(
      color: colours.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Qaddy', style: typography.h1.copyWith(color: colours.gold)),
            SizedBox(height: spacing.xxl),
            const QaddyCircularLoader(size: 40),
            SizedBox(height: spacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
