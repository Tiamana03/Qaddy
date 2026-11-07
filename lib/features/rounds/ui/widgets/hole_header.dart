/// The hole you are standing on, as the approved Live Scoring mockup draws it:
/// "Hole 4" large, "Par 4 | 380 m | SI 10" beneath it, and which nine it is on
/// the right. No card: it reads at arm's length because it is the biggest
/// thing on the screen.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/features/rounds/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// The header for [hole] of [total] holes.
class HoleHeader extends StatelessWidget {
  const HoleHeader({
    required this.hole,
    required this.total,
    this.greeting,
    super.key,
  });

  /// The hole being played.
  final CourseHole hole;

  /// How many holes the round has.
  final int total;

  /// A friendly line under the details — on the first tee, "Enjoy it out
  /// there."
  final String? greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final nine = hole.number <= total ~/ 2 ? 'Front nine' : 'Back nine';
    final details = <String>[
      'Par ${hole.par}',
      if (hole.metres != null) '${hole.metres} m',
      'SI ${hole.strokeIndex}',
    ].join('  |  ');
    final sideGames = <SideGame>[
      for (final game in upcomingRoundSideGames)
        if (game.hole == hole.number) game,
    ];
    final sideGame = sideGames.isEmpty
        ? ''
        : ' ${sideGames.first.name} is played here.';

    return Semantics(
      container: true,
      label:
          'Hole ${hole.number} of $total. Par ${hole.par}. '
          '${hole.metres == null ? '' : '${hole.metres} metres. '}'
          'Stroke index ${hole.strokeIndex}. $nine.'
          '$sideGame',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedSwitcher(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : QaddyMotion.standard.normal,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[...previous, ?current],
                        ),
                        child: Text(
                          'Hole ${hole.number}',
                          key: ValueKey<int>(hole.number),
                          style: typography.h1.copyWith(
                            color: colours.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.bodyLarge.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.md),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colours.card,
                    borderRadius: BorderRadius.circular(radius.large),
                    border: Border.all(color: colours.border),
                  ),
                  child: Text(
                    nine,
                    style: typography.small.copyWith(
                      color: colours.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (greeting != null) ...<Widget>[
              SizedBox(height: spacing.md),
              Text(
                greeting!,
                style: typography.body.copyWith(
                  color: colours.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
