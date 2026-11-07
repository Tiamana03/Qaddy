/// Qaddy's Friends Home screen — the clubhouse: your squad, the rivalry that
/// matters, anyone waiting to join you, what your mates have been up to and the
/// clubs you play with.
///
/// See `docs/features/friends-feature-integration.md`'s "Friends Home" and
/// `docs/features/friends-release-candidate.md`. Every destination the screen
/// has always offered — Friends List, Search, Requests, Groups, Activity and
/// Rivalries — is still one tap away, now through the content itself (a
/// section's "See all", a tap on the rivalry) and the two header buttons,
/// rather than a list of six links.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_icon_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/sample_banner.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/friend_request.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/widgets/activity_feed_tile.dart';
import 'package:qaddy/features/community/ui/widgets/friend_peek_sheet.dart';
import 'package:qaddy/features/community/ui/widgets/friend_request_row.dart';
import 'package:qaddy/features/community/ui/widgets/rivalry_spotlight.dart';
import 'package:qaddy/features/community/ui/widgets/squad_strip.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/clubs_strip.dart';
import 'package:qaddy/features/groups/ui/widgets/next_round_banner.dart';
import 'package:qaddy/features/groups/ui/widgets/season_race_card.dart';

/// Friends Home (route `/friends`) — the Friends destination.
class FriendsHomeScreen extends ConsumerWidget {
  const FriendsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final now = ref.watch(friendsClockProvider)();
    final squad = ref.watch(confirmedFriendsProvider);
    final incoming = ref.watch(incomingRequestsProvider);
    final outgoing = ref.watch(outgoingRequestsProvider);
    final active = recentlyActive(squad, now);
    final sample = ref.watch(sampleOnProvider);

    final clubs = <ClubPreview>[
      // The next round has its own card above; a club here is its crest and
      // its size.
      for (final group in groups) ClubPreview(group: group),
    ];

    void openClub(Group group) =>
        context.push(AppRoutes.friendsGroup(group.id));

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            _Header(
              onSearch: () => context.push(AppRoutes.friendsSearch),
              onAll: () => context.push(AppRoutes.friendsList),
            ),
            SizedBox(height: spacing.xs),
            Text(
              _summaryLine(squad, active, sample: sample),
              style: typography.body.copyWith(color: colours.textSecondary),
            ),
            SizedBox(height: spacing.xl),
            if (sample) ...<Widget>[
              SampleBanner(
                message:
                    'Your mates, clubs, rivalry and season table here are '
                    'pretend, so you can see how Qaddy works.',
                onManage: () => context.push(AppRoutes.profileSettings),
              ),
              SizedBox(height: spacing.sectionGap),
              const _NextRound(),
              SizedBox(height: spacing.sectionGap),
            ],
            if (squad.isEmpty)
              QaddyEmptyState(
                icon: Icons.groups_outlined,
                title: 'Build your squad',
                message:
                    'Invite the golfers you play with. Once they join, their '
                    'rounds, handicaps and rivalries land right here.',
                actionLabel: 'Invite a mate',
                onAction: () => context.push(AppRoutes.friendsSearch),
              )
            else ...<Widget>[
              QaddySectionHeading(
                title: 'Your squad',
                actionLabel: 'See all',
                onAction: () => context.push(AppRoutes.friendsList),
              ),
              SizedBox(height: spacing.md),
              SquadStrip(
                friends: squad,
                now: now,
                onFriendTap: (friend) =>
                    showFriendPeek(context, ref, friend, now: now),
                onAdd: () => context.push(AppRoutes.friendsSearch),
              ),
            ],
            if (incoming.isNotEmpty || outgoing.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(
                title: 'Requests',
                badge: incoming.length,
                actionLabel: 'See all',
                onAction: () => context.push(AppRoutes.friendRequests),
              ),
              SizedBox(height: spacing.md),
              _Requests(incoming: incoming, outgoing: outgoing),
            ],
            if (sample) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const _Rivalry(),
              SizedBox(height: spacing.sectionGap),
              const _SeasonRace(),
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(
                title: 'Latest from mates',
                actionLabel: 'See all',
                onAction: () => context.push(AppRoutes.friendsActivity),
              ),
              SizedBox(height: spacing.md),
              const _Activity(),
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(
                title: 'Your clubs',
                actionLabel: 'See all',
                onAction: () => context.push(AppRoutes.friendsGroups),
              ),
              SizedBox(height: spacing.md),
              ClubsStrip(clubs: clubs, onOpen: openClub),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// "5 friends · Tom and Ben played recently".
String _summaryLine(
  List<Friend> squad,
  List<Friend> active, {
  required bool sample,
}) {
  if (squad.isEmpty) {
    return 'Your golf crew, all in one place';
  }
  // The sample mates are never called the golfer's friends.
  final noun = sample ? 'sample mate' : 'friend';
  final count = squad.length == 1 ? '1 $noun' : '${squad.length} ${noun}s';
  if (active.isEmpty) {
    return count;
  }
  final names = active.map((friend) => friend.displayName).toList();
  final who = names.length <= 2
      ? names.join(' and ')
      : '${names.take(2).join(', ')} and ${names.length - 2} more';
  return '$count · $who played recently';
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch, required this.onAll});

  final VoidCallback onSearch;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    Widget action(IconData icon, String tooltip, VoidCallback onTap) => Padding(
      padding: EdgeInsets.only(left: spacing.sm),
      child: QaddyIconButton(
        tooltip: tooltip,
        semanticLabel: tooltip,
        onPressed: onTap,
        icon: icon,
      ),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Friends',
            style: typography.h1.copyWith(color: colours.textPrimary),
          ),
        ),
        action(Icons.person_add_alt_1_outlined, 'Invite a mate', onSearch),
        action(Icons.people_outline, 'All friends', onAll),
      ],
    );
  }
}

class _Requests extends StatelessWidget {
  const _Requests({required this.incoming, required this.outgoing});

  final List<FriendRequest> incoming;
  final List<FriendRequest> outgoing;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final all = <FriendRequest>[...incoming, ...outgoing];

    // The section eases open and shut as requests are answered.
    return AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : QaddyMotion.standard.pageTransition,
      curve: QaddyMotion.standard.enter,
      alignment: Alignment.topCenter,
      child: Column(
        children: <Widget>[
          for (final (index, request) in all.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.cardGap),
            FriendRequestRow(
              key: ValueKey<String>(request.friend.id),
              request: request,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _NextRound extends ConsumerWidget {
  const _NextRound();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NextRoundBanner(
      groupName: saturdayBoys.name,
      round: saturdayBoysUpcomingRound,
      players: <String>[for (final member in saturdayBoysMembers) member.name],
      onOpen: () => context.push(AppRoutes.friendsGroup(saturdayBoys.id)),
      onRally: () => shareOrCopy(
        context,
        ref,
        text: rallyMessage(
          groupName: saturdayBoys.name,
          round: saturdayBoysUpcomingRound,
          yourName: currentUserName,
        ),
        subject: "Who's in?",
      ),
    );
  }
}

class _SeasonRace extends StatelessWidget {
  const _SeasonRace();

  @override
  Widget build(BuildContext context) {
    return SeasonRaceCard(
      race: SeasonRace.of(
        saturdayBoysLeaderboard,
        yourName: currentUserName,
        roundsRemaining: saturdayBoysSeasonSummary.roundsRemaining,
      ),
      groupName: saturdayBoys.name,
      yourName: currentUserName,
      onOpen: () => context.push(AppRoutes.friendsGroup(saturdayBoys.id)),
    );
  }
}

class _Rivalry extends ConsumerWidget {
  const _Rivalry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = RivalrySummary.of(tomRivalry);

    return RivalrySpotlight(
      summary: summary,
      yourName: currentUserName,
      onOpen: () => context.push(AppRoutes.friendsRivalries),
      onChallenge: () => shareOrCopy(
        context,
        ref,
        text: summary.challengeMessage(currentUserName),
        subject: 'Rematch?',
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  const _Activity();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final recent = friendActivityFeed.take(3).toList();

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
