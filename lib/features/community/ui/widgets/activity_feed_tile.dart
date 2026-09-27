/// A single Activity Feed entry — see `docs/architecture/activity-feed.md`'s
/// "Screen Contents" ("Icon derived from Activity Type, actor's avatar,
/// message, relative timestamp"). Shared by the Activity Feed screen and
/// Friends Home's Activity Preview.
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/avatars/qaddy_avatar.dart';
import 'package:qaddy/features/community/logic/activity_relative_time.dart';
import 'package:qaddy/features/community/models/activity_feed_item.dart';

/// The icon representing an [ActivityType].
IconData activityTypeIcon(ActivityType type) {
  return switch (type) {
    ActivityType.roundCompleted => Icons.golf_course,
    ActivityType.friendJoined => Icons.person_add,
    ActivityType.groupJoined => Icons.group_add,
    ActivityType.tripCreated => Icons.luggage,
    ActivityType.handicapChanged => Icons.trending_down,
    ActivityType.achievementUnlocked => Icons.emoji_events,
  };
}

/// One [ActivityFeedItem]'s row.
class ActivityFeedTile extends StatelessWidget {
  const ActivityFeedTile({required this.item, super.key});

  /// The activity entry to display.
  final ActivityFeedItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        QaddyAvatar(name: item.actor),
        SizedBox(width: spacing.md),
        Icon(
          activityTypeIcon(item.type),
          color: colours.gold,
          size: spacing.lg,
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                item.message,
                style: typography.body.copyWith(color: colours.textPrimary),
              ),
              SizedBox(height: spacing.xs),
              Text(
                formatActivityTimestamp(item.timestamp),
                style: typography.small.copyWith(color: colours.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
