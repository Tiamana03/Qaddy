/// A circular progress ring with a centred label, used for "planning
/// progress" on the Planning screen and the trip hero card.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A ring filled to [progress] (0–1). The [label] sits in the middle and
/// [semanticLabel] is what a screen reader hears instead of the ring.
class PlanningRing extends StatelessWidget {
  const PlanningRing({
    required this.progress,
    required this.label,
    required this.semanticLabel,
    this.size = 64,
    this.trackColour,
    this.progressColour,
    this.labelColour,
    super.key,
  });

  /// How full the ring is, from 0 to 1.
  final double progress;

  /// The centre text (e.g. "50%").
  final String label;

  /// What the ring means, for screen readers.
  final String semanticLabel;

  /// The ring's diameter.
  final double size;

  /// The unfilled part (defaults to a quiet surface tone).
  final Color? trackColour;

  /// The filled part (defaults to the readable accent).
  final Color? progressColour;

  /// The centre text colour (defaults to primary text).
  final Color? labelColour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress.clamp(0, 1)),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: size / 9,
                strokeCap: StrokeCap.round,
                backgroundColor: trackColour ?? colours.surface2,
                color: progressColour ?? colours.accent,
              ),
            ),
            Center(
              child: Text(
                label,
                style: typography.small.copyWith(
                  color: labelColour ?? colours.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
