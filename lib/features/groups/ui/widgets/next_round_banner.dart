/// The next round on the calendar, as an invitation: when, where, who is
/// playing and one tap to rally the group.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar_huddle.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.82);

    return QaddyHeroCard(
      gradient: colours.gradientGreen,
      onTap: onOpen,
      semanticLabel:
          'Next round for $groupName: ${round.date} at ${round.teeTime}, '
          '${round.course}. ${round.competition}. '
          '${round.players} playing.',
      footer: QaddyGoldButton(
        label: "Who's in? Rally the group",
        icon: Icons.campaign_rounded,
        onPressed: onRally,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          QaddyEyebrow('Sample round · $groupName', maxLines: 1),
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
          QaddyAvatarHuddle(
            names: players,
            total: round.players,
            textColour: muted,
          ),
        ],
      ),
    );
  }
}
