/// The standard scoring layout: par and stroke index for eighteen holes, used
/// when a round is played without a course chosen.
///
/// This is **not a course**. It exists so Stableford can be scored on any
/// course the golfer plays before they pick it from the catalogue: it carries
/// no distances, no pictures and no name of its own, and a `Course` built from
/// it is marked `CourseOrigin.generic` so the UI says "standard layout"
/// rather than pass it off as the course.
library;

import 'package:qaddy/features/courses/models/course_hole.dart';

/// The standard par-72 layout: par and stroke index only.
const List<CourseHole> standardHoles = <CourseHole>[
  CourseHole(number: 1, par: 4, strokeIndex: 11),
  CourseHole(number: 2, par: 5, strokeIndex: 3),
  CourseHole(number: 3, par: 3, strokeIndex: 17),
  CourseHole(number: 4, par: 4, strokeIndex: 7),
  CourseHole(number: 5, par: 4, strokeIndex: 1),
  CourseHole(number: 6, par: 5, strokeIndex: 13),
  CourseHole(number: 7, par: 4, strokeIndex: 9),
  CourseHole(number: 8, par: 3, strokeIndex: 15),
  CourseHole(number: 9, par: 4, strokeIndex: 5),
  CourseHole(number: 10, par: 4, strokeIndex: 10),
  CourseHole(number: 11, par: 5, strokeIndex: 2),
  CourseHole(number: 12, par: 3, strokeIndex: 18),
  CourseHole(number: 13, par: 4, strokeIndex: 6),
  CourseHole(number: 14, par: 4, strokeIndex: 8),
  CourseHole(number: 15, par: 5, strokeIndex: 4),
  CourseHole(number: 16, par: 3, strokeIndex: 16),
  CourseHole(number: 17, par: 4, strokeIndex: 12),
  CourseHole(number: 18, par: 4, strokeIndex: 14),
];
