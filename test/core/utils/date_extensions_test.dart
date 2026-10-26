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

  test('toFriendlyRange drops whatever repeats between the two dates', () {
    expect(
      DateTime(2025, 10, 10).toFriendlyRange(DateTime(2025, 10, 15)),
      '10–15 Oct 2025',
    );
    expect(
      DateTime(2026, 11, 28).toFriendlyRange(DateTime(2026, 12)),
      '28 Nov – 1 Dec 2026',
    );
    expect(
      DateTime(2026, 12, 30).toFriendlyRange(DateTime(2027, 1, 2)),
      '30 Dec 2026 – 2 Jan 2027',
    );
    expect(
      DateTime(2026, 3, 4).toFriendlyRange(DateTime(2026, 3, 4)),
      '4 Mar 2026',
    );
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

  test('calendarDaysUntil counts whole calendar days, not elapsed hours', () {
    // 26 Sep -> 26 Oct spans the start of daylight saving in southern
    // hemisphere zones, where the span is 30 days but only 719 hours.
    expect(DateTime(2026, 9, 26).calendarDaysUntil(DateTime(2026, 10, 26)), 30);
    expect(
      DateTime(2026, 10, 26).calendarDaysUntil(DateTime(2026, 9, 26)),
      -30,
    );
    expect(DateTime(2026, 10, 26).calendarDaysUntil(DateTime(2026, 10, 26)), 0);
    expect(
      DateTime(
        2026,
        10,
        26,
        23,
        30,
      ).calendarDaysUntil(DateTime(2026, 10, 27, 0, 30)),
      1,
    );
  });

  test('toRelative reports weeks and months once a week has passed', () {
    expect(
      DateTime.now().subtract(const Duration(days: 14)).toRelative(),
      '2 weeks ago',
    );
    expect(
      DateTime.now().subtract(const Duration(days: 30)).toRelative(),
      '1 month ago',
    );
    expect(
      DateTime.now().subtract(const Duration(days: 182)).toRelative(),
      '6 months ago',
    );
  });
}
