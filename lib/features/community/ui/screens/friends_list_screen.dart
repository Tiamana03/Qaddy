/// Qaddy's Friends List screen — every confirmed mate.
///
/// Every row does something: Tom (the one sample mate with a full profile)
/// opens Friend Profile, and everyone else opens the same peek sheet the
/// squad strip uses — their handicap, when they last played and a one-tap
/// invite. With no mates it invites the golfer to bring some in rather than
/// showing an empty page. See `docs/features/friends-feature-integration.md`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/state/friends_controller.dart';
import 'package:qaddy/features/community/ui/widgets/friend_card.dart';
import 'package:qaddy/features/community/ui/widgets/friend_peek_sheet.dart';

/// Friends List (route `/friends/list`).
class FriendsListScreen extends ConsumerWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final confirmed = ref.watch(confirmedFriendsProvider);
    final now = ref.watch(friendsClockProvider)();

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Friends List')),
      body: confirmed.isEmpty
          ? Center(
              child: QaddyEmptyState(
                icon: Icons.group_outlined,
                title: 'No mates yet',
                message:
                    'Invite the people you play with and they will '
                    'appear here.',
                actionLabel: 'Invite a mate',
                onAction: () => context.push(AppRoutes.friendsSearch),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: spacing.lg),
                  for (final (index, friend) in confirmed.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.cardGap),
                    _FriendListCard(friend: friend, now: now),
                  ],
                  SizedBox(height: spacing.xl),
                ],
              ),
            ),
    );
  }
}

class _FriendListCard extends ConsumerWidget {
  const _FriendListCard({required this.friend, required this.now});

  final Friend friend;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FriendCard(
      friend: friend,
      onTap: friend.id == tom.id
          ? () => context.push(AppRoutes.friendProfile)
          : () => showFriendPeek(context, ref, friend, now: now),
    );
  }
}
