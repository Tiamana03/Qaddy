/// The hole you are standing on, as the approved Live Scoring mockup draws it:
/// "Hole 4" large, "Par 4 | 380 m | SI 10" beneath it and, at the right, the
/// pill that takes you to the next hole. No card: it reads at arm's length
/// because it is the biggest thing on the screen.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_secondary_button.dart';
import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// The header for [hole] of [total] holes.
class HoleHeader extends StatelessWidget {
  const HoleHeader({
    required this.hole,
    required this.total,
    this.onNext,
    super.key,
  });

  /// The hole being played.
  final CourseHole hole;

  /// How many holes the round has.
  final int total;

  /// Goes to the next hole. Omit on the last hole: the pill is not drawn.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    final nine = hole.number <= total ~/ 2 ? 'Front nine' : 'Back nine';
    final facts = <String>[
      'Par ${hole.par}',
      if (hole.metres != null) '${hole.metres} m',
      'SI ${hole.strokeIndex}',
    ];
    final sideGames = <SideGame>[
      for (final game in upcomingRoundSideGames)
        if (game.hole == hole.number) game,
    ];
    final sideGame = sideGames.isEmpty
        ? ''
        : ' ${sideGames.first.name} is played here.';

    Widget divider() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Container(width: 1, height: 14, color: colours.border),
    );

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
                          style: QaddyText.holeTitle.copyWith(
                            color: colours.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Row(
                        children: <Widget>[
                          for (final (index, fact)
                              in facts.indexed) ...<Widget>[
                            if (index > 0) divider(),
                            Flexible(
                              child: Text(
                                fact,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: QaddyText.holeMeta.copyWith(
                                  color: colours.textPrimary.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (onNext != null) ...<Widget>[
                  SizedBox(width: spacing.md),
                  SizedBox(
                    width: 118,
                    child: QaddySecondaryButton(
                      label: 'Next hole',
                      icon: Icons.chevron_right_rounded,
                      compact: true,
                      height: 40,
                      onPressed: onNext,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
