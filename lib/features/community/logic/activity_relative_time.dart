/// Activity Feed's relative timestamp formatting.
///
/// Activity Feed needs same-day entries to read "N hours ago" (see
/// placeholder-friend-data.md's "Activity Feed" section, e.g. "2 hours
/// ago") — finer-grained than `DateTime.toRelative()`'s day-level
/// "Today", which every other feature's relative dates use. Kept local to
/// this feature rather than widening the shared, tested `toRelative()`
/// utility for a display need specific to this one screen.
library;

import 'package:qaddy/core/utils/date_extensions.dart';

/// A relative description of [timestamp] for the Activity Feed: "N hours
/// ago" for same-day entries at least an hour old, otherwise falls back to
/// `toRelative()`'s "Today"/"Yesterday"/"N days ago" etc.
String formatActivityTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  if (timestamp.isSameDay(now)) {
    final hours = now.difference(timestamp).inHours;
    if (hours >= 1) {
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
  }
  return timestamp.toRelative();
}
