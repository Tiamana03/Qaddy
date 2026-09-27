import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/features/community/logic/activity_relative_time.dart';

void main() {
  test('formats same-day entries in hours', () {
    final timestamp = DateTime.now().subtract(const Duration(hours: 2));
    expect(formatActivityTimestamp(timestamp), '2 hours ago');
  });

  test('falls back to toRelative beyond the same day', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    expect(formatActivityTimestamp(yesterday), 'Yesterday');

    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    expect(formatActivityTimestamp(threeDaysAgo), '3 days ago');
  });
}
