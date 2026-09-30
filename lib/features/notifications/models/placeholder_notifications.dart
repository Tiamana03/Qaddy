/// The Notifications feature's shared placeholder data.
///
/// See `docs/standards/placeholder-notifications-data.md`. Per
/// `docs/architecture/notifications-engineering-decisions.md`'s
/// "Notifications Reuses Placeholder-Data.md's Existing Notifications",
/// these four messages already existed in `placeholder-data.md`'s
/// "Notifications" section before this feature began — they are reused
/// verbatim, not reinvented.
library;

import 'package:qaddy/features/notifications/models/notification_item.dart';

/// The four Release 1 notifications, in the same order as
/// `placeholder-data.md`'s "Notifications" section.
const List<NotificationItem> notifications = <NotificationItem>[
  NotificationItem(
    id: 'notification-1',
    message: 'Your round starts in 2 days.',
    category: NotificationCategory.roundReminder,
  ),
  NotificationItem(
    id: 'notification-2',
    message: 'Josh accepted your invitation.',
    category: NotificationCategory.friendActivity,
  ),
  NotificationItem(
    id: 'notification-3',
    message: 'Trip payment due this Friday.',
    category: NotificationCategory.tripUpdate,
  ),
  NotificationItem(
    id: 'notification-4',
    message: 'New version of Qaddy available.',
    category: NotificationCategory.systemUpdate,
  ),
];

/// Total notification count — computed, not a new literal.
int get totalNotificationsCount => notifications.length;
