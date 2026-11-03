/// Qaddy's group page — the clubhouse: who is in the group, what is coming up
/// and who is winning the season, with the things you do together (play,
/// travel, invite, wind each other up) one tap away.
///
/// See `docs/features/groups-release-candidate.md`. Saturday Boys is the group
/// with a full season; every other group shows what it has, and says kindly
/// what its first round will start.
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
import 'package:qaddy/core/utils/formatting.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/actions/link_actions.dart';
import 'package:qaddy/core/widgets/actions/qaddy_quick_actions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/buttons/qaddy_gold_button.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/widgets/friend_peek_sheet.dart';
import 'package:qaddy/features/groups/logic/group_insights.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/group_detail.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/group_crest.dart';
import 'package:qaddy/features/groups/ui/widgets/group_leaderboard_row.dart';
import 'package:qaddy/features/groups/ui/widgets/next_round_banner.dart';
import 'package:qaddy/features/groups/ui/widgets/season_race_card.dart';
import 'package:qaddy/features/rounds/state/rounds_controller.dart';
import 'package:qaddy/features/statistics/logic/career_stats.dart';
import 'package:qaddy/features/statistics/ui/widgets/rival_row.dart';

/// A group's page (route `/friends/groups/:groupId`).
class GroupDetailsScreen extends ConsumerWidget {
  const GroupDetailsScreen({required this.groupId, super.key});

  /// The id of the group to show.
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = groupById(groupId);
    if (group == null) {
      return QaddyScaffold(
        appBar: AppBar(title: const Text('Group')),
        body: Center(
          child: QaddyEmptyState(
            icon: Icons.groups_outlined,
            title: 'This group has gone quiet',
            message:
                "We couldn't find that group. Your crews are one tap away.",
            actionLabel: 'See my groups',
            onAction: () => context.go(AppRoutes.friendsGroups),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final accent = accentForGroup(colours, group);

    final members = membersOf(group);
    final summary = seasonSummaryOf(group);
    final upcoming = upcomingRoundOf(group);
    final board = leaderboardOf(group);
    final race = SeasonRace.of(
      board,
      yourName: currentUserName,
      roundsRemaining: summary?.roundsRemaining ?? 0,
    );
    final names = members.isNotEmpty
        ? <String>[for (final member in members) member.name]
        : group.memberIds;

    void planRound() {
      QaddyHaptics.light();
      ref.read(roundSetupProvider.notifier).pick(names);
      context.go(AppRoutes.rounds);
    }

    void share(String text, String subject) =>
        shareOrCopy(context, ref, text: text, subject: subject);

    final banter = banterMessage(
      groupName: group.name,
      race: race,
      yourName: currentUserName,
    );

    final actions = <QaddyQuickAction>[
      QaddyQuickAction(
        icon: Icons.sports_golf,
        label: 'Plan a round',
        colour: colours.accentTeal,
        onTap: planRound,
      ),
      QaddyQuickAction(
        icon: Icons.luggage_outlined,
        label: 'Plan a trip',
        colour: colours.accentSky,
        onTap: () => context.go(AppRoutes.tripCreate),
      ),
      QaddyQuickAction(
        icon: Icons.person_add_alt_1_outlined,
        label: 'Invite a mate',
        colour: colours.accentPink,
        onTap: () => share(
          groupInviteMessage(group, currentUserName),
          'Join the ${group.name}',
        ),
      ),
      QaddyQuickAction(
        icon: Icons.campaign_outlined,
        label: 'Banter',
        colour: colours.accentOrange,
        onTap: () => share(banter, group.name),
      ),
    ];

    return QaddyScaffold(
      appBar: AppBar(title: Text(group.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            _Hero(group: group, accent: accent),
            SizedBox(height: spacing.sectionGap),
            QaddyQuickActions(actions: actions),
            SizedBox(height: spacing.sectionGap),
            if (upcoming != null) ...<Widget>[
              NextRoundBanner(
                groupName: group.name,
                round: upcoming,
                players: names,
                onOpen: planRound,
                onRally: () => share(
                  rallyMessage(
                    groupName: group.name,
                    round: upcoming,
                    yourName: currentUserName,
                  ),
                  "Who's in?",
                ),
              ),
              SizedBox(height: spacing.sectionGap),
            ],
            if (summary != null && board.isNotEmpty) ...<Widget>[
              QaddySectionHeading(title: 'The ${summary.season}'),
              SizedBox(height: spacing.md),
              SeasonRaceCard(
                race: race,
                groupName: group.name,
                yourName: currentUserName,
                roundsPlayed: summary.roundsCompleted,
                roundsTotal: summary.roundsCompleted + summary.roundsRemaining,
              ),
              SizedBox(height: spacing.sectionGap),
            ] else ...<Widget>[
              _FirstRound(group: group, onPlan: planRound),
              SizedBox(height: spacing.sectionGap),
            ],
            if (members.isNotEmpty) ...<Widget>[
              const QaddySectionHeading(title: 'The squad'),
              SizedBox(height: spacing.md),
              _Squad(
                group: group,
                members: members,
                leader: board.isEmpty ? null : race.standings.first.player,
              ),
              SizedBox(height: spacing.sectionGap),
            ],
            if (race.standings.length > 3) ...<Widget>[
              const QaddySectionHeading(title: 'The rest of the field'),
              SizedBox(height: spacing.md),
              QaddyCard(
                child: Column(
                  children: <Widget>[
                    for (final (index, entry)
                        in race.standings.skip(3).indexed) ...<Widget>[
                      if (index > 0) SizedBox(height: spacing.xs),
                      GroupLeaderboardRow(
                        rank: entry.rank,
                        player: entry.player,
                        points: entry.points,
                        leaderPoints: race.standings.first.points,
                        isYou: entry.player == currentUserName,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: spacing.sectionGap),
            ],
            if (members.isNotEmpty) _HeadToHead(group: group, members: members),
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.group, required this.accent});

  final Group group;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;
    final description = group.description;

    return QaddyHeroCard(
      gradient: groupGradient(colours, accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GroupCrest(name: group.name, size: 64),
              SizedBox(width: spacing.lg),
              Expanded(
                child: Text(
                  group.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.h1.copyWith(color: onGradient),
                ),
              ),
            ],
          ),
          if (description != null) ...<Widget>[
            SizedBox(height: spacing.md),
            Text(
              description,
              style: typography.body.copyWith(
                color: onGradient.withValues(alpha: 0.88),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: <Widget>[
              QaddyInfoChip(
                icon: Icons.people_alt_outlined,
                text: group.totalMembers == 1
                    ? '1 mate'
                    : '${group.totalMembers} mates',
              ),
              QaddyInfoChip(
                icon: Icons.history,
                text: 'Since ${group.createdAt.year}',
              ),
              if (group.homeCourse != null)
                QaddyInfoChip(
                  icon: Icons.flag_outlined,
                  text: group.homeCourse!,
                ),
              if (group.competitionFormat != null)
                QaddyInfoChip(
                  icon: Icons.emoji_events_outlined,
                  text: group.competitionFormat!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// What a group without a season yet says: the table starts with a round.
class _FirstRound extends StatelessWidget {
  const _FirstRound({required this.group, required this.onPlan});

  final Group group;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'The table starts with a round',
            style: typography.h3.copyWith(color: colours.textPrimary),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Play a round with the ${group.name} and the points, the bragging '
            'rights and the banter all start counting.',
            style: typography.body.copyWith(color: colours.textSecondary),
          ),
          SizedBox(height: spacing.lg),
          QaddyGoldButton(
            label: 'Plan a round',
            icon: Icons.sports_golf,
            onPressed: onPlan,
          ),
        ],
      ),
    );
  }
}

class _Squad extends ConsumerWidget {
  const _Squad({
    required this.group,
    required this.members,
    required this.leader,
  });

  final Group group;
  final List<GroupMember> members;
  final String? leader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final friends = ref.watch(confirmedFriendsProvider);

    void open(GroupMember member) {
      if (member.name == currentUserName) {
        context.go(AppRoutes.profile);
        return;
      }
      for (final friend in friends) {
        if (friend.displayName == member.name) {
          showFriendPeek(
            context,
            ref,
            friend,
            now: ref.read(friendsClockProvider)(),
          );
          return;
        }
      }
    }

    return Wrap(
      spacing: spacing.md,
      runSpacing: spacing.lg,
      children: <Widget>[
        for (final (index, member) in members.indexed)
          QaddyFadeSlideIn(
            offset: 8,
            delay: staggerDelay(index, stepMs: 45),
            child: _MemberTile(
              member: member,
              isYou: member.name == currentUserName,
              isCaptain: member.name == group.ownerId,
              isLeader: member.name == leader,
              onTap: () => open(member),
            ),
          ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isYou,
    required this.isCaptain,
    required this.isLeader,
    required this.onTap,
  });

  final GroupMember member;
  final bool isYou;
  final bool isCaptain;
  final bool isLeader;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final label = isYou ? 'You' : member.name;
    final role = <String>[
      if (isCaptain) 'Captain',
      if (isLeader) 'Table leader',
    ].join(', ');

    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '$label, handicap ${handicapLabel(member.handicap)}'
          '${role.isEmpty ? '' : ', $role'}. Opens their card.',
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius.large),
        onTap: () {
          QaddyHaptics.selection();
          onTap();
        },
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isLeader ? colours.gold : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: QaddyAvatar(name: member.name),
                  ),
                  if (isLeader)
                    Positioned(
                      right: -4,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colours.backgroundBase,
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          size: 18,
                          color: colours.gold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: spacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.small.copyWith(
                  color: isYou ? colours.gold : colours.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                isCaptain ? 'Captain' : 'HCP ${handicapLabel(member.handicap)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.caption.copyWith(
                  color: isCaptain ? colours.gold : colours.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How the golfer's real finished rounds have gone against this group's mates.
class _HeadToHead extends ConsumerWidget {
  const _HeadToHead({required this.group, required this.members});

  final Group group;
  final List<GroupMember> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final stats = CareerStats.of(
      ref.watch(roundHistoryProvider),
      you: currentUserName,
    );
    final mates = <String>{for (final member in members) member.name};
    final rivals = <Rival>[
      for (final rival in stats?.rivals ?? const <Rival>[])
        if (mates.contains(rival.name)) rival,
    ].take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const QaddySectionHeading(title: 'Head to head'),
        SizedBox(height: spacing.md),
        QaddyCard(
          child: rivals.isEmpty
              ? Text(
                  'Play a round with the ${group.name} and the bragging rights '
                  'start counting.',
                  style: typography.body.copyWith(color: colours.textSecondary),
                )
              : Column(
                  children: <Widget>[
                    for (final (index, rival) in rivals.indexed) ...<Widget>[
                      if (index > 0) SizedBox(height: spacing.lg),
                      RivalRow(rival: rival),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
