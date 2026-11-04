/// The small "Sample" label that marks anything from the Sample Clubhouse: a
/// pretend mate, group, trip or round that is not the golfer's own.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';

/// A quiet pill reading "Sample". [onGradient] makes it readable on a coloured
/// hero rather than on a card.
class SampleBadge extends StatelessWidget {
  const SampleBadge({this.onGradient = false, super.key});

  /// Whether it sits on a coloured hero (light text) rather than a card.
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final colour = onGradient ? theme.colorScheme.onPrimary : colours.accent;

    return Semantics(
      label: 'Sample content',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colour.withValues(alpha: 0.7)),
          ),
          child: Text(
            'Sample',
            style: typography.caption.copyWith(
              color: colour,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
