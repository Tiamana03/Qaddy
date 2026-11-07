/// Qaddy's Profile screen, as the approved mockup draws it: who the golfer is,
/// four headline numbers, the badges they have earned and their recent rounds,
/// with one gold button to the full statistics.
///
/// Everything on it comes from rounds actually played; where there are none yet
/// it says so and offers the first tee. See
/// `docs/features/profile-release-candidate.md`. The mockup's XP journey has no
/// data behind it, so it is not drawn.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
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
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_icon_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_stat_tiles.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/achievements/logic/achievements.dart';
import 'package:qaddy/features/achievements/ui/widgets/achievement_shelf.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';
import 'package:qaddy/features/profile/ui/widgets/edit_profile_sheet.dart';
import 'package:qaddy/features/profile/ui/widgets/profile_header.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/logic/stats_story.dart';
import 'package:qaddy/features/trips/models/trip.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

/// The Profile destination (route `/profile`).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final golfer = ref.watch(golferDetailsProvider);
    final history = ref.watch(roundHistoryProvider);
    final stats = CareerStats.of(history, you: currentUserName);
    final achievements = achievementsFor(stats);
    final earned = achievements.where((a) => a.unlocked).length;
    final unread = ref.watch(unreadNotificationCountProvider);

    // In Release 1 the only mates and groups are the Sample Clubhouse's, so
    // the golfer's own count of them is honestly zero.
    final sampleFriends = ref.watch(confirmedFriendsProvider).length;
    final allTrips = <Trip>[
      ...ref.watch(upcomingTripsProvider),
      ...ref.watch(pastTripsProvider),
    ];
    final sampleTrips = allTrips.where(TripsController.isSample).length;

    final shortcuts = <QaddyQuickAction>[
      QaddyQuickAction(
        icon: Icons.sports_golf,
        featured: true,
        label: 'Golf bag',
        colour: colours.accentTeal,
        onTap: () => context.push(AppRoutes.profileGolfBag),
      ),
      QaddyQuickAction(
        icon: Icons.ios_share_rounded,
        label: 'Share my golf card',
        colour: colours.accentOrange,
        onTap: () => shareOrCopy(
          context,
          ref,
          text: _cardMessage(golfer, stats),
          subject: '${golfer.firstName} on Qaddy',
        ),
      ),
      QaddyQuickAction(
        icon: Icons.bar_chart_rounded,
        label: 'My stats',
        colour: colours.accentSky,
        onTap: () => context.push(AppRoutes.profileStatistics),
      ),
    ];

    Widget action(Widget icon, String tooltip, VoidCallback onTap) => Padding(
      padding: EdgeInsets.only(left: spacing.sm),
      child: QaddyIconButton.custom(
        tooltip: tooltip,
        semanticLabel: tooltip,
        onPressed: onTap,
        child: icon,
      ),
    );

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Profile',
                    style: typography.h1.copyWith(color: colours.textPrimary),
                  ),
                ),
                action(
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      const Icon(Icons.notifications_outlined),
                      if (unread > 0)
                        Positioned(
                          right: -spacing.sm,
                          top: -spacing.sm,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: spacing.lg,
                              minHeight: spacing.lg,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.xs,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colours.gold,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: colours.surface1,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: typography.caption.copyWith(
                                color: colours.backgroundBase,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  unread > 0 ? 'Notifications, $unread new' : 'Notifications',
                  () => context.push(AppRoutes.homeNotifications),
                ),
                action(
                  const Icon(Icons.settings_outlined),
                  'Settings',
                  () => context.push(AppRoutes.profileSettings),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            ProfileHeader(
              golfer: golfer,
              onEdit: () => showEditProfileSheet(context, ref),
            ),
            if (stats != null || golfer.handicap != null) ...<Widget>[
              SizedBox(height: spacing.lg),
              QaddyStatTiles(
                layout: QaddyStatLayout.profile,
                onOpen: () => context.push(AppRoutes.profileStatistics),
                stats: <QaddyStat>[
                  QaddyStat(
                    icon: Icons.speed_outlined,
                    figure: golfer.handicap == null
                        ? '–'
                        : handicapLabel(golfer.handicap!),
                    label: 'Handicap',
                  ),
                  QaddyStat(
                    icon: Icons.assignment_outlined,
                    figure: stats == null
                        ? '–'
                        : '${stats.averagePoints.round()}',
                    label: 'Avg points',
                  ),
                  QaddyStat(
                    icon: Icons.flag_outlined,
                    figure: '${stats?.rounds ?? 0}',
                    label: 'Rounds',
                  ),
                  QaddyStat(
                    icon: Icons.emoji_events_outlined,
                    figure: '${stats?.wins ?? 0}',
                    label: stats?.wins == 1 ? 'Win' : 'Wins',
                  ),
                ],
              ),
            ],
            SizedBox(height: spacing.sectionGap),
            QaddyQuickActions(actions: shortcuts),
            SizedBox(height: spacing.sectionGap),
            QaddySectionHeading(title: 'Achievements', badge: earned),
            SizedBox(height: spacing.md),
            AchievementShelf(achievements: achievements),
            if (stats != null) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(
                title: 'Recent rounds',
                actionLabel: 'View all',
                onAction: () => context.push(AppRoutes.profileStatistics),
              ),
              SizedBox(height: spacing.md),
              _RecentRounds(
                rounds: stats.chronological.reversed.take(3).toList(),
              ),
            ],
            // Only once the golfer has made something of their own: a row of
            // zeros (and someone else's sample numbers) says nothing.
            if (allTrips.length - sampleTrips > 0) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Your world'),
              SizedBox(height: spacing.md),
              _World(
                sampleFriends: sampleFriends,
                sampleGroups: groups.length,
                trips: allTrips.length - sampleTrips,
                sampleTrips: sampleTrips,
              ),
            ],
            if (stats != null && stats.rivals.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Your playing partners'),
              SizedBox(height: spacing.md),
              _Partners(rivals: stats.rivals.take(4).toList()),
            ],
            SizedBox(height: spacing.sectionGap),
            if (stats == null)
              QaddyGoldButton(
                label: 'Start your first round',
                icon: Icons.sports_golf,
                tall: true,
                onPressed: () => context.go(AppRoutes.rounds),
              )
            else
              QaddyGoldButton(
                label: 'View full statistics',
                icon: Icons.bar_chart_rounded,
                tall: true,
                onPressed: () => context.push(AppRoutes.profileStatistics),
              ),
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
    required this.sampleFriends,
    required this.sampleGroups,
    required this.trips,
    required this.sampleTrips,
  });

  final int sampleFriends;
  final int sampleGroups;
  final int trips;
  final int sampleTrips;

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
      String to, {
      int sample = 0,
    }) => Expanded(
      child: Semantics(
        button: true,
        label: sample == 0
            ? '$count $label'
            : '$count $label, plus $sample sample',
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
              if (sample > 0)
                Text(
                  '+$sample sample',
                  style: typography.caption.copyWith(
                    color: colours.accent,
                    fontWeight: FontWeight.w600,
                  ),
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
          0,
          'Friends',
          AppRoutes.friends,
          sample: sampleFriends,
        ),
        SizedBox(width: spacing.cardGap),
        tile(
          Icons.groups,
          colours.accentIndigo,
          0,
          'Groups',
          AppRoutes.friendsGroups,
          sample: sampleGroups,
        ),
        SizedBox(width: spacing.cardGap),
        tile(
          Icons.luggage,
          colours.accentSky,
          trips,
          'Trips',
          AppRoutes.trips,
          sample: sampleTrips,
        ),
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

/// The last few rounds, newest first: a thumbnail, the course and day, the
/// points and where the golfer finished.
class _RecentRounds extends StatelessWidget {
  const _RecentRounds({required this.rounds});

  final List<YourRound> rounds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      onTap: () => context.push(AppRoutes.profileStatistics),
      child: Column(
        children: <Widget>[
          for (final (index, round) in rounds.indexed) ...<Widget>[
            if (index > 0) ...<Widget>[
              SizedBox(height: spacing.sm),
              Divider(height: 1, color: colours.border),
              SizedBox(height: spacing.sm),
            ],
            Row(
              children: <Widget>[
                SizedBox(
                  width: 52,
                  height: 44,
                  child: QaddyMediaPlaceholder(
                    borderRadius: BorderRadius.circular(radius.small),
                    tone: index % 3,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        round.round.course,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.copyWith(
                          color: colours.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${round.date.day} ${round.date.monthAbbreviation}',
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius.small),
                    border: Border.all(color: colours.border),
                  ),
                  child: Text(
                    '${round.points} pts',
                    style: typography.small.copyWith(
                      color: colours.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: round.won ? colours.selected : colours.surface2,
                    borderRadius: BorderRadius.circular(radius.small),
                  ),
                  child: Text(
                    round.won ? 'Won' : round.standing.position,
                    style: typography.small.copyWith(
                      color: round.won
                          ? theme.colorScheme.onPrimary
                          : colours.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
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
