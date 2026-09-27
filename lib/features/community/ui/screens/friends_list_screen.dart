/// Qaddy's Friends List screen — every Confirmed friend.
///
/// See `docs/features/friends-feature-integration.md`'s "Friends List"
/// section. Only Tom (the shared placeholder friend with full detail data)
/// opens Friend Profile — the same "only the detailed subject is
/// interactive" pattern `TripsScreen`'s `_TripListCard` already uses for
/// Melbourne Golf Weekend.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/models/friend.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/friend_card.dart';

/// Friends List (route `/friends/list`).
class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Friends List')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final (index, friend) in confirmedFriends.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              _FriendListCard(friend: friend),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _FriendListCard extends StatelessWidget {
  const _FriendListCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final isDetailed = friend.id == tom.id;

    return FriendCard(
      friend: friend,
      onTap: isDetailed ? () => context.push(AppRoutes.friendProfile) : null,
    );
  }
}
