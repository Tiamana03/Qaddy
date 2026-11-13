/// The seams where outside course data plugs in.
///
/// Qaddy is local-first and ships no course database. Courses, hole pictures,
/// GPS and the forecast come from outside, and GolfCore is being evaluated as
/// the course database. Rather than let any screen reach for a provider, every
/// kind of outside data has an interface here, and the app asks only these:
///
/// * [CourseCatalogue]: find a course, load a course.
/// * [HoleMediaSource]: a hole's aerial picture and flyover film.
/// * [HoleDistanceSource]: live GPS distances to the green.
/// * [WeatherSource]: the forecast for a course at a time.
///
/// An integration implements the interfaces it can and leaves the rest on the
/// `Unavailable*` defaults; the screens already handle "not available". Wiring
/// one in is a change to `state/course_providers.dart` and nothing else. See
/// `docs/architecture/course-data.md`.
// ignore_for_file: one_member_abstracts
// Each source is one method on purpose: a provider integration implements
// only the ones it can.
library;

import 'package:qaddy/features/courses/models/course.dart';
import 'package:qaddy/features/courses/models/hole_guide.dart';

/// Finds courses and loads one in full.
abstract interface class CourseCatalogue {
  /// Courses matching [query], best first. An empty list means none matched;
  /// a provider that cannot be reached throws, and the picker says so.
  Future<List<CourseSummary>> search(CourseQuery query);

  /// The course with [id], or `null` if the provider no longer knows it.
  Future<Course?> course(String id);

  /// Whether searching can return anything at all. `false` for the default,
  /// so the picker can explain instead of showing an empty list.
  bool get isConnected;
}

/// Supplies hole pictures and film.
abstract interface class HoleMediaSource {
  /// The media for [ref]'s hole; [HoleMedia.none] when there is none.
  Future<HoleMedia> media(HoleRef ref);
}

/// Supplies GPS distances from the golfer to the green.
abstract interface class HoleDistanceSource {
  /// Distances to [ref]'s hole as the golfer moves; emits nothing when there
  /// is no position fix or no green data.
  Stream<HoleDistances> watch(HoleRef ref);
}

/// Supplies the forecast.
abstract interface class WeatherSource {
  /// The conditions for [ref]'s course at [HoleRef.at] (now when `null`), or
  /// `null` when there is no forecast.
  Future<Forecast?> forecast(HoleRef ref);
}

/// The default catalogue: connected to nothing, so it finds nothing.
class UnavailableCourseCatalogue implements CourseCatalogue {
  const UnavailableCourseCatalogue();

  @override
  bool get isConnected => false;

  @override
  Future<List<CourseSummary>> search(CourseQuery query) async =>
      const <CourseSummary>[];

  @override
  Future<Course?> course(String id) async => null;
}

/// The default media source: no pictures.
class UnavailableHoleMedia implements HoleMediaSource {
  const UnavailableHoleMedia();

  @override
  Future<HoleMedia> media(HoleRef ref) async => HoleMedia.none;
}

/// The default distance source: no GPS.
class UnavailableHoleDistances implements HoleDistanceSource {
  const UnavailableHoleDistances();

  @override
  Stream<HoleDistances> watch(HoleRef ref) =>
      const Stream<HoleDistances>.empty();
}

/// The default weather source: no forecast.
class UnavailableWeather implements WeatherSource {
  const UnavailableWeather();

  @override
  Future<Forecast?> forecast(HoleRef ref) async => null;
}
