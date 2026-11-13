/// A golf course, as Qaddy needs to know it: who it is, where it is and what
/// its holes are.
///
/// Nothing in the app hard-codes a course. A [Course] arrives from a
/// `CourseCatalogue` (see `data/course_data_source.dart`), whether that is the
/// GolfCore API, a cached copy of it or, for the Sample Clubhouse, a small
/// sample. The shapes here are Qaddy's own, so the screens never learn which
/// provider supplied them; a provider's adapter maps its fields into these.
/// See `docs/architecture/course-data.md`.
library;

import 'package:qaddy/features/courses/models/course_hole.dart';

/// Where a course's details came from. The UI uses it to be honest: a
/// [generic] layout is a scoring convenience, not a real course.
enum CourseOrigin {
  /// Supplied by a course database (GolfCore) or its cache.
  database,

  /// The Sample Clubhouse's pretend course. Labelled Sample wherever shown.
  sample,

  /// A standard scoring layout used when no course has been chosen: par and
  /// stroke index only, no distances, no pictures.
  generic,
}

/// A set of tee markers: the length, and the rating, that a golfer plays.
class CourseTee {
  const CourseTee({
    required this.id,
    required this.name,
    required this.holes,
    this.courseRating,
    this.slopeRating,
  });

  /// The provider's id for the tee.
  final String id;

  /// What golfers call it ("White", "Blue").
  final String name;

  /// Every hole from this tee, in playing order, with this tee's distances.
  final List<CourseHole> holes;

  /// The tee's course rating, when the provider has one.
  final double? courseRating;

  /// The tee's slope rating, when the provider has one.
  final int? slopeRating;

  /// The tee's par.
  int get par => holes.fold<int>(0, (sum, hole) => sum + hole.par);
}

/// Where a course is. Every part is optional: a provider may know only a town.
class CourseLocation {
  const CourseLocation({
    this.suburb,
    this.region,
    this.country,
    this.latitude,
    this.longitude,
  });

  /// The town or suburb ("Richmond").
  final String? suburb;

  /// The state or county ("VIC").
  final String? region;

  /// The country.
  final String? country;

  /// Latitude, for the forecast and for "courses near me".
  final double? latitude;

  /// Longitude, for the forecast and for "courses near me".
  final double? longitude;

  /// "Richmond, VIC", or whatever of it is known; empty when nothing is.
  String get label => <String?>[
    suburb,
    region,
  ].whereType<String>().where((part) => part.isNotEmpty).join(', ');

  /// Whether a position is known.
  bool get hasPosition => latitude != null && longitude != null;
}

/// A course: its name, place, tees and pictures.
class Course {
  const Course({
    required this.id,
    required this.name,
    required this.tees,
    this.clubName,
    this.location = const CourseLocation(),
    this.logoUrl,
    this.photoUrl,
    this.origin = CourseOrigin.database,
  });

  /// A scoring layout for a course Qaddy has no details for: the standard par
  /// and stroke index so Stableford can be scored, and no distances.
  factory Course.generic({
    required String name,
    required List<CourseHole> holes,
  }) => Course(
    id: 'generic',
    name: name,
    origin: CourseOrigin.generic,
    tees: <CourseTee>[
      CourseTee(id: 'standard', name: 'Standard', holes: holes),
    ],
  );

  /// The provider's stable id. Rounds keep it, so a played round can find its
  /// course again.
  final String id;

  /// The course's name ("Richmond Golf Club").
  final String name;

  /// The club that owns it, when that differs from [name] (a club with
  /// several courses).
  final String? clubName;

  /// Where it is.
  final CourseLocation location;

  /// The club's logo, to be shown when the provider supplies one.
  final Uri? logoUrl;

  /// A photograph of the course, when the provider supplies one.
  final Uri? photoUrl;

  /// The tees, longest first by convention. Never empty.
  final List<CourseTee> tees;

  /// Where the details came from.
  final CourseOrigin origin;

  /// The tee a golfer plays when they have not chosen one.
  CourseTee get defaultTee => tees.first;

  /// The holes from [tee] (or the default tee).
  List<CourseHole> holesFrom([CourseTee? tee]) => (tee ?? defaultTee).holes;

  /// How many holes the course has.
  int get holeCount => defaultTee.holes.length;

  /// Whether this is only a scoring layout, not a real course.
  bool get isGeneric => origin == CourseOrigin.generic;
}

/// A course in a search result: enough to choose from, light to fetch.
class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.name,
    this.location = const CourseLocation(),
    this.holeCount,
    this.logoUrl,
    this.distanceKm,
  });

  /// The provider's stable id.
  final String id;

  /// The course's name.
  final String name;

  /// Where it is.
  final CourseLocation location;

  /// How many holes it has, when known.
  final int? holeCount;

  /// The club's logo, when supplied.
  final Uri? logoUrl;

  /// How far it is from the search position, when the search had one.
  final double? distanceKm;
}

/// What a golfer asked the catalogue for.
class CourseQuery {
  const CourseQuery({this.text = '', this.nearLatitude, this.nearLongitude});

  /// Words from the course or club name.
  final String text;

  /// A position to search near, in degrees.
  final double? nearLatitude;

  /// A position to search near, in degrees.
  final double? nearLongitude;
}
