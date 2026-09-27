/// Qaddy's Activity Feed screen — chronological friend activity.
///
/// See `docs/architecture/activity-feed.md`.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/community/models/placeholder_friends.dart';
import 'package:qaddy/features/community/ui/widgets/activity_feed_tile.dart';

/// Activity Feed (route `/friends/activity`).
class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Activity Feed')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            for (final (index, item) in friendActivityFeed.indexed) ...<Widget>[
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
