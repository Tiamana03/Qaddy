/// See `docs/sprints/sprint-01-4-responsive-layout.md`'s
/// `date_extensions.dart` section: reusable DateTime helper methods —
/// friendly date formatting, relative dates, common date conversions. No
/// business logic. Implemented without `package:intl`, since this sprint
/// does not require adding a new dependency.
library;

const List<String> _monthAbbreviations = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdayNames = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Reusable `DateTime` helpers.
extension DateExtensions on DateTime {
  /// A date-only copy (year/month/day, time reset to midnight).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Whether this date falls on the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Whether this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// Whether this date is yesterday.
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// A friendly, fixed-format date, e.g. "12 Mar 2025".
  String toFriendlyDate() => '$day ${_monthAbbreviations[month - 1]} $year';

  /// A full weekday name and date with no year, e.g. "Tuesday 22 September" —
  /// matches the Dashboard's Welcome Header example in
  /// `docs/sprints/sprint-02-01-dashboard.md`.
  String toWeekdayAndDate() =>
      '${_weekdayNames[weekday - 1]} $day ${_monthNames[month - 1]}';

  /// A relative description of this date: "Today", "Yesterday", "N days
  /// ago", or [toFriendlyDate] once it's further away than that.
  String toRelative() {
    if (isToday) {
      return 'Today';
    }
    if (isYesterday) {
      return 'Yesterday';
    }
    final days = DateTime.now().dateOnly.difference(dateOnly).inDays;
    if (days > 0 && days < 7) {
      return '$days days ago';
    }
    return toFriendlyDate();
  }
}
