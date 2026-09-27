/// The Activity Feed Item model — see
/// `docs/architecture/activity-feed.md`'s "Activity Feed Item Model" and
/// "Activity Type" sections.
library;

/// The kind of activity an [ActivityFeedItem] represents.
enum ActivityType {
  roundCompleted,
  friendJoined,
  groupJoined,
  tripCreated,
  handicapChanged,
  achievementUnlocked,
}

/// One entry in the friend-scoped Activity Feed.
class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.actor,
    required this.type,
    required this.message,
    required this.timestamp,
    this.relatedEntity,
  });

  /// Unique activity identifier.
  final String id;

  /// The friend the activity belongs to.
  final String actor;

  /// The kind of activity.
  final ActivityType type;

  /// Display text for the activity.
  final String message;

  /// Optional related name (course, group, trip).
  final String? relatedEntity;

  /// When the activity occurred.
  final DateTime timestamp;
}
