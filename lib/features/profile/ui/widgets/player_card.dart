/// The golfer's player card: their face, handicap, home course and, once they
/// have played, what their rounds say — with one gold button to share it or,
/// before the first round, to start one.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/text/qaddy_eyebrow.dart';
import 'package:qaddy/features/profile/models/profile.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/logic/stats_story.dart';

/// The Profile hero card.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    required this.profile,
    required this.stats,
    required this.onShare,
    required this.onStartRound,
    required this.onOpenStats,
    super.key,
  });

  /// Who the card is about.
  final Profile profile;

  /// What their finished rounds say, or `null` before the first one.
  final CareerStats? stats;

  /// Shares the card.
  final VoidCallback onShare;

  /// Starts a round (offered before the first one).
  final VoidCallback onStartRound;

  /// Opens the full statistics.
  final VoidCallback onOpenStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final muted = onGradient.withValues(alpha: 0.85);
    final career = stats;

    Widget figure(String value, String label) => Expanded(
      child: Column(
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: typography.h1.copyWith(color: onGradient),
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: typography.caption.copyWith(color: muted),
          ),
        ],
      ),
    );

    return QaddyHeroCard(
      gradient: colours.gradientGreen,
      onTap: career == null ? null : onOpenStats,
      semanticLabel: career == null
          ? null
          : '${profile.displayName}. Handicap '
                '${profile.handicap.toStringAsFixed(1)}. '
                '${roundsLabel(career.rounds)}, ${career.wins} wins, '
                '${career.averagePoints.round()} points a round. '
                'Opens your statistics.',
      footer: career == null
          ? QaddyGoldButton(
              label: 'Start your first round',
              icon: Icons.sports_golf,
              tall: true,
              onPressed: onStartRound,
            )
          : QaddyGoldButton(
              label: 'Share my golf card',
              icon: Icons.ios_share_rounded,
              tall: true,
              onPressed: onShare,
            ),
      child: Column(
        children: <Widget>[
          const QaddyEyebrow('PLAYER CARD'),
          SizedBox(height: spacing.lg),
          Container(
            width: 104,
            height: 104,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colours.gold, width: 3),
            ),
            child: FittedBox(child: QaddyAvatar(name: profile.displayName)),
          ),
          SizedBox(height: spacing.md),
          Text(
            profile.displayName,
            textAlign: TextAlign.center,
            style: typography.h1.copyWith(color: onGradient),
          ),
          SizedBox(height: spacing.xs),
          Text(
            '${profile.homeCourse} · ${profile.location}',
            textAlign: TextAlign.center,
            style: typography.body.copyWith(color: muted),
          ),
          SizedBox(height: spacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: <Widget>[
              QaddyInfoChip(
                icon: Icons.speed_outlined,
                text: 'Handicap ${profile.handicap.toStringAsFixed(1)}',
              ),
              QaddyInfoChip(
                icon: Icons.calendar_today_outlined,
                text: 'Since ${profile.joinedDate.year}',
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          if (career == null)
            Text(
              'Play a round and this card fills with your game.',
              textAlign: TextAlign.center,
              style: typography.body.copyWith(color: muted),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                figure('${career.rounds}', 'Rounds'),
                figure('${career.wins}', career.wins == 1 ? 'Win' : 'Wins'),
                figure('${career.averagePoints.round()}', 'Avg points'),
              ],
            ),
        ],
      ),
    );
  }
}
