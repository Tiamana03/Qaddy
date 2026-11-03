/// Qaddy's Dashboard — the Home destination and the first thing a golfer sees.
///
/// The Dashboard is the first tee: today, in one screen. It leads with the
/// round you are about to play (a countdown, who is coming, one tap to get
/// ready or to tell the group), then your shortcuts, your game, your next
/// trip, what your mates have been up to and your recent highlights. Every
/// card and every button leads somewhere real. See
/// `docs/features/dashboard-release-candidate.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/actions/qaddy_quick_actions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/widgets/activity_feed_tile.dart';
import 'package:qaddy/features/dashboard/logic/dashboard_insights.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/dashboard/ui/widgets/highlights_card.dart';
import 'package:qaddy/features/dashboard/ui/widgets/next_round_hero.dart';
import 'package:qaddy/features/dashboard/ui/widgets/next_trip_card.dart';
import 'package:qaddy/features/dashboard/ui/widgets/your_game_card.dart';
import 'package:qaddy/features/profile/models/placeholder_profile.dart';
import 'package:qaddy/features/rounds/models/placeholder_rounds.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/trips/state/trips_controller.dart';

/// The Home / Dashboard destination (route `/home`).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;

    final now = ref.watch(dashboardClockProvider)();
    final squad = ref.watch(confirmedFriendsProvider);
    final nextTrip = ref.watch(
      upcomingTripsProvider.select(
        (trips) => trips.isEmpty ? null : trips.first,
      ),
    );
    final live = ref.watch(liveRoundProvider);
    final completed = ref.watch(completedRoundProvider);
    final history = ref.watch(roundHistoryProvider);
    final stats = CareerStats.of(history, you: currentUserName);
    final lastRound = completed == null
        ? null
        : lastRoundFrom(completed, currentUserName, now);

    final quickActions = <QaddyQuickAction>[
      QaddyQuickAction(
        icon: live == null ? Icons.sports_golf : Icons.play_arrow_rounded,
        label: live == null ? 'Start a round' : 'Continue round',
        colour: colours.accentTeal,
        onTap: () => live == null
            ? context.go(AppRoutes.rounds)
            : context.push(AppRoutes.roundScorecard),
      ),
      QaddyQuickAction(
        icon: Icons.luggage_outlined,
        label: 'Plan a trip',
        colour: colours.accentSky,
        onTap: () => context.push(AppRoutes.tripCreate),
      ),
      QaddyQuickAction(
        icon: Icons.person_add_alt_1_outlined,
        label: 'Add a mate',
        colour: colours.accentPink,
        onTap: () => context.push(AppRoutes.friendsSearch),
      ),
      QaddyQuickAction(
        icon: Icons.bar_chart_rounded,
        label: 'My stats',
        colour: colours.accentOrange,
        onTap: () => context.push(AppRoutes.profileStatistics),
      ),
    ];

    final highlights = <Highlight>[
      Highlight(
        icon: Icons.golf_course,
        colour: colours.accentTeal,
        text: 'Round completed at Richmond Golf Club',
        onTap: () => context.push(AppRoutes.profileStatistics),
      ),
      Highlight(
        icon: Icons.group_add,
        colour: colours.accentIndigo,
        text: 'Josh joined the Saturday Boys group',
        onTap: () => context.push(AppRoutes.friendsGroupDetails),
      ),
      Highlight(
        icon: Icons.luggage,
        colour: colours.accentSky,
        text: 'New golf trip created',
        onTap: () => context.go(AppRoutes.trips),
      ),
      Highlight(
        icon: Icons.trending_down,
        colour: colours.gold,
        text: 'Handicap reduced to ${profile.handicap.toStringAsFixed(1)}',
        onTap: () => context.push(AppRoutes.profileStatistics),
      ),
      Highlight(
        icon: Icons.emoji_events,
        colour: colours.gold,
        text: 'Achievement unlocked: Personal Best',
        onTap: () => context.go(AppRoutes.profile),
      ),
    ];

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            _Header(now: now),
            SizedBox(height: spacing.xl),
            NextRoundHero(
              round: upcomingRound,
              countdown: roundCountdown(now, upcomingRound.date),
              players: <String>[
                currentUserName,
                for (final friend in squad) friend.displayName,
              ],
              inProgressHole: live == null ? null : live.currentHole + 1,
              onOpen: () => live == null
                  ? context.go(AppRoutes.rounds)
                  : context.push(AppRoutes.roundScorecard),
              onShare: () => shareOrCopy(
                context,
                ref,
                text: roundShareMessage(upcomingRound, currentUserName),
                subject: "Who's in?",
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddyQuickActions(actions: quickActions),
            SizedBox(height: spacing.sectionGap),
            YourGameCard(
              handicap: profile.handicap,
              stats: stats,
              lastRound: lastRound,
              onOpen: () => context.push(AppRoutes.profileStatistics),
              onOpenLastRound: lastRound == null
                  ? null
                  : () => context.push(AppRoutes.roundComplete),
            ),
            SizedBox(height: spacing.sectionGap),
            NextTripCard(
              trip: nextTrip,
              now: now,
              onOpen: () => context.push(
                nextTrip == null
                    ? AppRoutes.tripCreate
                    : AppRoutes.tripDetails(nextTrip.id),
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionHeading(
              title: 'From your mates',
              actionLabel: 'See all',
              onAction: () => context.go(AppRoutes.friends),
            ),
            SizedBox(height: spacing.md),
            const _Mates(),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Your highlights'),
            SizedBox(height: spacing.md),
            HighlightsCard(highlights: highlights),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// The greeting, the golfer's name, today's date and the way to Search,
/// Notifications and Profile.
class _Header extends StatelessWidget {
  const _Header({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    Widget action(Widget icon, String tooltip, VoidCallback onTap) => Padding(
      padding: EdgeInsets.only(left: spacing.sm),
      child: IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: colours.surface1,
          foregroundColor: colours.textPrimary,
          minimumSize: const Size(48, 48),
        ),
        icon: icon,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${greetingFor(now)},',
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  currentUserName,
                  style: typography.h1.copyWith(color: colours.textPrimary),
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                dateLine(now),
                style: typography.small.copyWith(color: colours.textTertiary),
              ),
            ],
          ),
        ),
        action(
          const Icon(Icons.search),
          'Search',
          () => context.push(AppRoutes.homeSearch),
        ),
        action(
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colours.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: colours.surface1, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          'Notifications',
          () => context.push(AppRoutes.homeNotifications),
        ),
        Padding(
          padding: EdgeInsets.only(left: spacing.sm),
          child: Semantics(
            button: true,
            label: 'Your profile',
            excludeSemantics: true,
            onTap: () => context.go(AppRoutes.profile),
            child: InkResponse(
              onTap: () => context.go(AppRoutes.profile),
              radius: 28,
              child: const SizedBox(
                width: 48,
                height: 48,
                child: QaddyAvatar(name: currentUserName),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The latest moments from friends, with the same cheer buttons as Friends.
class _Mates extends StatelessWidget {
  const _Mates();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final recent = friendActivityFeed.take(2).toList();

    return QaddyCard(
      child: Column(
        children: <Widget>[
          for (final (index, item) in recent.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.lg),
            ActivityFeedTile(item: item),
          ],
        ],
      ),
    );
  }
}
