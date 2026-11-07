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
import 'package:qaddy/core/user/golfer_controller.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/actions/qaddy_quick_actions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/achievements/logic/achievements.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/dashboard/logic/dashboard_insights.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/dashboard/ui/widgets/highlights_card.dart';
import 'package:qaddy/features/dashboard/ui/widgets/next_round_hero.dart';
import 'package:qaddy/features/dashboard/ui/widgets/next_trip_card.dart';
import 'package:qaddy/features/dashboard/ui/widgets/your_game_card.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';
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
        label: 'Invite a mate',
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

    final golfer = ref.watch(golferDetailsProvider);
    final earned = achievementsFor(stats).where((a) => a.unlocked).length;
    final requests = ref.watch(incomingRequestsProvider);
    final race = SeasonRace.of(
      saturdayBoysLeaderboard,
      yourName: currentUserName,
      roundsRemaining: saturdayBoysSeasonSummary.roundsRemaining,
    );

    // Only what has really happened: the last round, what it earned, who is
    // waiting on you and where the season stands.
    final highlights = <Highlight>[
      if (lastRound != null)
        Highlight(
          icon: Icons.golf_course,
          colour: colours.accentTeal,
          text:
              '${lastRound.position} at ${lastRound.course} · '
              '${lastRound.stableford} points',
          onTap: () => context.push(AppRoutes.roundComplete),
        ),
      if (earned > 0)
        Highlight(
          icon: Icons.emoji_events,
          colour: colours.gold,
          text:
              '$earned ${earned == 1 ? 'achievement' : 'achievements'} earned',
          onTap: () => context.go(AppRoutes.profile),
        ),
      for (final request in requests.take(2))
        Highlight(
          icon: Icons.group_add,
          colour: colours.accentIndigo,
          text: '${request.friend.displayName} wants to play with you',
          onTap: () => context.push(AppRoutes.friendRequests),
        ),
      if (groups.isNotEmpty)
        Highlight(
          icon: Icons.leaderboard_outlined,
          colour: colours.accentOrange,
          text: '${race.headline} in the ${saturdayBoys.name} table (sample)',
          onTap: () => context.push(AppRoutes.friendsGroup(saturdayBoys.id)),
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
            // Sections arrive as they have something to say: the golfer's game
            // after a first round or a handicap, the trip when there is one,
            // highlights when something happened. A new golfer sees a hero and
            // four doors, nothing empty.
            if (stats != null || golfer.handicap != null) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              YourGameCard(
                handicap: golfer.handicap,
                stats: stats,
                lastRound: lastRound,
                onOpen: () => context.push(AppRoutes.profileStatistics),
                onOpenLastRound: lastRound == null
                    ? null
                    : () => context.push(AppRoutes.roundComplete),
              ),
            ],
            if (nextTrip != null) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              NextTripCard(
                trip: nextTrip,
                now: now,
                onOpen: () => context.push(AppRoutes.tripDetails(nextTrip.id)),
              ),
            ],
            if (highlights.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'Highlights'),
              SizedBox(height: spacing.md),
              HighlightsCard(highlights: highlights),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// The greeting, the golfer's name, today's date and the way to Search,
/// Notifications and Profile.
class _Header extends ConsumerWidget {
  const _Header({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
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
                  currentUserDisplayName,
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
              if (unread > 0)
                // The unread count, as in the mockups: a small gold badge.
                Positioned(
                  right: -spacing.sm,
                  top: -spacing.sm,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: spacing.lg,
                      minHeight: spacing.lg,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colours.gold,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colours.surface1, width: 1.5),
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
              child: SizedBox(
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
