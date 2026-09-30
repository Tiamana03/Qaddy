/// Qaddy's Notifications screen — the in-app notification feed.
///
/// See `docs/features/notifications-feature-integration.md`. Release 1 is a
/// single screen reached from Dashboard — see
/// `docs/architecture/notifications-engineering-decisions.md`'s
/// "Notifications Is Reached From Dashboard, Not the Bottom Navigation".
library;

import 'package:flutter/material.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/cards/qaddy_statistic_card.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/notifications/models/placeholder_notifications.dart';

/// Notifications (route `/home/notifications`).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<QaddySpacing>()!;

    return QaddyScaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.lg),
            QaddyStatisticCard(
              label: 'Total Notifications',
              value: '$totalNotificationsCount',
            ),
            SizedBox(height: spacing.sectionGap),
            for (final (index, item) in notifications.indexed) ...<Widget>[
              if (index > 0) SizedBox(height: spacing.cardGap),
              QaddyCard(child: _NotificationTile(item: item)),
            ],
            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    return Row(
      children: <Widget>[
        Icon(
          notificationCategoryIcon(item.category),
          color: colours.gold,
          size: spacing.lg,
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Text(
            item.message,
            style: typography.body.copyWith(color: colours.textPrimary),
          ),
        ),
      ],
    );
  }
}
