/// Qaddy's Activity Feed screen — chronological friend activity.
///
/// Every entry is about a sample mate (there are no accounts yet), so the
/// screen says so; with the Sample Clubhouse off it says what will appear
/// instead of showing a blank page. See `docs/architecture/activity-feed.md`
/// and `docs/features/sample-clubhouse.md`.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/sample_banner.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/activity_feed_tile.dart';

/// Activity Feed (route `/friends/activity`).
class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;
    final feed = friendActivityFeed;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Activity Feed')),
      body: feed.isEmpty
          ? Center(
              child: QaddyEmptyState(
                icon: Icons.bolt_outlined,
                title: 'Nothing yet',
                message:
                    'When your mates play rounds, join groups or plan trips, '
                    'you will see it here.',
                actionLabel: 'Invite a mate',
                onAction: () => context.push(AppRoutes.friendsSearch),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: spacing.lg),
                  SampleBanner(
                    message:
                        'This activity is pretend, so you can see how '
                        'cheering a mate works.',
                    onManage: () => context.push(AppRoutes.profileSettings),
                  ),
                  SizedBox(height: spacing.sectionGap),
                  for (final (index, item) in feed.indexed) ...<Widget>[
                    if (index > 0) SizedBox(height: spacing.cardGap),
                    QaddyCard(child: ActivityFeedTile(item: item)),
                  ],
                  SizedBox(height: spacing.xl),
                ],
              ),
            ),
    );
  }
}
