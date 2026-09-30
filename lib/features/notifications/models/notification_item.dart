/// The Notification Item model — see
/// `docs/architecture/notifications-data-model.md`'s "Notification Item
/// Model" and "Notification Category" sections.
library;

import 'package:flutter/material.dart';

/// Which kind of notification a [NotificationItem] represents.
///
/// Reused directly by Settings' Notification Preferences section — see
/// `docs/architecture/notifications-engineering-decisions.md`'s "Categories
/// Exist So Settings Can Reference Them Without a Second List".
enum NotificationCategory {
  roundReminder,
  friendActivity,
  tripUpdate,
  systemUpdate,
}

/// A human-readable label for [category].
String notificationCategoryLabel(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.roundReminder => 'Round Reminders',
    NotificationCategory.friendActivity => 'Friend Activity',
    NotificationCategory.tripUpdate => 'Trip Updates',
    NotificationCategory.systemUpdate => 'System Updates',
  };
}

/// The icon representing [category].
IconData notificationCategoryIcon(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.roundReminder => Icons.flag_outlined,
    NotificationCategory.friendActivity => Icons.people_outline,
    NotificationCategory.tripUpdate => Icons.card_travel,
    NotificationCategory.systemUpdate => Icons.info_outline,
  };
}

/// One in-app notification.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.message,
    required this.category,
  });

  /// Unique notification identifier.
  final String id;

  /// Display text.
  final String message;

  /// Which kind of notification this is.
  final NotificationCategory category;
}
