/// Qaddy's Profile screen — the golfer's own player card.
///
/// It is about *me*: my face and handicap, what my rounds say, the
/// achievements I have earned and the one I am chasing, the mates I play with
/// and my recent rounds. Everything on it comes from rounds actually played;
/// where there are none yet it says so and offers the first tee. See
/// `docs/features/profile-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/golfer.dart';
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/actions/qaddy_quick_actions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/achievements/logic/achievements.dart';
import 'package:qaddy/features/achievements/ui/widgets/achievement_shelf.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/profile/ui/widgets/player_card.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/logic/stats_story.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

/// The Profile destination (route `/profile`).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    final golfer = ref.watch(golferDetailsProvider);
    final history = ref.watch(roundHistoryProvider);
    final stats = CareerStats.of(history, you: currentUserName);
    final achievements = achievementsFor(stats);
    final earned = achievements.where((a) => a.unlocked).length;

    final friends = ref.watch(confirmedFriendsProvider).length;
    final trips =
        ref.watch(upcomingTripsProvider).length +
        ref.watch(pastTripsProvider).length;

    final shortcuts = <QaddyQuickAction>[
      QaddyQuickAction(
        icon: Icons.bar_chart_rounded,
        label: 'My stats',
        colour: colours.accentOrange,
        onTap: () => context.push(AppRoutes.profileStatistics),
      ),
      QaddyQuickAction(
        icon: Icons.sports_golf,
        label: 'Golf bag',
        colour: colours.accentTeal,
        onTap: () => context.push(AppRoutes.profileGolfBag),
      ),
      QaddyQuickAction(
        icon: Icons.settings_outlined,
        label: 'Settings',
        colour: colours.accentSky,
        onTap: () => context.push(AppRoutes.profileSettings),
      ),
    ];

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            PlayerCard(
              golfer: golfer,
              stats: stats,
              onOpenStats: () => context.push(AppRoutes.profileStatistics),
              onStartRound: () => context.go(AppRoutes.rounds),
              onShare: () => shareOrCopy(
                context,
                ref,
                text: _cardMessage(golfer, stats),
                subject: '${golfer.firstName} on Qaddy',
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddyQuickActions(actions: shortcuts),
            SizedBox(height: spacing.sectionGap),
            QaddySectionHeading(title: 'Achievements', badge: earned),
            SizedBox(height: spacing.md),
            AchievementShelf(achievements: achievements),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Your world'),
            SizedBox(height: spacing.md),
            _World(friends: friends, groups: groups.length, trips: trips),
            if (stats != null && stats.rivals.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Your playing partners'),
              SizedBox(height: spacing.md),
              _Partners(rivals: stats.rivals.take(4).toList()),
            ],
            if (stats != null) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Recent rounds'),
              SizedBox(height: spacing.md),
              _RecentRounds(
                rounds: stats.chronological.reversed.take(3).toList(),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// The message shared with "Share my golf card".
String _cardMessage(GolferProfile golfer, CareerStats? stats) {
  final handicap = golfer.handicap;
  final facts = <String>[
    if (handicap != null) 'handicap ${handicapLabel(handicap)}',
    if (golfer.homeCourse != null) 'plays at ${golfer.homeCourse}',
  ].join(' · ');
  if (stats == null) {
    return '${golfer.firstName}${facts.isEmpty ? '' : ': $facts'}. '
        'See you on the first tee. Played with Qaddy.';
  }
  final lead = handicap == null
      ? golfer.firstName
      : '${golfer.firstName}: handicap ${handicapLabel(handicap)}';
  return '$lead · '
      '${roundsLabel(stats.rounds)} · ${stats.wins} '
      '${stats.wins == 1 ? 'win' : 'wins'} · '
      '${stats.averagePoints.round()} points a round. Played with Qaddy.';
}

/// Friends, groups and trips as three tiles, each leading to its home.
class _World extends StatelessWidget {
  const _World({
    required this.friends,
    required this.groups,
    required this.trips,
  });

  final int friends;
  final int groups;
  final int trips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    Widget tile(
      IconData icon,
      Color colour,
      int count,
      String label,
      String to,
    ) => Expanded(
      child: Semantics(
        button: true,
        label: '$count $label',
        excludeSemantics: true,
        onTap: () => context.go(to),
        child: QaddyCard(
          onTap: () => context.go(to),
          child: Column(
            children: <Widget>[
              QaddyIconBadge(icon: icon, colour: colour),
              SizedBox(height: spacing.sm),
              Text(
                '$count',
                style: typography.h2.copyWith(color: colours.textPrimary),
              ),
              Text(
                label,
                style: typography.small.copyWith(color: colours.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );

    return Row(
      children: <Widget>[
        tile(
          Icons.people,
          colours.accentPink,
          friends,
          'Friends',
          AppRoutes.friends,
        ),
        SizedBox(width: spacing.cardGap),
        tile(
          Icons.groups,
          colours.accentIndigo,
          groups,
          'Groups',
          AppRoutes.friendsGroups,
        ),
        SizedBox(width: spacing.cardGap),
        tile(Icons.luggage, colours.accentSky, trips, 'Trips', AppRoutes.trips),
      ],
    );
  }
}

/// The people the golfer plays with most, from their real rounds.
class _Partners extends StatelessWidget {
  const _Partners({required this.rivals});

  final List<Rival> rivals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final spoken = rivals
        .map((r) => '${r.name}, ${roundsLabel(r.together)}')
        .join('. ');

    return Semantics(
      button: true,
      onTap: () => context.push(AppRoutes.profileStatistics),
      excludeSemantics: true,
      label: 'Your playing partners: $spoken. Opens your head to head.',
      child: QaddyCard(
        onTap: () => context.push(AppRoutes.profileStatistics),
        child: Row(
          children: <Widget>[
            for (final rival in rivals)
              Expanded(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: FittedBox(child: QaddyAvatar(name: rival.name)),
                    ),
                    SizedBox(height: spacing.sm),
                    Text(
                      rival.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.small.copyWith(
                        color: colours.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      roundsLabel(rival.together),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.caption.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The last few rounds, newest first.
class _RecentRounds extends StatelessWidget {
  const _RecentRounds({required this.rounds});

  final List<YourRound> rounds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      onTap: () => context.push(AppRoutes.profileStatistics),
      child: Column(
        children: <Widget>[
          for (final (index, round) in rounds.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                QaddyIconBadge(
                  icon: round.won ? Icons.emoji_events : Icons.golf_course,
                  colour: round.won ? colours.gold : colours.accentTeal,
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        round.won
                            ? 'Won at ${round.round.course}'
                            : '${round.standing.position} at '
                                  '${round.round.course}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${round.points} pts · '
                        '${round.date.day} ${round.date.monthAbbreviation}',
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
