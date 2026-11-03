/// One notification, and the kinds there are.
///
/// Notifications are not a stored list: they are worked out from what is
/// really going on in the golfer's Qaddy (a round to play, a mate waiting, a
/// trip coming up) — see `logic/notification_feed.dart` and
/// `docs/features/notifications-release-candidate.md`. Each knows where it
/// leads.
library;

import 'package:flutter/material.dart';

/// Which kind of notification a [NotificationItem] is. Settings lets the golfer
/// switch each kind on or off.
enum NotificationCategory {
  roundReminder,
  friendActivity,
  tripUpdate,
  systemUpdate,
}

/// A short name for [category], as Settings and the feed show it.
String notificationCategoryLabel(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.roundReminder => 'Rounds',
    NotificationCategory.friendActivity => 'Mates and groups',
    NotificationCategory.tripUpdate => 'Trips',
    NotificationCategory.systemUpdate => 'Tips and milestones',
  };
}

/// One line saying what [category] covers, for Settings.
String notificationCategoryBlurb(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.roundReminder =>
      'Your next tee time and a round in progress',
    NotificationCategory.friendActivity =>
      'Friend requests and where your groups stand',
    NotificationCategory.tripUpdate =>
      'Trips coming up and who still has to reply',
    NotificationCategory.systemUpdate =>
      'Welcome tips and achievements you earn',
  };
}

/// The icon representing [category].
IconData notificationCategoryIcon(NotificationCategory category) {
  return switch (category) {
    NotificationCategory.roundReminder => Icons.flag_outlined,
    NotificationCategory.friendActivity => Icons.people_outline,
    NotificationCategory.tripUpdate => Icons.luggage_outlined,
    NotificationCategory.systemUpdate => Icons.emoji_events_outlined,
  };
}

/// One notification.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.category,
    required this.message,
    required this.location,
    this.detail,
    this.when,
    this.icon,
    this.sample = false,
  });

  /// A stable identity: the same thing happening again is the same
  /// notification, so reading it once reads it for good. When what it says
  /// changes (a new achievement, a new position) the id changes and it is new
  /// again.
  final String id;

  /// Which kind this is.
  final NotificationCategory category;

  /// What it says.
  final String message;

  /// A line beneath, for the detail.
  final String? detail;

  /// When or how soon, as display text ("In 4 days", "3 days ago").
  final String? when;

  /// Where tapping it goes: an app route.
  final String location;

  /// An icon of its own, instead of its category's.
  final IconData? icon;

  /// Whether it comes from the Sample Clubhouse rather than the golfer's own
  /// rounds, mates and trips.
  final bool sample;
}

/// A notification and whether the golfer has seen it.
class NotificationEntry {
  const NotificationEntry({required this.item, required this.isRead});

  final NotificationItem item;
  final bool isRead;
}
