/// The picture of the hole, as the approved Live Scoring mockup draws it: a
/// tall aerial view with the hole's length in a frosted card at the top left
/// and the side game, if there is one, at the bottom.
///
/// The aerial is a `QaddyMediaPlaceholder` until real hole imagery exists (see
/// `docs/design/asset-register.md`), 290 tall as the mockup's is. No distance
/// is invented: only the hole's own length is shown, and wind, GPS, the course
/// map and the flyover are not drawn because nothing is behind them.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';
import 'package:qaddy/features/rounds/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// The hole view for [hole].
class HoleView extends StatelessWidget {
  const HoleView({required this.hole, this.greeting, super.key});

  /// The hole being played.
  final CourseHole hole;

  /// A friendly line over the picture: on the first tee, "Enjoy it out
  /// there."
  final String? greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final onImage = theme.colorScheme.onPrimary;
    final shape = BorderRadius.circular(radius.medium);
    final sideGames = <SideGame>[
      for (final game in upcomingRoundSideGames)
        if (game.hole == hole.number) game,
    ];

    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          QaddyMediaPlaceholder(borderRadius: shape, aerial: true),
          Padding(
            padding: EdgeInsets.all(spacing.md - 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (hole.metres != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius.medium - 4),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colours.backgroundBase.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(
                            radius.medium - 4,
                          ),
                          border: Border.all(
                            color: onImage.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Length',
                              style: QaddyText.weatherPlace.copyWith(
                                color: onImage.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              '${hole.metres} m',
                              style: QaddyText.timeFigure.copyWith(
                                color: onImage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (greeting != null)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: sideGames.isNotEmpty ? spacing.sm : 0,
                    ),
                    child: QaddyInfoChip(
                      icon: Icons.waving_hand_outlined,
                      text: greeting!,
                    ),
                  ),
                if (sideGames.isNotEmpty)
                  QaddyInfoChip(
                    icon: Icons.flag_outlined,
                    text: '${sideGames.first.name} on this hole',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
