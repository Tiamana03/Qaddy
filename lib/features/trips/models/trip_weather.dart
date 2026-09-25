/// A Trip's weather forecast — see placeholder-trip-data.md's "Weather"
/// section. Placeholder only; a future release may integrate a live
/// weather API.
library;

/// One day's forecast.
class TripWeatherForecast {
  const TripWeatherForecast({
    required this.day,
    required this.forecast,
    required this.high,
    required this.low,
  });

  /// The day name (e.g. "Saturday").
  final String day;

  /// A short forecast description (e.g. "Sunny").
  final String forecast;

  /// The forecast high, as sourced (e.g. "24°C").
  final String high;

  /// The forecast low, as sourced (e.g. "14°C").
  final String low;
}
