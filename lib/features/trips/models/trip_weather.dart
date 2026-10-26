/// A Trip's weather forecast — see `docs/architecture/trip-data-model.md`'s
/// "Weather" section. Entered manually in Release 1; a later release may
/// integrate a live weather API.
library;

import 'package:flutter/material.dart';

/// The conditions a forecast can describe.
enum WeatherCondition {
  sunny('Sunny', Icons.wb_sunny_outlined),
  partlyCloudy('Partly Cloudy', Icons.wb_cloudy_outlined),
  cloudy('Cloudy', Icons.cloud_outlined),
  showers('Showers', Icons.grain),
  rain('Rain', Icons.umbrella_outlined),
  windy('Windy', Icons.air);

  const WeatherCondition(this.label, this.icon);

  /// Display name.
  final String label;

  /// Icon shown beside it.
  final IconData icon;
}

/// One day's forecast.
class TripWeatherForecast {
  const TripWeatherForecast({
    required this.id,
    required this.day,
    required this.condition,
    required this.high,
    required this.low,
  });

  /// Unique identifier within the trip.
  final String id;

  /// The day name (e.g. "Saturday").
  final String day;

  /// The expected conditions.
  final WeatherCondition condition;

  /// The forecast high in °C.
  final int high;

  /// The forecast low in °C.
  final int low;

  /// "Sunny" — the condition's label.
  String get forecast => condition.label;

  /// "24°C".
  String get highLabel => '$high°C';

  /// "14°C".
  String get lowLabel => '$low°C';

  /// A copy with the given fields replaced.
  TripWeatherForecast copyWith({
    String? day,
    WeatherCondition? condition,
    int? high,
    int? low,
  }) {
    return TripWeatherForecast(
      id: id,
      day: day ?? this.day,
      condition: condition ?? this.condition,
      high: high ?? this.high,
      low: low ?? this.low,
    );
  }
}
