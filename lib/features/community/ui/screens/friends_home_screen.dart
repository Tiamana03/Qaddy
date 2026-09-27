/// Qaddy's Friends Home screen — the central hub for the Friends feature.
///
/// See `docs/features/friends-feature-integration.md`'s "Friends Home"
/// section: Friend Summary, Quick Actions (View Friends, Search Friends,
/// Requests, Groups, View Activity, View Rivalries), Activity Preview and
/// Pending Requests Preview. Activity Feed and Rivalries are reachable
/// directly from here — not only through Friend Profile — per
/// `docs/architecture/navigation.md`'s Friends Navigation Structure, so
/// both stay within the Three Click Rule.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/activity_feed_tile.dart';
import 'package:qaddy/features/community/ui/widgets/friend_request_row.dart';

/// Friends Home (route `/friends`) — the Friends destination.
class FriendsHomeScreen extends StatelessWidget {
  const FriendsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return QaddyScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Text(
              'Friends',
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.sectionGap),
            const _FriendSummary(),
            SizedBox(height: spacing.sectionGap),
            const _QuickActionsCard(),
            SizedBox(height: spacing.sectionGap),
            const _ActivityPreview(),
            SizedBox(height: spacing.sectionGap),
            const _PendingRequestsPreview(),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _FriendSummary extends StatelessWidget {
  const _FriendSummary();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return Row(
      children: <Widget>[
        Expanded(
          child: QaddyStatisticCard(
            label: 'Total',
            value: '$totalFriendsCount',
          ),
        ),
        SizedBox(width: spacing.cardGap),
        Expanded(
          child: QaddyStatisticCard(
            label: 'Confirmed',
            value: '$confirmedFriendsCount',
          ),
        ),
        SizedBox(width: spacing.cardGap),
        Expanded(
          child: QaddyStatisticCard(
            label: 'Pending',
            value: '$pendingFriendsCount',
          ),
        ),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    const actions = <(IconData, String, String)>[
      (Icons.people_outline, 'View Friends', AppRoutes.friendsList),
      (Icons.search, 'Search Friends', AppRoutes.friendsSearch),
      (Icons.mail_outline, 'Requests', AppRoutes.friendRequests),
      (Icons.groups_outlined, 'Groups', AppRoutes.friendsGroups),
      (Icons.timeline, 'View Activity', AppRoutes.friendsActivity),
      (
        Icons.emoji_events_outlined,
        'View Rivalries',
        AppRoutes.friendsRivalries,
      ),
    ];

    return QaddySectionCard(
      title: 'Quick Actions',
      child: Column(
        children: <Widget>[
          for (final (index, action) in actions.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.sm),
            _ActionTile(
              icon: action.$1,
              label: action.$2,
              onTap: () => context.push(action.$3),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.medium),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Row(
            children: <Widget>[
              Icon(icon, color: colours.gold),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  label,
                  style: typography.body.copyWith(color: colours.textPrimary),
                ),
              ),
              Icon(Icons.chevron_right, color: colours.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityPreview extends StatelessWidget {
  const _ActivityPreview();

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final preview = friendActivityFeed.take(3).toList();

    return QaddySectionCard(
      title: 'Activity',
      onTap: () => context.push(AppRoutes.friendsActivity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (index, item) in preview.indexed) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.md),
            ActivityFeedTile(item: item),
          ],
        ],
      ),
    );
  }
}

class _PendingRequestsPreview extends StatelessWidget {
  const _PendingRequestsPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final preview = friendRequests.take(2).toList();

    return QaddySectionCard(
      title: 'Pending Requests',
      onTap: () => context.push(AppRoutes.friendRequests),
      child: preview.isEmpty
          ? Text(
              'No pending requests.',
              style: typography.body.copyWith(color: colours.textSecondary),
            )
          : Column(
              children: <Widget>[
                for (final (index, request) in preview.indexed) ...<Widget>[
                  if (index > 0) SizedBox(height: spacing.md),
                  FriendRequestRow(request: request),
                ],
              ],
            ),
    );
  }
}
