/// The next round on the calendar, as an invitation: when, where, who is
/// playing and one tap to rally the group.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_shadows.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';

/// A full-width card for a group's upcoming round. Tapping the story opens
/// the group; the button sends the "who's in?" message to the group.
class NextRoundBanner extends StatelessWidget {
  const NextRoundBanner({
    required this.groupName,
    required this.round,
    required this.players,
    required this.onOpen,
    required this.onRally,
    super.key,
  });

  /// The group playing, e.g. "Saturday Boys".
  final String groupName;

  /// The round to show.
  final GroupUpcomingRound round;

  /// Names of the golfers to show faces for, the golfer first.
  final List<String> players;

  /// Opens the group.
  final VoidCallback onOpen;

  /// Sends the "who's in?" message.
  final VoidCallback onRally;

  /// How many faces are shown before "+N".
  static const int _faces = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final shadows = theme.extension<QaddyShadows>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.82);
    final borderRadius = BorderRadius.circular(radius.extraLarge);

    final shown = players.take(_faces).toList();
    final more = round.players - shown.length;

    // Faces overlap by a third, each ringed in the card's own colour so they
    // read as a huddle rather than a row of stickers.
    const size = 36.0;
    const step = 26.0;
    final huddle = SizedBox(
      width: size + step * (shown.length - 1),
      height: size,
      child: Stack(
        children: <Widget>[
          for (final (index, name) in shown.indexed)
            Positioned(
              left: step * index,
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colours.backgroundBase,
                ),
                child: FittedBox(child: QaddyAvatar(name: name)),
              ),
            ),
        ],
      ),
    );

    final story = Semantics(
      button: true,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          'Next round for $groupName: ${round.date} at ${round.teeTime}, '
          '${round.course}. ${round.competition}. '
          '${round.players} playing.',
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.xl,
            spacing.xl,
            spacing.xl,
            spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'NEXT ROUND · ${groupName.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.caption.copyWith(
                  color: colours.gold,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: spacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${round.date}, ${round.teeTime}',
                  style: typography.h1.copyWith(color: onGradient),
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                '${round.course} · ${round.competition}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.body.copyWith(color: muted),
              ),
              SizedBox(height: spacing.lg),
              Row(
                children: <Widget>[
                  huddle,
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      more > 0
                          ? '+$more more · ${round.players} playing'
                          : '${round.players} playing',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.small.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows.large,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: colours.gradientGreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                story,
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.xl,
                    0,
                    spacing.xl,
                    spacing.xl,
                  ),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colours.gold,
                      foregroundColor: colours.backgroundBase,
                      minimumSize: Size.fromHeight(spacing.display),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius.medium),
                      ),
                    ),
                    onPressed: onRally,
                    icon: const Icon(Icons.campaign_rounded, size: 20),
                    label: Text(
                      "Who's in? Rally the group",
                      overflow: TextOverflow.ellipsis,
                      style: typography.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
