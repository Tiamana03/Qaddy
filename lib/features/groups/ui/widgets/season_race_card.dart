/// The season race: a podium of the group's top three, and where the golfer
/// stands against the mate just ahead of them.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';

/// A card showing the season's podium. Tapping it (when [onOpen] is given)
/// opens the group.
class SeasonRaceCard extends StatelessWidget {
  const SeasonRaceCard({
    required this.race,
    required this.groupName,
    required this.yourName,
    this.onOpen,
    this.roundsPlayed,
    this.roundsTotal,
    super.key,
  });

  /// The standings to show.
  final SeasonRace race;

  /// The group racing, e.g. "Saturday Boys".
  final String groupName;

  /// The golfer's own name, to pick them out on the podium.
  final String yourName;

  /// Opens the group's full leaderboard. Omit on the group's own page, where
  /// the card is already the table.
  final VoidCallback? onOpen;

  /// How many rounds of the season are done, for the progress line.
  final int? roundsPlayed;

  /// How many rounds the season has in all.
  final int? roundsTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final podium = race.podium;
    final chase = race.chase;

    // Second place stands on the left, first in the middle, third on the
    // right — the way a podium is built.
    final order = <int>[1, 0, 2].where((i) => i < podium.length).toList();

    final summary =
        '${race.headline}${chase == null ? '' : ', $chase'}. '
        '${race.roundsLeft}.';

    return Semantics(
      button: onOpen != null,
      onTap: onOpen,
      excludeSemantics: true,
      label:
          'Season race for $groupName. '
          '${podium.map((e) => '${ordinal(e.rank)} ${e.player}, '
              '${e.points} points').join('. ')}. $summary',
      child: QaddyCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(child: QaddyEyebrow('SEASON RACE')),
                Text(
                  race.roundsLeft,
                  style: typography.small.copyWith(
                    color: colours.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            SizedBox(
              height: 224,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (final index in order)
                    Expanded(
                      child: _PodiumPlace(
                        entry: podium[index],
                        isYou: podium[index].player == yourName,
                      ),
                    ),
                ],
              ),
            ),
            if (roundsPlayed != null && roundsTotal != null) ...<Widget>[
              SizedBox(height: spacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  theme.extension<QaddyRadius>()!.large,
                ),
                child: LinearProgressIndicator(
                  value: roundsTotal == 0 ? 0 : roundsPlayed! / roundsTotal!,
                  minHeight: 6,
                  backgroundColor: colours.surface2,
                  valueColor: AlwaysStoppedAnimation<Color>(colours.gold),
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                '$roundsPlayed of $roundsTotal rounds played',
                style: typography.caption.copyWith(
                  color: colours.textSecondary,
                ),
              ),
            ],
            SizedBox(height: spacing.lg),
            Text(
              race.headline,
              style: typography.h3.copyWith(color: colours.textPrimary),
            ),
            if (chase != null) ...<Widget>[
              SizedBox(height: spacing.xs),
              Text(
                chase,
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.entry, required this.isYou});

  final GroupLeaderboardEntry entry;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final (barHeight, barColour) = switch (entry.rank) {
      1 => (84.0, colours.gold),
      2 => (60.0, colours.textSecondary),
      _ => (40.0, colours.accentOrange),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            '${(entry.points * t).round()}',
            style: typography.h3.copyWith(
              color: colours.textPrimary,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: spacing.sm),
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isYou ? colours.gold : colours.border,
                width: isYou ? 2.5 : 1.5,
              ),
            ),
            child: FittedBox(child: QaddyAvatar(name: entry.player)),
          ),
          SizedBox(height: spacing.xs),
          Text(
            isYou ? 'You' : entry.player,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.small.copyWith(
              color: isYou ? colours.gold : colours.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.sm),
          Container(
            height: barHeight * t,
            margin: EdgeInsets.symmetric(horizontal: spacing.xs),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: barColour.withValues(alpha: 0.22),
              border: Border(top: BorderSide(color: barColour, width: 3)),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(radius.medium),
              ),
            ),
            child: barHeight * t > 28
                ? Padding(
                    padding: EdgeInsets.only(top: spacing.sm),
                    child: Text(
                      '${entry.rank}',
                      style: typography.h3.copyWith(color: barColour),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
