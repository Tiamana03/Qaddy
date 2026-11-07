/// Qaddy's Dashboard — the Home destination and the first thing a golfer sees.
///
/// Composed as the approved mockup is: the brand and the way to Search,
/// Notifications and Profile; a photo hero with the greeting; four doors; the
/// upcoming round as a card; "Your Game" as four stat tiles; and the next trip.
/// Sections arrive when they have something to say (Your Game after a handicap
/// or a first round, the trip when there is one), so a new golfer sees a hero
/// and four doors, nothing empty. Photography is a placeholder until the final
/// images arrive. See `docs/features/dashboard-release-candidate.md`.
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
import 'package:qaddy/core/widgets/brand/qaddy_mark.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_icon_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_round_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/dashboard/logic/dashboard_insights.dart';
import 'package:qaddy/features/dashboard/state/dashboard_clock.dart';
import 'package:qaddy/features/dashboard/ui/widgets/home_hero.dart';
import 'package:qaddy/features/dashboard/ui/widgets/next_trip_card.dart';
import 'package:qaddy/features/dashboard/ui/widgets/your_game_tiles.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';
import 'package:qaddy/features/rounds/logic/round_insights.dart';
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
    final history = ref.watch(roundHistoryProvider);
    final stats = CareerStats.of(history, you: currentUserName);
    final golfer = ref.watch(golferDetailsProvider);
    final planned = upcomingRound.planned;
    final countdown = planned ? roundCountdown(now, upcomingRound.date) : null;

    final quickActions = <QaddyQuickAction>[
      QaddyQuickAction(
        icon: live == null ? Icons.sports_golf : Icons.play_arrow_rounded,
        featured: true,
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

    String whenPhrase(RoundCountdown c) => switch (c.value) {
      'Today' => 'Today',
      '1' => 'Tomorrow',
      _ => 'In ${c.value} days',
    };

    final names = <String>[
      currentUserName,
      for (final friend in squad) friend.displayName,
    ];

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.md),
            const _Header(),
            SizedBox(height: spacing.lg),
            HomeHero(
              greeting: '${greetingFor(now)},',
              name: currentUserDisplayName,
              line: dateLine(now),
              weather: planned ? upcomingRound.weather : null,
              course: planned ? upcomingRound.course : null,
              sample: planned,
            ),
            SizedBox(height: spacing.cardGap),
            QaddyQuickActions(actions: quickActions),
            SizedBox(height: spacing.sectionGap),
            QaddySectionHeading(
              title: 'Upcoming round',
              actionLabel: 'See all',
              onAction: () => context.go(AppRoutes.rounds),
            ),
            SizedBox(height: spacing.md),
            if (live != null)
              QaddyRoundCard(
                course: live.course,
                when: 'Hole ${live.currentHole + 1} of ${live.holes.length}',
                primaryLabel: 'Continue round',
                onPrimary: () => context.push(AppRoutes.roundScorecard),
              )
            else
              QaddyRoundCard(
                course: upcomingRound.course,
                day: planned ? upcomingRound.date : null,
                when: countdown == null ? null : whenPhrase(countdown),
                teeTime: planned ? upcomingRound.teeTime : null,
                players: planned ? names : const <String>[],
                total: upcomingRound.players,
                sample: planned,
                primaryLabel: planned ? 'Get ready' : 'Start round',
                onPrimary: () => context.go(AppRoutes.rounds),
                onDetails: planned
                    ? () => shareOrCopy(
                        context,
                        ref,
                        text: roundShareMessage(upcomingRound, currentUserName),
                        subject: "Who's in?",
                      )
                    : null,
              ),
            if (stats != null || golfer.handicap != null) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(
                title: 'Your game',
                actionLabel: 'See all',
                onAction: () => context.push(AppRoutes.profileStatistics),
              ),
              SizedBox(height: spacing.md),
              YourGameTiles(
                handicap: golfer.handicap,
                stats: stats,
                onOpen: () => context.push(AppRoutes.profileStatistics),
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
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// The brand, and the way to Search, Notifications and Profile.
///
/// The mark and wordmark are a placeholder for the crown lockup (see
/// `docs/design/asset-register.md`).
class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    Widget action(Widget icon, String tooltip, VoidCallback onTap) => Padding(
      padding: EdgeInsets.only(left: spacing.sm),
      child: QaddyIconButton.custom(
        tooltip: tooltip,
        semanticLabel: tooltip,
        onPressed: onTap,
        child: icon,
      ),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              const QaddyMark(size: 32, animate: false),
              SizedBox(width: spacing.sm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Qaddy',
                    style: typography.h3.copyWith(
                      color: colours.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
