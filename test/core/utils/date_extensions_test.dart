import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/utils/date_extensions.dart';

void main() {
  test('isToday and isYesterday reflect the current date', () {
    final now = DateTime.now();
    expect(now.isToday, isTrue);
    expect(now.subtract(const Duration(days: 1)).isYesterday, isTrue);
  });

  test('toFriendlyDate formats as "D Mon YYYY"', () {
    expect(DateTime(2025, 3, 12).toFriendlyDate(), '12 Mar 2025');
  });

  test('toWeekdayAndDate formats as "Weekday D Month" with no year', () {
    // 2 September 2024 (US Labor Day) was a Monday.
    expect(DateTime(2024, 9, 2).toWeekdayAndDate(), 'Monday 2 September');
  });

  test('toRelative reports Today, Yesterday, then a friendly date', () {
    expect(DateTime.now().toRelative(), 'Today');
    expect(
      DateTime.now().subtract(const Duration(days: 1)).toRelative(),
      'Yesterday',
    );
    expect(
      DateTime.now().subtract(const Duration(days: 3)).toRelative(),
      '3 days ago',
    );
  });
}
