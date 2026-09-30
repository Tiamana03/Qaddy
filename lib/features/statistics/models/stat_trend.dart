/// The Stat Trend model — see `docs/architecture/statistics-data-model.md`'s
/// "Stat Trend Model" section.
library;

/// A two-point comparison (current value vs. a previous value) used to show
/// whether a statistic is improving.
class StatTrend {
  const StatTrend({
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.period,
    required this.lowerIsBetter,
  });

  /// What is trending, e.g. "Handicap".
  final String label;

  /// The current value.
  final double currentValue;

  /// The value at the start of the comparison period.
  final double previousValue;

  /// The comparison window, e.g. "Last 3 months".
  final String period;

  /// Whether a decrease represents improvement (true for Handicap and
  /// Average Score; false for a metric like Stableford where higher is
  /// better).
  final bool lowerIsBetter;

  /// currentValue − previousValue.
  double get delta => currentValue - previousValue;

  /// Whether [delta] represents an improvement, given [lowerIsBetter].
  bool get isImprovement => lowerIsBetter ? delta < 0 : delta > 0;
}
