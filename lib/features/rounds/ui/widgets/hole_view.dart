/// The picture of the hole, as the approved Live Scoring mockup draws it: a
/// wide aerial view with the distance in a frosted card and the side game, if
/// there is one, laid over it.
///
/// The aerial is a `QaddyMediaPlaceholder` until real hole imagery exists (see
/// `docs/design/asset-register.md`). No distance is invented: only the hole's
/// own length is shown, and wind, GPS and the course map are not drawn at all.
library;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';
import 'package:qaddy/features/rounds/models/course_hole.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';

/// The hole view for [hole].
class HoleView extends StatelessWidget {
  const HoleView({required this.hole, super.key});

  /// The hole being played.
  final CourseHole hole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onImage = theme.colorScheme.onPrimary;
    final shape = BorderRadius.circular(radius.large);
    final sideGames = <SideGame>[
      for (final game in upcomingRoundSideGames)
        if (game.hole == hole.number) game,
    ];

    return SizedBox(
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          QaddyMediaPlaceholder(borderRadius: shape, tone: hole.number % 3),
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (hole.metres != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius.medium),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colours.backgroundBase.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(radius.medium),
                          border: Border.all(
                            color: onImage.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Length',
                              style: typography.caption.copyWith(
                                color: onImage.withValues(alpha: 0.85),
                              ),
                            ),
                            Text(
                              '${hole.metres} m',
                              style: typography.h4.copyWith(
                                color: onImage,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
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
