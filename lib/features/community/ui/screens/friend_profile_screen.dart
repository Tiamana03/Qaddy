/// Qaddy's Friend Profile screen — a mate's player card: who they are, what
/// you have been through together and the quickest ways to get a round going.
///
/// See `docs/architecture/friend-profile.md` and
/// `docs/features/friends-profile-and-rivalries.md`. Displays Tom — the shared
/// placeholder friend (see `placeholder_friends.dart`).
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
import 'package:qaddy/core/widgets/badges/qaddy_info_chip.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_hero_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/logic/friend_insights.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/widgets/activity_feed_tile.dart';
import 'package:qaddy/features/community/ui/widgets/rivalry_strip.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/group_crest.dart';

/// Friend Profile (route `/friends/profile`).
class FriendProfileScreen extends ConsumerWidget {
  const FriendProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final onGradient = theme.colorScheme.onPrimary;

    // The store is the truth; the placeholder is the fallback.
    final friend = ref
        .watch(confirmedFriendsProvider)
        .firstWhere((f) => f.id == tom.id, orElse: () => tom);
    final now = ref.watch(friendsClockProvider)();
    final recent = playedRecently(friend, now);
    final summary = RivalrySummary.of(tomRivalry);
    final theirActivity = friendActivityFeed
        .where((item) => item.actor == friend.displayName)
        .take(2)
        .toList();
    final sharedGroups = <Group>[
      for (final group in groups)
        if (membersOf(group).any((m) => m.name == friend.displayName)) group,
    ];

    final actions = <QaddyQuickAction>[
      QaddyQuickAction(
        icon: Icons.sports_golf,
        label: 'Invite to play',
        colour: colours.accentTeal,
        onTap: () => shareOrCopy(
          context,
          ref,
          text: inviteMessage(friend, currentUserName),
          subject: 'Fancy a round?',
        ),
      ),
      QaddyQuickAction(
        icon: Icons.emoji_events_outlined,
        label: 'Challenge',
        colour: colours.accentOrange,
        onTap: () => shareOrCopy(
          context,
          ref,
          text: summary.challengeMessage(currentUserName),
          subject: 'Rematch?',
        ),
      ),
      QaddyQuickAction(
        icon: Icons.timeline,
        label: 'Activity',
        colour: colours.accentSky,
        onTap: () => context.push(AppRoutes.friendsActivity),
      ),
    ];

    return QaddyScaffold(
      appBar: AppBar(title: Text(friend.displayName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            QaddyHeroCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color.lerp(colours.accentSky, colours.backgroundBase, 0.5)!,
                  Color.lerp(colours.accentSky, colours.backgroundBase, 0.82)!,
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 84,
                        height: 84,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: recent
                                ? colours.gold
                                : onGradient.withValues(alpha: 0.35),
                            width: 3,
                          ),
                        ),
                        child: FittedBox(
                          child: QaddyAvatar(name: friend.displayName),
                        ),
                      ),
                      SizedBox(width: spacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              friend.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.h1.copyWith(color: onGradient),
                            ),
                            SizedBox(height: spacing.xs),
                            Text(
                              'Handicap ${handicapLabel(friend.handicap)}',
                              style: typography.h3.copyWith(
                                color: colours.gold,
                              ),
                            ),
                            Text(
                              lastPlayedLabel(friend, now),
                              style: typography.small.copyWith(
                                color: onGradient.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.lg),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    children: <Widget>[
                      QaddyInfoChip(
                        icon: Icons.flag_outlined,
                        text: '${friend.homeClub} · ${friend.location}',
                      ),
                      QaddyInfoChip(
                        icon: Icons.sports_golf,
                        text: friend.roundsPlayed == 1
                            ? '1 round'
                            : '${friend.roundsPlayed} rounds',
                      ),
                      QaddyInfoChip(
                        icon: Icons.history,
                        text: 'Since ${friend.createdAt.year}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddyQuickActions(actions: actions),
            SizedBox(height: spacing.sectionGap),
            const QaddySectionHeading(title: 'Head to head'),
            SizedBox(height: spacing.md),
            RivalryStrip(
              summary: summary,
              yourName: currentUserName,
              onOpen: () => context.push(AppRoutes.friendsRivalries),
            ),
            if (sharedGroups.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              const QaddySectionHeading(title: 'In your crews'),
              SizedBox(height: spacing.md),
              QaddyCard(
                child: Column(
                  children: <Widget>[
                    for (final (index, group)
                        in sharedGroups.indexed) ...<Widget>[
                      if (index > 0) SizedBox(height: spacing.md),
                      _CrewRow(
                        group: group,
                        accent: accentForGroup(colours, group),
                        onTap: () =>
                            context.push(AppRoutes.friendsGroup(group.id)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (theirActivity.isNotEmpty) ...<Widget>[
              SizedBox(height: spacing.sectionGap),
              QaddySectionHeading(
                title: 'Latest from ${friend.displayName}',
                actionLabel: 'See all',
                onAction: () => context.push(AppRoutes.friendsActivity),
              ),
              SizedBox(height: spacing.md),
              QaddyCard(
                child: Column(
                  children: <Widget>[
                    for (final (index, item)
                        in theirActivity.indexed) ...<Widget>[
                      if (index > 0) SizedBox(height: spacing.lg),
                      ActivityFeedTile(item: item),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

/// One crew you and this mate share: its crest, name and what it is about.
class _CrewRow extends StatelessWidget {
  const _CrewRow({
    required this.group,
    required this.accent,
    required this.onTap,
  });

  final Group group;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      label: '${group.name}. Opens the group.',
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
              child: GroupCrest(name: group.name, size: 40),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    group.name,
                    style: typography.body.copyWith(
                      color: colours.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (group.description != null)
                    Text(
                      group.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.small.copyWith(
                        color: colours.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colours.textTertiary),
          ],
        ),
      ),
    );
  }
}
