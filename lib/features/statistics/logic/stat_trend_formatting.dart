/// Formatting helpers for displaying a [StatTrend] on a `QaddyStatisticCard`
/// — see `docs/architecture/statistics-engineering-decisions.md`'s "No
/// Charting Library in Release 1" (the widget's own `trend` field doc
/// comment gives "↓1.2 (Last 3 months)" as its example; this produces
/// exactly that shape).
library;

import 'package:qaddy/features/statistics/models/stat_trend.dart';

/// Formats a value as a whole number when it has no fractional part,
/// otherwise to one decimal place (e.g. `83.0` → "83", `8.4` → "8.4").
String formatStatValue(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

/// Formats [trend]'s delta as trend text, e.g. "↓1.2 (Last 3 months)".
String formatTrendText(StatTrend trend) {
  final delta = trend.delta;
  final arrow = delta < 0
      ? '↓'
      : delta > 0
      ? '↑'
      : '';
  return '$arrow${formatStatValue(delta.abs())} (${trend.period})';
}
