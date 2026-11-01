/// Your clubs: the groups you play with, each with its own crest and the one
/// thing worth knowing about it right now.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/groups/models/group.dart';

/// What a club card says beyond its name.
class ClubPreview {
  const ClubPreview({required this.group, this.nextRound});

  /// The group.
  final Group group;

  /// The next round, e.g. "Saturday · 8:20 AM at Richmond Golf Club".
  final String? nextRound;
}

/// A horizontal strip of club cards.
class ClubsStrip extends StatelessWidget {
  const ClubsStrip({required this.clubs, required this.onOpen, super.key});

  /// The clubs to show.
  final List<ClubPreview> clubs;

  /// Called with the club that was tapped.
  final ValueChanged<Group> onOpen;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: clubs.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing.cardGap),
        itemBuilder: (context, index) => QaddyFadeSlideIn(
          offset: 10,
          delay: staggerDelay(index, stepMs: 60),
          child: _ClubCard(
            club: clubs[index],
            index: index,
            onTap: () => onOpen(clubs[index].group),
          ),
        ),
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({
    required this.club,
    required this.index,
    required this.onTap,
  });

  final ClubPreview club;

  /// The club's place in the strip, which decides its colour.
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final group = club.group;
    final line = groupLine(group, nextRound: club.nextRound);

    // Each club gets its own colour (by position, so neighbours never match).
    final palette = <Color>[
      colours.accentTeal,
      colours.accentIndigo,
      colours.accentOrange,
      colours.accentPink,
    ];
    final base = palette[index % palette.length];
    final borderRadius = BorderRadius.circular(radius.large);

    return Semantics(
      button: true,
      label: '${group.name}. $line',
      excludeSemantics: true,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadows.medium,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              width: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color.lerp(base, colours.backgroundBase, 0.55)!,
                    Color.lerp(base, colours.backgroundBase, 0.82)!,
                  ],
                ),
              ),
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // The club's crest: its initial on a ring.
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colours.gold, width: 2),
                          color: onGradient.withValues(alpha: 0.10),
                        ),
                        child: Text(
                          group.name.characters.first,
                          style: typography.body.copyWith(
                            color: colours.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        group.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.copyWith(
                          color: onGradient,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        line,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: typography.small.copyWith(
                          color: onGradient.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
