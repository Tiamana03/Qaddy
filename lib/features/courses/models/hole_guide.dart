/// Everything that is known about a hole *right now* beyond its par and
/// length: GPS distances, the forecast, and the pictures. Each part comes from
/// its own source (see `data/course_data_source.dart`) and any part may be
/// missing, so every field is nullable and the screens draw a placeholder of
/// the same size when one is.
library;

import 'package:flutter/foundation.dart' show immutable;

/// Distances from the golfer to the green, in metres.
class HoleDistances {
  const HoleDistances({this.front, this.middle, this.back, this.toTarget});

  /// To the front edge of the green.
  final int? front;

  /// To the middle of the green.
  final int? middle;

  /// To the back edge of the green.
  final int? back;

  /// To a point the golfer tapped on the map, when they did.
  final int? toTarget;
}

/// The conditions on the course.
class Forecast {
  const Forecast({
    this.temperatureC,
    this.condition,
    this.windKph,
    this.windFrom,
  });

  /// Degrees Celsius.
  final double? temperatureC;

  /// A word for the sky ("Sunny").
  final String? condition;

  /// The wind's speed, in kilometres an hour.
  final double? windKph;

  /// Where the wind blows from, as a compass point ("NW").
  final String? windFrom;

  /// "21°", or `null` when no temperature is known.
  String? get temperatureLabel =>
      temperatureC == null ? null : '${temperatureC!.round()}°';

  /// "12 km/h NW", or `null` when no wind is known.
  String? get windLabel => windKph == null
      ? null
      : '${windKph!.round()} km/h${windFrom == null ? '' : ' $windFrom'}';
}

/// A hole's pictures and film. Locations, not bytes: the screens load them
/// and show the sized placeholder until they arrive or if there are none.
class HoleMedia {
  const HoleMedia({this.aerialUrl, this.flyoverUrl});

  /// The picture of the hole from above.
  final Uri? aerialUrl;

  /// The flyover film.
  final Uri? flyoverUrl;

  /// Nothing is available.
  static const HoleMedia none = HoleMedia();
}

/// Which hole, on which course, when. The key every hole-level source answers.
@immutable
class HoleRef {
  const HoleRef({required this.courseId, required this.hole, this.at});

  /// The course's id (`Round.courseId`).
  final String? courseId;

  /// The hole number, 1 to 18.
  final int hole;

  /// When the golfer is playing it, for the forecast.
  final DateTime? at;

  @override
  bool operator ==(Object other) =>
      other is HoleRef &&
      other.courseId == courseId &&
      other.hole == hole &&
      other.at == at;

  @override
  int get hashCode => Object.hash(courseId, hole, at);
}

/// What the live hole screen shows beyond par and length, gathered from the
/// sources. [unavailable] is the honest default.
class HoleGuide {
  const HoleGuide({this.distances, this.forecast, this.media = HoleMedia.none});

  /// GPS distances, or `null` when there is no position or no green data.
  final HoleDistances? distances;

  /// The conditions, or `null` when there is no forecast.
  final Forecast? forecast;

  /// Pictures and film.
  final HoleMedia media;

  /// Nothing known: the screen shows dashes and placeholders.
  static const HoleGuide unavailable = HoleGuide();
}
