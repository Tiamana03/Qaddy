import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/courses/data/course_data_source.dart';
import 'package:qaddy/features/courses/data/sample_course_data.dart';
import 'package:qaddy/features/courses/data/standard_layout.dart';
import 'package:qaddy/features/courses/models/course.dart';
import 'package:qaddy/features/courses/models/hole_guide.dart';
import 'package:qaddy/features/courses/state/course_providers.dart';

import '../../support/fake_course_data.dart';
import '../../support/sample_off.dart';

class _Failing implements HoleMediaSource, WeatherSource, HoleDistanceSource {
  @override
  Future<HoleMedia> media(HoleRef ref) async => throw Exception('down');

  @override
  Future<Forecast?> forecast(HoleRef ref) async => throw Exception('down');

  @override
  Stream<HoleDistances> watch(HoleRef ref) =>
      Stream<HoleDistances>.error(Exception('no fix'));
}

ProviderContainer _container([List<Override> overrides = const <Override>[]]) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

void main() {
  tearDown(resetSampleClubhouseForTests);

  group('Course', () {
    test('adds up par and counts holes from its tee', () {
      expect(fakeCourse.defaultTee.par, 8);
      expect(fakeCourse.holeCount, 2);
      expect(fakeCourse.holesFrom(), fakeCourse.tees.first.holes);
      expect(fakeCourse.isGeneric, isFalse);
    });

    test('a generic course is a scoring layout, not a real course', () {
      final course = Course.generic(name: 'Home', holes: standardHoles);

      expect(course.isGeneric, isTrue);
      expect(course.origin, CourseOrigin.generic);
      expect(course.defaultTee.par, 72);
      expect(course.holesFrom().every((h) => h.metres == null), isTrue);
    });

    test('says where it is with whatever is known', () {
      expect(
        const CourseLocation(suburb: 'Richmond', region: 'VIC').label,
        'Richmond, VIC',
      );
      expect(const CourseLocation(region: 'VIC').label, 'VIC');
      expect(const CourseLocation().label, isEmpty);
      expect(
        const CourseLocation(latitude: 1, longitude: 2).hasPosition,
        isTrue,
      );
      expect(const CourseLocation(latitude: 1).hasPosition, isFalse);
    });
  });

  group('HoleGuide', () {
    test('formats the forecast and says nothing it does not know', () {
      const forecast = Forecast(
        temperatureC: 20.6,
        windKph: 12.4,
        windFrom: 'NW',
      );

      expect(forecast.temperatureLabel, '21°');
      expect(forecast.windLabel, '12 km/h NW');
      expect(const Forecast().temperatureLabel, isNull);
      expect(const Forecast().windLabel, isNull);
      expect(const Forecast(windKph: 5).windLabel, '5 km/h');
    });

    test('unavailable has nothing in it', () {
      expect(HoleGuide.unavailable.distances, isNull);
      expect(HoleGuide.unavailable.forecast, isNull);
      expect(HoleGuide.unavailable.media.aerialUrl, isNull);
    });

    test('a hole reference compares by value', () {
      expect(
        const HoleRef(courseId: 'a', hole: 3),
        const HoleRef(courseId: 'a', hole: 3),
      );
      expect(
        const HoleRef(courseId: 'a', hole: 3),
        isNot(const HoleRef(courseId: 'a', hole: 4)),
      );
    });
  });

  group('the defaults', () {
    test('an unconnected catalogue finds nothing and says so', () async {
      const catalogue = UnavailableCourseCatalogue();

      expect(catalogue.isConnected, isFalse);
      expect(await catalogue.search(const CourseQuery(text: 'x')), isEmpty);
      expect(await catalogue.course('any'), isNull);
    });

    test('unconnected sources know nothing', () async {
      const ref = HoleRef(courseId: 'a', hole: 1);

      expect(await const UnavailableHoleMedia().media(ref), HoleMedia.none);
      expect(await const UnavailableWeather().forecast(ref), isNull);
      expect(await const UnavailableHoleDistances().watch(ref).isEmpty, isTrue);
    });
  });

  group('the sample', () {
    test('serves its one course through the catalogue interface', () async {
      const catalogue = SampleCourseCatalogue();

      expect(catalogue.isConnected, isTrue);
      expect(await catalogue.search(const CourseQuery()), hasLength(1));
      expect(
        await catalogue.search(const CourseQuery(text: 'rich')),
        hasLength(1),
      );
      expect(await catalogue.search(const CourseQuery(text: 'zzz')), isEmpty);
      expect(await catalogue.course(sampleCourseId), sampleCourse);
      expect(await catalogue.course('other'), isNull);
      expect(sampleCourse.origin, CourseOrigin.sample);
    });

    test('has a forecast only for its own course', () async {
      final own = await const SampleWeather().forecast(
        const HoleRef(courseId: sampleCourseId, hole: 1),
      );
      final other = await const SampleWeather().forecast(
        const HoleRef(courseId: 'other', hole: 1),
      );

      expect(own?.condition, 'Sunny');
      expect(other, isNull);
    });
  });

  group('providers', () {
    test('with the Sample Clubhouse on, the sample is the default course', () {
      final container = _container();

      expect(container.read(courseCatalogueProvider).isConnected, isTrue);
      expect(container.read(nextRoundCourseProvider), sampleCourse);
    });

    test('with it off, nothing is connected and the layout is generic', () {
      final container = _container(sampleOff());

      expect(container.read(courseCatalogueProvider).isConnected, isFalse);
      final course = container.read(nextRoundCourseProvider);
      expect(course.isGeneric, isTrue);
      expect(course.holeCount, 18);
    });

    test('a chosen course wins, and can be cleared', () {
      final container = _container();

      container.read(selectedCourseProvider.notifier).choose(fakeCourse);
      expect(container.read(nextRoundCourseProvider), fakeCourse);

      container.read(selectedCourseProvider.notifier).choose(null);
      expect(container.read(nextRoundCourseProvider), sampleCourse);
    });

    test('the hole guide gathers every source', () async {
      final container = _container(fakeCourseData());
      const ref = HoleRef(courseId: 'fake-1', hole: 2);
      final subscription = container.listen(holeGuideProvider(ref), (_, _) {});
      addTearDown(subscription.close);

      HoleGuide? guide;
      for (var i = 0; i < 20 && guide?.distances == null; i++) {
        await Future<void>.delayed(Duration.zero);
        guide = container.read(holeGuideProvider(ref)).valueOrNull;
      }

      expect(guide?.distances?.middle, 111);
      expect(guide?.forecast?.condition, 'Showers');
      expect(guide?.media.aerialUrl.toString(), 'https://example.test/2.jpg');
    });

    test('a failing source never breaks the guide', () async {
      final failing = _Failing();
      final container = _container(<Override>[
        holeMediaSourceProvider.overrideWithValue(failing),
        weatherSourceProvider.overrideWithValue(failing),
        holeDistanceSourceProvider.overrideWithValue(failing),
      ]);
      const ref = HoleRef(courseId: 'fake-1', hole: 1);
      final subscription = container.listen(holeGuideProvider(ref), (_, _) {});
      addTearDown(subscription.close);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      final guide = container.read(holeGuideProvider(ref));

      expect(guide.hasError, isFalse);
      expect(guide.valueOrNull?.forecast, isNull);
      expect(guide.valueOrNull?.distances, isNull);
    });
  });
}
