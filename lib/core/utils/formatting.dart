/// See `docs/sprints/sprint-01-4-responsive-layout.md`'s `formatting.dart`
/// section: reusable formatting helpers shared throughout the
/// application — distances, scores, durations, currency. Generic and
/// reusable; no feature-specific formatting.
library;

/// Formats a distance given in metres.
///
/// Under 1000m, formats as whole metres (e.g. "254m"); at or above 1000m,
/// formats as kilometres to one decimal place (e.g. "15.4 km") — matching
/// the exact examples in `design/design-tokens/typography.md`'s
/// `statDistance` / `statDistanceLong` usage.
String formatDistance(double metres) {
  if (metres < 1000) {
    return '${metres.round()}m';
  }
  return '${(metres / 1000).toStringAsFixed(1)} km';
}

/// Formats a score relative to par using standard golf notation:
/// negative values as "-3", positive values as "+2", and zero as "E"
/// (even).
String formatScore(int relativeToPar) {
  if (relativeToPar == 0) {
    return 'E';
  }
  return relativeToPar > 0 ? '+$relativeToPar' : '$relativeToPar';
}

/// Formats a [Duration] as e.g. "1h 23m", or just "45m" under an hour.
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) {
    return '${minutes}m';
  }
  return '${hours}h ${minutes}m';
}

/// Formats an amount as currency with the given [symbol] (defaults to
/// "$"), always showing two decimal places (e.g. "$12.00").
String formatCurrency(double amount, {String symbol = r'$'}) {
  return '$symbol${amount.toStringAsFixed(2)}';
}
