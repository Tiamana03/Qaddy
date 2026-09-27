/// Qaddy's Groups screen — every group the user belongs to.
///
/// See `docs/architecture/groups.md`. Only Saturday Boys (the shared
/// placeholder group with full detail data) opens Group Details — the
/// same "only the detailed subject is interactive" pattern
/// `TripsScreen`'s `_TripListCard` already uses for Melbourne Golf Weekend.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/groups/models/group.dart';
import 'package:qaddy/features/groups/models/placeholder_groups.dart';
import 'package:qaddy/features/groups/ui/widgets/group_card.dart';

/// Groups (route `/friends/groups`).
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final (index, group) in groups.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              _GroupListCard(group: group),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _GroupListCard extends StatelessWidget {
  const _GroupListCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final isDetailed = group.id == saturdayBoys.id;

    return GroupCard(
      group: group,
      onTap: isDetailed
          ? () => context.push(AppRoutes.friendsGroupDetails)
          : null,
    );
  }
}
