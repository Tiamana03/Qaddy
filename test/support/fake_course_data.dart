/// A pretend course provider for tests: what GolfCore will look like to the
/// app, with a course that is plainly not any real one.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/features/courses/data/course_data_source.dart';
import 'package:qaddy/features/courses/models/course.dart';
import 'package:qaddy/features/courses/models/course_hole.dart';
import 'package:qaddy/features/courses/models/hole_guide.dart';
import 'package:qaddy/features/courses/state/course_providers.dart';

/// Two holes, no more, with distances unlike any sample.
const List<CourseHole> fakeHoles = <CourseHole>[
  CourseHole(number: 1, par: 5, strokeIndex: 2, metres: 500),
  CourseHole(number: 2, par: 3, strokeIndex: 1, metres: 111),
];

/// A course as a provider's adapter would hand it over.
const Course fakeCourse = Course(
  id: 'fake-1',
  name: 'Test Links',
  location: CourseLocation(suburb: 'Testville', region: 'TS'),
  tees: <CourseTee>[CourseTee(id: 't', name: 'Tee', holes: fakeHoles)],
);

/// A catalogue holding [fakeCourse], that can be made to fail.
class FakeCatalogue implements CourseCatalogue {
  FakeCatalogue({this.fails = false});

  /// Whether every call throws, as an unreachable provider would.
  bool fails;

  /// The queries received.
  final List<String> queries = <String>[];

  @override
  bool get isConnected => true;

  @override
  Future<List<CourseSummary>> search(CourseQuery query) async {
    queries.add(query.text);
    if (fails) {
      throw Exception('offline');
    }
    if (query.text.isNotEmpty &&
        !fakeCourse.name.toLowerCase().contains(query.text.toLowerCase())) {
      return const <CourseSummary>[];
    }
    return const <CourseSummary>[
      CourseSummary(
        id: 'fake-1',
        name: 'Test Links',
        location: CourseLocation(suburb: 'Testville', region: 'TS'),
        holeCount: 2,
        distanceKm: 4.2,
      ),
    ];
  }

  @override
  Future<Course?> course(String id) async {
    if (fails) {
      throw Exception('offline');
    }
    return id == 'fake-1' ? fakeCourse : null;
  }
}

/// Pictures, a forecast and GPS for any hole.
class FakeHoleData
    implements HoleMediaSource, WeatherSource, HoleDistanceSource {
  @override
  Future<HoleMedia> media(HoleRef ref) async =>
      HoleMedia(aerialUrl: Uri.parse('https://example.test/${ref.hole}.jpg'));

  @override
  Future<Forecast?> forecast(HoleRef ref) async => const Forecast(
    temperatureC: 17.4,
    condition: 'Showers',
    windKph: 23,
    windFrom: 'SW',
  );

  @override
  Stream<HoleDistances> watch(HoleRef ref) => Stream<HoleDistances>.value(
    const HoleDistances(front: 101, middle: 111, back: 121),
  );
}

/// Overrides that connect the fake provider everywhere.
List<Override> fakeCourseData({FakeCatalogue? catalogue, FakeHoleData? holes}) {
  final data = holes ?? FakeHoleData();
  return <Override>[
    courseCatalogueProvider.overrideWithValue(catalogue ?? FakeCatalogue()),
    holeMediaSourceProvider.overrideWithValue(data),
    weatherSourceProvider.overrideWithValue(data),
    holeDistanceSourceProvider.overrideWithValue(data),
  ];
}
