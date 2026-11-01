/// The hole you are standing on: its number, par, length and difficulty — and
/// the side game, if there is one — on a card you can read at arm's length.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/rounds/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// The banner for [hole] of [total] holes.
class HoleBanner extends StatelessWidget {
  const HoleBanner({required this.hole, required this.total, super.key});

  /// The hole being played.
  final CourseHole hole;

  /// How many holes the round has.
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;

    final nine = hole.number <= total ~/ 2 ? 'FRONT NINE' : 'BACK NINE';
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
          '${hole.metres} metres. Stroke index ${hole.strokeIndex}.'
          '$sideGame',
      child: ExcludeSemantics(
        child: QaddyHeroCard(
          gradient: colours.gradientGreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              QaddyEyebrow('$nine · HOLE ${hole.number} OF $total'),
              SizedBox(height: spacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      '${hole.number}',
                      key: ValueKey<int>(hole.number),
                      style: typography.display.copyWith(
                        color: colours.gold,
                        fontSize: 72,
                        height: 1,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.lg),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: spacing.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Par ${hole.par}',
                            style: typography.h2.copyWith(color: onGradient),
                          ),
                          SizedBox(height: spacing.xs),
                          Text(
                            '${hole.metres} m · SI ${hole.strokeIndex}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.copyWith(
                              color: onGradient.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (sideGames.isNotEmpty) ...<Widget>[
                SizedBox(height: spacing.md),
                QaddyInfoChip(
                  icon: Icons.flag_outlined,
                  text: '${sideGames.first.name} on this hole',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
