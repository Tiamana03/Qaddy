/// Increase/decrease control for a hole's current score.
///
/// See `docs/sprints/sprint-02-03-live-scoring.md`'s "Score Entry" section
/// ("Score cannot be lower than 1") and "Layout" section ("Desktop: ...
/// Large score controls"). Decrement/increment reuse `QaddyIconButton`,
/// which already satisfies this sprint's 48px touch-target requirement.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/responsive/responsive_extensions.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_icon_button.dart';

/// A large +/- control for entering a hole's gross score.
class ScoreStepper extends StatelessWidget {
  const ScoreStepper({
    required this.score,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  /// The current score.
  final int score;

  /// Called when the increment control is tapped.
  final VoidCallback onIncrement;

  /// Called when the decrement control is tapped. `null` when [score] is
  /// already at the floor of 1, rendering the control disabled.
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    // "Large score controls" on desktop reuses `statLarge` in place of
    // `statScore` — both already-documented tokens, just a bigger one.
    final scoreStyle = context.isDesktop
        ? typography.statLarge
        : typography.statScore;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        QaddyIconButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          semanticLabel: 'Decrease score',
        ),
        SizedBox(width: spacing.xl),
        Text('$score', style: scoreStyle.copyWith(color: colours.textPrimary)),
        SizedBox(width: spacing.xl),
        QaddyIconButton(
          icon: Icons.add,
          onPressed: onIncrement,
          semanticLabel: 'Increase score',
        ),
      ],
    );
  }
}
