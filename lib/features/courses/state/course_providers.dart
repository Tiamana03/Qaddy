/// Where the app gets course data from. The only place a provider is chosen.
///
/// Every course-related screen reads these providers and nothing else, so
/// connecting GolfCore later means replacing the four source providers below
/// (or overriding them in `main`), with no screen changing. Until then the
/// Sample Clubhouse is served by the sample sources, and everyone else gets
/// the `Unavailable*` defaults, which return "nothing known" and are drawn as
/// dashes and sized placeholders.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/user/current_user.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/courses/data/course_data_source.dart';
import 'package:qaddy/features/courses/data/sample_course_data.dart';
import 'package:qaddy/features/courses/data/standard_layout.dart';
import 'package:qaddy/features/courses/models/course.dart';
import 'package:qaddy/features/courses/models/hole_guide.dart';

/// The course catalogue: the sample's while the Sample Clubhouse is on,
/// otherwise nothing is connected yet.
final courseCatalogueProvider = Provider<CourseCatalogue>(
  (ref) => ref.watch(sampleOnProvider)
      ? const SampleCourseCatalogue()
      : const UnavailableCourseCatalogue(),
);

/// Hole pictures and film. Nothing is connected yet.
final holeMediaSourceProvider = Provider<HoleMediaSource>(
  (ref) => const UnavailableHoleMedia(),
);

/// GPS distances to the green. Nothing is connected yet.
final holeDistanceSourceProvider = Provider<HoleDistanceSource>(
  (ref) => const UnavailableHoleDistances(),
);

/// The forecast: the sample round's while the Sample Clubhouse is on,
/// otherwise nothing is connected yet.
final weatherSourceProvider = Provider<WeatherSource>(
  (ref) => ref.watch(sampleOnProvider)
      ? const SampleWeather()
      : const UnavailableWeather(),
);

/// The course picked for the next round, or `null` while none has been.
final selectedCourseProvider = NotifierProvider<SelectedCourse, Course?>(
  SelectedCourse.new,
);

/// Holds the golfer's course choice.
class SelectedCourse extends Notifier<Course?> {
  @override
  Course? build() => null;

  /// Picks [course]. `null` goes back to the default.
  // ignore: use_setters_to_change_properties
  void choose(Course? course) => state = course;
}

/// The course the next round is played on: the one picked, else the sample
/// course (Sample Clubhouse on) or the standard scoring layout at the
/// golfer's home course.
final nextRoundCourseProvider = Provider<Course>((ref) {
  final picked = ref.watch(selectedCourseProvider);
  if (picked != null) {
    return picked;
  }
  return ref.watch(sampleOnProvider)
      ? sampleCourse
      : Course.generic(
          name: currentUserHomeCourse ?? 'Your course',
          holes: standardHoles,
        );
});

/// What is known about a hole right now: forecast, pictures and, as the
/// golfer moves, GPS distances. A source that fails counts as "not known";
/// it never breaks the scorecard.
final holeGuideProvider = StreamProvider.autoDispose.family<HoleGuide, HoleRef>(
  (ref, hole) async* {
    final media = await _orNull(ref.watch(holeMediaSourceProvider).media(hole));
    final forecast = await _orNull(
      ref.watch(weatherSourceProvider).forecast(hole),
    );
    var guide = HoleGuide(media: media ?? HoleMedia.none, forecast: forecast);
    yield guide;
    try {
      await for (final distances
          in ref.watch(holeDistanceSourceProvider).watch(hole)) {
        guide = HoleGuide(
          distances: distances,
          forecast: guide.forecast,
          media: guide.media,
        );
        yield guide;
      }
    } on Object {
      // No GPS: the guide keeps what it has.
    }
  },
);

Future<T?> _orNull<T>(Future<T?> future) async {
  try {
    return await future;
  } on Object {
    return null;
  }
}
