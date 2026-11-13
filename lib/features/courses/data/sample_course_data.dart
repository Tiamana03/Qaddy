/// The Sample Clubhouse's pretend course, and the sample sources that serve
/// it.
///
/// This is the only hard-coded course in Qaddy, it is sample content (see
/// `core/user/sample_clubhouse.dart`), and it is served through the same
/// interfaces a real provider will use, so the app is exercised exactly as it
/// will be with GolfCore. Switch the Sample Clubhouse off and none of it
/// exists.
library;

import 'package:qaddy/features/courses/data/course_data_source.dart';
import 'package:qaddy/features/courses/models/course.dart';
import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/courses/models/hole_guide.dart';

/// The sample course's id.
const String sampleCourseId = 'sample-richmond';

/// The sample course's eighteen holes: par, stroke index and metres. Sample
/// content, not a real scorecard.
const List<CourseHole> richmondHoles = <CourseHole>[
  CourseHole(number: 1, par: 4, strokeIndex: 11, metres: 352),
  CourseHole(number: 2, par: 5, strokeIndex: 3, metres: 486),
  CourseHole(number: 3, par: 3, strokeIndex: 17, metres: 148),
  CourseHole(number: 4, par: 4, strokeIndex: 7, metres: 371),
  CourseHole(number: 5, par: 4, strokeIndex: 1, metres: 414),
  CourseHole(number: 6, par: 5, strokeIndex: 13, metres: 471),
  CourseHole(number: 7, par: 4, strokeIndex: 9, metres: 364),
  CourseHole(number: 8, par: 3, strokeIndex: 15, metres: 163),
  CourseHole(number: 9, par: 4, strokeIndex: 5, metres: 390),
  CourseHole(number: 10, par: 4, strokeIndex: 10, metres: 360),
  CourseHole(number: 11, par: 5, strokeIndex: 2, metres: 502),
  CourseHole(number: 12, par: 3, strokeIndex: 18, metres: 141),
  CourseHole(number: 13, par: 4, strokeIndex: 6, metres: 384),
  CourseHole(number: 14, par: 4, strokeIndex: 8, metres: 373),
  CourseHole(number: 15, par: 5, strokeIndex: 4, metres: 495),
  CourseHole(number: 16, par: 3, strokeIndex: 16, metres: 158),
  CourseHole(number: 17, par: 4, strokeIndex: 12, metres: 347),
  CourseHole(number: 18, par: 4, strokeIndex: 14, metres: 401),
];

/// The sample course, as a catalogue would return it.
const Course sampleCourse = Course(
  id: sampleCourseId,
  name: 'Richmond Golf Club',
  origin: CourseOrigin.sample,
  location: CourseLocation(suburb: 'Richmond', region: 'VIC'),
  tees: <CourseTee>[
    CourseTee(id: 'sample', name: 'Sample', holes: richmondHoles),
  ],
);

/// A catalogue holding just the sample course.
class SampleCourseCatalogue implements CourseCatalogue {
  const SampleCourseCatalogue();

  @override
  bool get isConnected => true;

  @override
  Future<List<CourseSummary>> search(CourseQuery query) async {
    final text = query.text.trim().toLowerCase();
    if (text.isNotEmpty && !sampleCourse.name.toLowerCase().contains(text)) {
      return const <CourseSummary>[];
    }
    return const <CourseSummary>[
      CourseSummary(
        id: sampleCourseId,
        name: 'Richmond Golf Club',
        location: CourseLocation(suburb: 'Richmond', region: 'VIC'),
        holeCount: 18,
      ),
    ];
  }

  @override
  Future<Course?> course(String id) async =>
      id == sampleCourseId ? sampleCourse : null;
}

/// The sample round's forecast: sunny and 21 degrees, as Saturday's card says.
class SampleWeather implements WeatherSource {
  const SampleWeather();

  @override
  Future<Forecast?> forecast(HoleRef ref) async =>
      ref.courseId == sampleCourseId
      ? const Forecast(temperatureC: 21, condition: 'Sunny')
      : null;
}
