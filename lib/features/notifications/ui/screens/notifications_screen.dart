/// Qaddy's Notifications screen — what is happening in the golfer's golf, with
/// what they have not seen yet lit up, and every line one tap from where it
/// matters.
///
/// See `docs/features/notifications-release-candidate.md`. Notifications are
/// worked out from the golfer's real rounds, mates and trips; reading one
/// remembers it, and the bell on the Dashboard counts what is still unread.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qaddy/core/routing/app_routes.dart';
import 'package:qaddy/core/theme/qaddy_animations.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_spacing.dart';
import 'package:qaddy/core/theme/qaddy_typography.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/badges/qaddy_icon_badge.dart';
import 'package:qaddy/core/widgets/badges/sample_badge.dart';
import 'package:qaddy/core/widgets/cards/qaddy_card.dart';
import 'package:qaddy/core/widgets/headings/qaddy_section_heading.dart';
import 'package:qaddy/core/widgets/motion/qaddy_fade_slide_in.dart';
import 'package:qaddy/core/widgets/scaffold/qaddy_scaffold.dart';
import 'package:qaddy/core/widgets/states/qaddy_empty_state.dart';
import 'package:qaddy/features/notifications/logic/notification_feed.dart';
import 'package:qaddy/features/notifications/models/notification_item.dart';
import 'package:qaddy/features/notifications/state/notifications_controller.dart';

/// Notifications (route `/home/notifications`).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;

    final entries = ref.watch(notificationEntriesProvider);
    final fresh = entries.where((e) => !e.isRead).toList();
    final earlier = entries.where((e) => e.isRead).toList();

    void open(NotificationItem item) {
      QaddyHaptics.selection();
      ref.read(notificationsProvider.notifier).markRead(item.id);
      if (isTabLocation(item.location)) {
        context.go(item.location);
      } else {
        context.push(item.location);
      }
    }

    final pulse = entries.isEmpty
        ? 'Nothing to tell you right now'
        : fresh.isEmpty
        ? "You're all caught up"
        : fresh.length == 1
        ? '1 new'
        : '${fresh.length} new';

    return QaddyScaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          if (fresh.isNotEmpty)
            TextButton(
              onPressed: () {
                QaddyHaptics.light();
                ref
                    .read(notificationsProvider.notifier)
                    .markAllRead(fresh.map((e) => e.item.id));
              },
              child: Text(
                'Mark all read',
                style: TextStyle(color: colours.accent),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: staggered(<Widget>[
            SizedBox(height: spacing.lg),
            Text(
              "What's happening",
              style: typography.h1.copyWith(color: colours.textPrimary),
            ),
            SizedBox(height: spacing.xs),
            AnimatedSwitcher(
              duration: QaddyMotion.standard.fast,
              child: Text(
                pulse,
                key: ValueKey<String>(pulse),
                style: typography.body.copyWith(color: colours.textSecondary),
              ),
            ),
            SizedBox(height: spacing.xl),
            if (entries.isEmpty)
              QaddyEmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'Nothing to tell you',
                message:
                    'You have switched every kind of notification off. Turn '
                    'some back on in Settings.',
                actionLabel: 'Open Settings',
                onAction: () => context.push(AppRoutes.profileSettings),
              )
            else ...<Widget>[
              if (fresh.isNotEmpty) ...<Widget>[
                QaddySectionHeading(title: 'New', badge: fresh.length),
                SizedBox(height: spacing.md),
                for (final (index, entry) in fresh.indexed) ...<Widget>[
                  if (index > 0) SizedBox(height: spacing.cardGap),
                  _NotificationTile(
                    key: ValueKey<String>(entry.item.id),
                    entry: entry,
                    onTap: () => open(entry.item),
                  ),
                ],
                SizedBox(height: spacing.sectionGap),
              ],
              if (earlier.isNotEmpty) ...<Widget>[
                const QaddySectionHeading(title: 'Earlier'),
                SizedBox(height: spacing.md),
                for (final (index, entry) in earlier.indexed) ...<Widget>[
                  if (index > 0) SizedBox(height: spacing.cardGap),
                  _NotificationTile(
                    key: ValueKey<String>(entry.item.id),
                    entry: entry,
                    onTap: () => open(entry.item),
                  ),
                ],
              ],
            ],
            SizedBox(height: spacing.xl),
          ]),
        ),
      ),
    );
  }
}

Color _accentFor(QaddyColours colours, NotificationCategory category) =>
    switch (category) {
      NotificationCategory.roundReminder => colours.accentTeal,
      NotificationCategory.friendActivity => colours.accentIndigo,
      NotificationCategory.tripUpdate => colours.accentSky,
      NotificationCategory.systemUpdate => colours.gold,
    };

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.entry,
    required this.onTap,
    super.key,
  });

  final NotificationEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final spacing = theme.extension<QaddySpacing>()!;
    final typography = theme.extension<QaddyTypography>()!;
    final item = entry.item;
    final unread = !entry.isRead;
    final accent = _accentFor(colours, item.category);

    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      label:
          '${unread ? 'New. ' : ''}${item.message}. ${item.detail ?? ''} '
          '${item.when ?? ''}. Opens it.',
      child: AnimatedOpacity(
        duration: QaddyMotion.standard.pageTransition,
        opacity: unread ? 1 : 0.72,
        child: QaddyCard(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              QaddyIconBadge(
                icon: item.icon ?? notificationCategoryIcon(item.category),
                colour: accent,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (item.sample) ...<Widget>[
                      const SampleBadge(),
                      SizedBox(height: spacing.xs),
                    ],
                    Text(
                      item.message,
                      style: typography.body.copyWith(
                        color: colours.textPrimary,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (item.detail != null) ...<Widget>[
                      SizedBox(height: spacing.xs),
                      Text(
                        item.detail!,
                        style: typography.small.copyWith(
                          color: colours.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (item.when != null)
                    Text(
                      item.when!,
                      style: typography.caption.copyWith(
                        color: colours.textTertiary,
                      ),
                    ),
                  SizedBox(height: spacing.xs),
                  AnimatedContainer(
                    duration: QaddyMotion.standard.normal,
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unread ? colours.gold : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
