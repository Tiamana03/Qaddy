/// Qaddy's Friend Profile screen — one friend's details and shared history.
///
/// See `docs/architecture/friend-profile.md`. Displays Tom — the shared
/// placeholder friend (see `placeholder_friends.dart`).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/date_extensions.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/core/widgets/badges/qaddy_status_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_section_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/friend_info_row.dart';

/// Friend Profile (route `/friends/profile`).
class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final friend = tom;

    return QaddyScaffold(
      appBar: AppBar(title: Text(friend.displayName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            Center(
              child: Column(
                children: <Widget>[
                  QaddyAvatar(name: friend.displayName),
                  SizedBox(height: spacing.sm),
                  Text(
                    friend.displayName,
                    style: typography.h2.copyWith(color: colours.textPrimary),
                  ),
                  SizedBox(height: spacing.xs),
                  // Only Confirmed friends can be opened from Friends List —
                  // see friend-profile.md's "Status Badge" section.
                  const QaddyStatusBadge(
                    label: 'Confirmed',
                    tone: QaddyStatusBadgeTone.success,
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FriendInfoRow(label: 'Home Club', value: friend.homeClub),
                  SizedBox(height: spacing.sm),
                  FriendInfoRow(label: 'Location', value: friend.location),
                  SizedBox(height: spacing.sm),
                  FriendInfoRow(label: 'Handicap', value: '${friend.handicap}'),
                  SizedBox(height: spacing.sm),
                  FriendInfoRow(
                    label: 'Member Since',
                    value: friend.createdAt.toFriendlyDate(),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            QaddySectionCard(
              title: 'Shared History',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FriendInfoRow(
                    label: 'Rounds Played Together',
                    value: '${friend.roundsPlayed}',
                  ),
                  SizedBox(height: spacing.sm),
                  FriendInfoRow(
                    label: 'Last Played Together',
                    value: friend.lastPlayed.toRelative(),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.sectionGap),
            _QuickActionsCard(friend: friend.displayName),
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.friend});

  final String friend;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddySectionCard(
      title: 'Quick Actions',
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ActionTile(
              icon: Icons.timeline,
              label: 'View Activity',
              onTap: () => context.push(AppRoutes.friendsActivity),
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: _ActionTile(
              icon: Icons.emoji_events_outlined,
              label: 'View Rivalry',
              onTap: () => context.push(AppRoutes.friendsRivalries),
            ),
          ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: colours.gold, size: spacing.xl),
              SizedBox(height: spacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: typography.small.copyWith(color: colours.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
